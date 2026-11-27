//! "Quick Alt-Tab" detection: was a previous picker open less than
//! `DOUBLE_PRESS_WINDOW_MS` ago?
//!
//! Why a lock file:
//!
//! The user's keybind is `LaunchOrFocusPlugin` with `in_place=true`. With
//! `in_place=true` AND `pane_id_to_replace=Some(...)`, zellij's screen
//! handler unconditionally LAUNCHES a new plugin pane to replace the
//! focused one — it never checks for an existing instance of the same URL.
//! See `zellij-server/src/screen.rs` LaunchOrFocusPlugin handler around
//! line 8210.
//!
//! So on the second `Ctrl p`, a fresh plugin instance (B) is created and
//! the previous picker (A) becomes a suppressed orphan. B's `on_key`
//! handler is unreachable for Ctrl-p because the keybind fires before keys
//! reach the plugin. The new instance has no in-memory link to the old
//! one — the lock file is the only handoff channel.
//!
//! The manifest also signals replacement (a suppressed plugin pane in B's
//! tab), but that's a *tighter* signal: it requires waiting for the
//! manifest to update before deciding. The lock file fires immediately on
//! `load()`. We use the manifest signal only for the *wait-until-orphan-is-
//! gone* phase before actually firing alt-tab.

use std::time::{SystemTime, UNIX_EPOCH};

const LOCK: &str = "/tmp/zellij_nav_recent_open.ts";

/// Two Ctrl-p presses within this window count as "quick alt-tab".
/// Longer than typical key-bounce; shorter than a deliberate
/// "Ctrl-p, glance at picker, give up, Ctrl-p again" gap.
const DOUBLE_PRESS_WINDOW_MS: u128 = 800;

fn now_millis() -> u128 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis())
        .unwrap_or(0)
}

/// Read the lock, return whether the previous open was within the window,
/// and refresh the lock with the current timestamp. Call exactly once per
/// `load()`.
pub fn detect_and_refresh() -> bool {
    let now = now_millis();
    let is_recent = std::fs::read_to_string(LOCK)
        .ok()
        .and_then(|s| s.trim().parse::<u128>().ok())
        .map(|prev| now.saturating_sub(prev) < DOUBLE_PRESS_WINDOW_MS)
        .unwrap_or(false);
    let _ = std::fs::write(LOCK, now.to_string());
    is_recent
}

/// Clear the lock so a subsequent `Ctrl p` opens fresh — used on
/// activate / cancel so `Ctrl p Enter Ctrl p` and `Ctrl p Esc Ctrl p`
/// don't trip the alt-tab path.
pub fn clear() {
    let _ = std::fs::remove_file(LOCK);
}
