use nucleo_matcher::{Config, Matcher, Utf32Str};
use zellij_tile::prelude::PaneId;

use crate::candidates::Candidate;
use crate::frecency::Frecency;

pub struct RankContext<'a> {
    pub query: &'a str,
    pub frecency: &'a Frecency,
    /// Hidden entirely from results — the user's current pane.
    pub current_pane: Option<PaneId>,
    pub now: u64,
}

#[derive(Debug, Clone)]
pub struct Scored {
    pub candidate_idx: usize,
    pub match_indices: Vec<u32>,
    pub combined: i32,
    /// Most recent access timestamp — used as the sort tiebreaker.
    pub last_access: u64,
}

pub struct Fuzzy {
    matcher: Matcher,
    haystack_buf: Vec<char>,
    needle_buf: Vec<char>,
    idx_buf: Vec<u32>,
}

impl Fuzzy {
    pub fn new() -> Self {
        let mut config = Config::DEFAULT;
        config.prefer_prefix = true;
        Self {
            matcher: Matcher::new(config),
            haystack_buf: Vec::new(),
            needle_buf: Vec::new(),
            idx_buf: Vec::new(),
        }
    }

    /// Pure decision. Filters out the current pane and (with a query) any
    /// non-matching candidates. Ranks remaining by fff's multiplicative
    /// frecency boost; falls back to most-recent-access as a tiebreaker.
    pub fn rank(&mut self, candidates: &[Candidate], ctx: &RankContext) -> Vec<Scored> {
        let needle = Utf32Str::new(ctx.query, &mut self.needle_buf);
        let has_query = !ctx.query.is_empty();

        let mut out = Vec::with_capacity(candidates.len());
        for (idx, cand) in candidates.iter().enumerate() {
            if Some(cand.id) == ctx.current_pane {
                continue;
            }

            self.idx_buf.clear();
            let haystack = Utf32Str::new(&cand.search_text, &mut self.haystack_buf);
            // With an empty query, base=1 makes the multiplicative boost
            // collapse to (frecency_score / 100 ≈ 0), so all combined scores
            // are 1 and ordering falls to the last_access tiebreaker — the
            // Alt-Tab cycle behavior the user expects.
            let base: i32 = if has_query {
                match self.matcher.fuzzy_indices(haystack, needle, &mut self.idx_buf) {
                    Some(score) => score as i32,
                    None => continue,
                }
            } else {
                1
            };

            // fff's formula: frecency boosts ~0–15% of base.
            let frecency_score = ctx.frecency.score(cand.id, ctx.now);
            let frecency_boost = ((base as f32) * frecency_score / 100.0) as i32;
            let combined = base.saturating_add(frecency_boost);
            let last_access = ctx.frecency.last_access(cand.id).unwrap_or(0);

            out.push(Scored {
                candidate_idx: idx,
                match_indices: self.idx_buf.clone(),
                combined,
                last_access,
            });
        }

        // Primary: combined desc. Tiebreaker: last_access desc (most recent wins).
        out.sort_by(|a, b| {
            b.combined
                .cmp(&a.combined)
                .then_with(|| b.last_access.cmp(&a.last_access))
                .then_with(|| a.candidate_idx.cmp(&b.candidate_idx))
        });
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const NOW: u64 = 1_700_000_000;
    const DAY: u64 = 86_400;

    fn pane(id: u32, title: &str) -> Candidate {
        Candidate {
            id: PaneId::Terminal(id),
            tab_name: "t".into(),
            label: format!("t  {title}"),
            search_text: title.into(),
        }
    }

    fn pane_in_tab(id: u32, tab_name: &str, title: &str) -> Candidate {
        Candidate {
            id: PaneId::Terminal(id),
            tab_name: tab_name.into(),
            label: format!("{tab_name}  {title}"),
            search_text: format!("{tab_name} {title}"),
        }
    }

    fn ids(scored: &[Scored], cands: &[Candidate]) -> Vec<u32> {
        scored
            .iter()
            .map(|s| match cands[s.candidate_idx].id {
                PaneId::Terminal(n) => n,
                PaneId::Plugin(_) => unreachable!(),
            })
            .collect()
    }

    fn ctx<'a>(query: &'a str, frecency: &'a Frecency, current: Option<PaneId>) -> RankContext<'a> {
        RankContext { query, frecency, current_pane: current, now: NOW }
    }

    #[test]
    fn current_pane_is_excluded() {
        let cands = vec![pane(1, "a"), pane(2, "b")];
        let freq = Frecency::new();
        let mut f = Fuzzy::new();
        let out = f.rank(&cands, &ctx("", &freq, Some(PaneId::Terminal(1))));
        assert!(!ids(&out, &cands).contains(&1));
    }

    /// Empty query, recency-only ordering. C is current and excluded; B is the
    /// most-recently-touched non-current and should land on top.
    #[test]
    fn cycle_via_last_access_tiebreaker() {
        let cands = vec![pane(1, "a"), pane(2, "b"), pane(3, "c")];
        let mut freq = Frecency::new();
        freq.bump(PaneId::Terminal(1), NOW - 10 * DAY); // A: oldest
        freq.bump(PaneId::Terminal(2), NOW - 60);        // B: recent
        freq.bump(PaneId::Terminal(3), NOW);             // C: just-now (current)
        let mut f = Fuzzy::new();
        let out = f.rank(&cands, &ctx("", &freq, Some(PaneId::Terminal(3))));
        let order = ids(&out, &cands);
        assert_eq!(order[0], 2, "B (most recently touched, non-current) should be top; got {order:?}");
    }

    /// Two panes both prefix-match the query equally; recency breaks the tie.
    #[test]
    fn recency_breaks_fuzzy_ties() {
        let cands = vec![
            pane_in_tab(1, "packit", "alpha"),
            pane_in_tab(2, "packit", "alpha"),
        ];
        let mut freq = Frecency::new();
        freq.bump(PaneId::Terminal(1), NOW - DAY);
        freq.bump(PaneId::Terminal(2), NOW - 60);
        let mut f = Fuzzy::new();
        let out = f.rank(&cands, &ctx("packit", &freq, None));
        let order = ids(&out, &cands);
        assert_eq!(order[0], 2, "more-recently-visited match wins; got {order:?}");
    }

    /// A vastly stronger fuzzy match should still beat a marginally-recency-
    /// boosted weak match.
    #[test]
    fn strong_fuzzy_beats_weak_with_recency() {
        let cands = vec![
            pane(1, "completely unrelated thing"),
            pane(2, "packit develop"),
        ];
        let mut freq = Frecency::new();
        // pane 1 is hot but barely matches
        for i in 0..5 {
            freq.bump(PaneId::Terminal(1), NOW - i * 10 * COALESCE);
        }
        let mut f = Fuzzy::new();
        let out = f.rank(&cands, &ctx("packit", &freq, None));
        let order = ids(&out, &cands);
        // pane 1 should be filtered (no "packit" match), or at minimum behind 2.
        assert_eq!(order[0], 2, "strong match wins; got {order:?}");
    }

    /// Tab name in search_text means typing the tab name clusters its panes.
    #[test]
    fn tab_name_in_query_groups_tab_panes() {
        let cands = vec![
            pane_in_tab(1, "packit", "nvim"),
            pane_in_tab(2, "other", "shell"),
            pane_in_tab(3, "packit", "cargo"),
        ];
        let freq = Frecency::new();
        let mut f = Fuzzy::new();
        let out = f.rank(&cands, &ctx("packit", &freq, None));
        let order = ids(&out, &cands);
        let pos1 = order.iter().position(|&i| i == 1).unwrap();
        let pos3 = order.iter().position(|&i| i == 3).unwrap();
        if let Some(pos2) = order.iter().position(|&i| i == 2) {
            assert!(pos1 < pos2 && pos3 < pos2, "packit panes (1,3) before other (2); got {order:?}");
        }
    }

    const COALESCE: u64 = 5;
}
