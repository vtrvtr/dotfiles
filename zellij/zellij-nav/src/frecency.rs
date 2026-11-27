use std::collections::{HashMap, VecDeque};
use std::path::Path;

use serde::{Deserialize, Serialize};
use zellij_tile::prelude::PaneId;

// `/tmp` (→ /tmp/zellij-<UID>/) is shared across plugin instances. `/data`
// would be the natural choice, but it's per-instance, and `close_self`
// gives us a fresh instance on every Ctrl+p — so saving to `/data` means
// each new picker has an empty frecency. /tmp survives the close_self
// cycle.
const FILE: &str = "/tmp/zellij_nav_frecency.bin";

/// Half-life of an access's contribution. 10 days → an access from yesterday
/// is worth ~93% of a fresh one; a 10-day-old access is worth 50%.
const HALF_LIFE_DAYS: f64 = 10.0;
const DECAY: f64 = std::f64::consts::LN_2 / HALF_LIFE_DAYS;
const SECONDS_PER_DAY: f64 = 86_400.0;
const MAX_HISTORY_DAYS: f64 = 30.0;
const MAX_ACCESSES_PER_PANE: usize = 32;

/// Two accesses within this window count as one, so PaneUpdate-driven
/// `record_focus` spam doesn't drown out actual navigation events.
const COALESCE_WINDOW_SECS: u64 = 5;

/// Timestamp-keyed access tracker. Each focused/activated terminal pane gets
/// a series of timestamps; the frecency score is a decayed sum and the
/// last-access timestamp is exposed for use as a sort tiebreaker.
///
/// Plugin panes are rejected at the boundary so the picker can't accidentally
/// track itself.
#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Frecency {
    accesses: HashMap<u32, VecDeque<u64>>,
}

impl Frecency {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn bump(&mut self, id: PaneId, now: u64) {
        let PaneId::Terminal(n) = id else { return };
        let stamps = self.accesses.entry(n).or_default();
        // Coalesce bursts: a fresh PaneUpdate every 100ms shouldn't each
        // count as an access.
        if let Some(&latest) = stamps.back() {
            if now.saturating_sub(latest) < COALESCE_WINDOW_SECS {
                return;
            }
        }
        stamps.push_back(now);
        if stamps.len() > MAX_ACCESSES_PER_PANE {
            stamps.pop_front();
        }
    }

    /// fff's decayed-sum formula. Returns 0.0..~15.0 (10 + sqrt-growth after).
    pub fn score(&self, id: PaneId, now: u64) -> f32 {
        let PaneId::Terminal(n) = id else { return 0.0 };
        let Some(stamps) = self.accesses.get(&n) else { return 0.0 };
        let cutoff = now.saturating_sub((MAX_HISTORY_DAYS * SECONDS_PER_DAY) as u64);
        let raw: f64 = stamps
            .iter()
            .rev()
            .take_while(|&&t| t >= cutoff)
            .map(|&t| {
                let days = (now.saturating_sub(t) as f64) / SECONDS_PER_DAY;
                (-DECAY * days).exp()
            })
            .sum();
        let normalized = if raw <= 10.0 { raw } else { 10.0 + (raw - 10.0).sqrt() };
        normalized as f32
    }

    pub fn last_access(&self, id: PaneId) -> Option<u64> {
        let PaneId::Terminal(n) = id else { return None };
        self.accesses.get(&n).and_then(|v| v.back().copied())
    }

    pub fn load_from_disk() -> Self {
        let path = Path::new(FILE);
        if !path.exists() {
            return Self::new();
        }
        match std::fs::read(path).map(|b| postcard::from_bytes::<Self>(&b)) {
            Ok(Ok(f)) => f,
            _ => Self::new(),
        }
    }

    pub fn save_to_disk(&self) -> std::io::Result<()> {
        let bytes = postcard::to_allocvec(self).map_err(std::io::Error::other)?;
        std::fs::write(FILE, bytes)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const NOW: u64 = 1_700_000_000;
    const DAY: u64 = 86_400;

    #[test]
    fn plugin_panes_are_ignored() {
        let mut f = Frecency::new();
        f.bump(PaneId::Plugin(1), NOW);
        assert_eq!(f.score(PaneId::Plugin(1), NOW), 0.0);
        assert_eq!(f.last_access(PaneId::Plugin(1)), None);
    }

    #[test]
    fn empty_score_is_zero() {
        let f = Frecency::new();
        assert_eq!(f.score(PaneId::Terminal(1), NOW), 0.0);
    }

    #[test]
    fn fresh_access_scores_one() {
        let mut f = Frecency::new();
        f.bump(PaneId::Terminal(1), NOW);
        // Score of one fresh access: exp(-DECAY * 0) = 1.0
        let s = f.score(PaneId::Terminal(1), NOW);
        assert!((s - 1.0).abs() < 0.01, "got {s}");
    }

    #[test]
    fn decay_halves_at_half_life() {
        let mut f = Frecency::new();
        f.bump(PaneId::Terminal(1), NOW - HALF_LIFE_DAYS as u64 * DAY);
        let s = f.score(PaneId::Terminal(1), NOW);
        assert!((s - 0.5).abs() < 0.05, "10-day-old access should score ~0.5; got {s}");
    }

    #[test]
    fn coalesce_collapses_burst() {
        let mut f = Frecency::new();
        for i in 0..5 {
            f.bump(PaneId::Terminal(1), NOW + i); // 1-second apart
        }
        // Coalesce window is 5s, so all 5 collapse into the first one.
        let s = f.score(PaneId::Terminal(1), NOW + 4);
        assert!((s - 1.0).abs() < 0.01, "burst should count as one; got {s}");
    }

    #[test]
    fn distinct_events_accumulate() {
        let mut f = Frecency::new();
        // Three events well outside the coalesce window.
        f.bump(PaneId::Terminal(1), NOW - 3 * COALESCE_WINDOW_SECS);
        f.bump(PaneId::Terminal(1), NOW - 2 * COALESCE_WINDOW_SECS);
        f.bump(PaneId::Terminal(1), NOW);
        let s = f.score(PaneId::Terminal(1), NOW);
        // Sum of three ~1.0 decays — basically 3.
        assert!(s > 2.5 && s < 3.5, "got {s}");
    }

    #[test]
    fn last_access_is_most_recent() {
        let mut f = Frecency::new();
        f.bump(PaneId::Terminal(1), NOW - 10 * COALESCE_WINDOW_SECS);
        f.bump(PaneId::Terminal(1), NOW);
        assert_eq!(f.last_access(PaneId::Terminal(1)), Some(NOW));
    }

    #[test]
    fn old_accesses_evicted_when_cap_hit() {
        let mut f = Frecency::new();
        let oldest = NOW - 100 * COALESCE_WINDOW_SECS;
        f.bump(PaneId::Terminal(1), oldest);
        for i in 1..=MAX_ACCESSES_PER_PANE as u64 {
            f.bump(PaneId::Terminal(1), oldest + i * COALESCE_WINDOW_SECS * 2);
        }
        let stamps = &f.accesses[&1];
        assert_eq!(stamps.len(), MAX_ACCESSES_PER_PANE);
        // The first one we pushed should have been evicted.
        assert!(!stamps.contains(&oldest));
    }

    #[test]
    fn persistence_roundtrip() {
        let mut f = Frecency::new();
        f.bump(PaneId::Terminal(1), NOW);
        f.bump(PaneId::Terminal(2), NOW - COALESCE_WINDOW_SECS * 2);
        let bytes = postcard::to_allocvec(&f).unwrap();
        let f2: Frecency = postcard::from_bytes(&bytes).unwrap();
        assert_eq!(f2.last_access(PaneId::Terminal(1)), Some(NOW));
        assert_eq!(f2.last_access(PaneId::Terminal(2)), Some(NOW - COALESCE_WINDOW_SECS * 2));
    }
}
