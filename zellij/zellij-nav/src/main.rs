use std::collections::BTreeMap;
use std::time::{SystemTime, UNIX_EPOCH};

use zellij_tile::prelude::*;

mod candidates;
mod frecency;
mod fuzzy;
mod instrument;
mod quickopen;
mod render;

use candidates::Candidate;
use frecency::Frecency;
use fuzzy::{Fuzzy, RankContext, Scored};

struct State {
    own_plugin_id: u32,
    permission_granted: bool,
    pane_manifest: Option<PaneManifest>,
    tab_info: Option<Vec<TabInfo>>,
    query: String,
    candidates: Vec<Candidate>,
    scored: Vec<Scored>,
    selected: usize,
    scroll: usize,
    fuzzy: Fuzzy,
    frecency: Frecency,
    /// The user's current terminal pane — found via `get_focused_pane_info`
    /// when the picker is hidden, or via the suppressed-pane scan when the
    /// picker is in_place and focused. Excluded from picker results.
    last_terminal_focus: Option<PaneId>,
    /// After `activate(target)` we ignore PaneUpdates whose focused pane
    /// doesn't match the target until that landing confirms — zellij fires
    /// transient updates during the focus shift.
    expected_focus: Option<PaneId>,
    /// Set on `load()` when the lock file shows another picker was open
    /// less than 800ms ago — i.e. user did `Ctrl p Ctrl p`. Clears once we
    /// fire `activate_top`.
    alt_tab_pending: bool,
}

impl Default for State {
    fn default() -> Self {
        Self {
            own_plugin_id: 0,
            permission_granted: false,
            pane_manifest: None,
            tab_info: None,
            query: String::new(),
            candidates: Vec::new(),
            scored: Vec::new(),
            selected: 0,
            scroll: 0,
            fuzzy: Fuzzy::new(),
            frecency: Frecency::new(),
            last_terminal_focus: None,
            expected_focus: None,
            alt_tab_pending: false,
        }
    }
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, _config: BTreeMap<String, String>) {
        self.own_plugin_id = get_plugin_ids().plugin_id;

        request_permission(&[
            PermissionType::ReadApplicationState,
            PermissionType::ChangeApplicationState,
        ]);
        subscribe(&[
            EventType::Key,
            EventType::TabUpdate,
            EventType::PaneUpdate,
            EventType::PermissionRequestResult,
        ]);

        self.frecency = Frecency::load_from_disk();
        self.alt_tab_pending = quickopen::detect_and_refresh();
        log_event!(
            "load",
            "plugin_id" => self.own_plugin_id,
            "alt_tab_pending" => self.alt_tab_pending,
        );
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::PermissionRequestResult(_) => {
                self.permission_granted = true;
                false
            }
            Event::TabUpdate(tabs) => {
                self.tab_info = Some(tabs);
                self.recompute();
                true
            }
            Event::PaneUpdate(manifest) => {
                self.pane_manifest = Some(manifest);
                // I've been replaced by another picker — get out of the
                // way so the new instance's `close_self` doesn't unsuppress
                // me into the user's face.
                if self.is_self_suppressed() {
                    log_event!("self_suppressed_exit", "id" => self.own_plugin_id);
                    close_self();
                    return false;
                }
                self.record_focus();
                self.recompute();
                self.maybe_alt_tab();
                true
            }
            Event::Key(key) => {
                log_event!("key", "bare" => key.bare_key, "mods" => key.key_modifiers);
                self.expected_focus = None;
                self.on_key(key)
            }
            _ => false,
        }
    }

    fn pipe(&mut self, _msg: PipeMessage) -> bool {
        false
    }

    fn render(&mut self, rows: usize, cols: usize) {
        self.log_render_snapshot();
        render::render(
            rows,
            cols,
            &self.query,
            &self.candidates,
            &self.scored,
            self.selected,
            self.scroll,
        );
    }
}

impl State {
    fn on_key(&mut self, key: KeyWithModifier) -> bool {
        let ctrl_only = key.has_only_modifiers(&[KeyModifier::Ctrl]);
        let no_mods = key.has_no_modifiers();

        match key.bare_key {
            BareKey::Esc if no_mods => {
                self.cancel();
                false
            }
            BareKey::Enter if no_mods => {
                self.activate();
                true
            }
            BareKey::Up if no_mods => {
                self.move_sel(-1);
                true
            }
            BareKey::Down if no_mods => {
                self.move_sel(1);
                true
            }
            // Note: Ctrl-p is unreachable here — the user's global keybind
            // intercepts it before key events reach the plugin. Quick
            // Alt-Tab (`Ctrl p Ctrl p`) is implemented at load time via the
            // lock file in `quickopen.rs` instead.
            BareKey::Char('k') if ctrl_only => {
                self.move_sel(-1);
                true
            }
            BareKey::Char('j') | BareKey::Char('n') if ctrl_only => {
                self.move_sel(1);
                true
            }
            BareKey::Char('u') if ctrl_only => {
                self.query.clear();
                self.rescore();
                true
            }
            BareKey::Char('p') if ctrl_only => {
                self.activate();
                true
            }
            BareKey::Backspace if no_mods => {
                self.query.pop();
                self.rescore();
                true
            }
            BareKey::Char(c) if no_mods => {
                self.query.push(c);
                self.rescore();
                true
            }
            _ => false,
        }
    }

    fn reset_picker_state(&mut self) {
        self.query.clear();
        self.selected = 0;
        self.scroll = 0;
        self.rescore();
    }

    fn recompute(&mut self) {
        let (Some(manifest), Some(tabs)) = (&self.pane_manifest, &self.tab_info) else {
            return;
        };
        self.candidates = candidates::build(manifest, tabs, self.own_plugin_id);
        self.rescore();
    }

    /// Identify the user's terminal pane and bump its frecency. When
    /// `get_focused_pane_info` reports our plugin (because the picker has
    /// focus), we still need to find what we replaced — with
    /// `in_place true close_replaced_pane false` zellij marks the displaced
    /// pane as suppressed. Scan the manifest for it.
    fn record_focus(&mut self) {
        let Ok((_tab_idx, pane_id)) = get_focused_pane_info() else {
            return;
        };

        let (terminal_id, source) = match pane_id {
            PaneId::Terminal(_) => (pane_id, "direct"),
            PaneId::Plugin(_) => {
                // Picker has focus. The pane it replaced is `is_suppressed`
                // in the manifest — but there can be multiple stale
                // suppressions from previous plugin instances scattered
                // across tabs. We need the one in the *same tab* as our
                // own plugin pane (the picker is `in_place`, so its tab
                // contains the pane it replaced).
                let Some(manifest) = self.pane_manifest.as_ref() else {
                    return;
                };
                let Some(picker_tab) = manifest.panes.iter().find_map(|(tab_pos, panes)| {
                    panes
                        .iter()
                        .any(|p| p.is_plugin && p.id == self.own_plugin_id)
                        .then_some(*tab_pos)
                }) else {
                    log_event!("record_focus_skip", "reason" => "no_own_pane_in_manifest");
                    return;
                };
                let Some(panes) = manifest.panes.get(&picker_tab) else {
                    return;
                };
                let Some(suppressed) = panes
                    .iter()
                    .find(|p| p.is_suppressed && !p.is_plugin)
                    .map(|p| PaneId::Terminal(p.id))
                else {
                    log_event!(
                        "record_focus_skip",
                        "reason" => "no_suppressed_in_picker_tab",
                        "picker_tab" => picker_tab,
                    );
                    return;
                };
                (suppressed, "suppressed_in_picker_tab")
            }
        };

        if let Some(expected) = self.expected_focus {
            if terminal_id != expected {
                log_event!("ignore_transient", "expected" => expected, "found" => terminal_id);
                return;
            }
            self.expected_focus = None;
        }

        let changed = self.last_terminal_focus != Some(terminal_id);
        self.last_terminal_focus = Some(terminal_id);
        self.frecency.bump(terminal_id, now_secs());
        log_event!(
            "record_focus",
            "ltf" => terminal_id,
            "source" => source,
            "changed" => changed,
        );
    }

    fn rescore(&mut self) {
        let ctx = RankContext {
            query: &self.query,
            frecency: &self.frecency,
            current_pane: self.last_terminal_focus,
            now: now_secs(),
        };
        self.scored = self.fuzzy.rank(&self.candidates, &ctx);
        self.selected = self.selected.min(self.scored.len().saturating_sub(1));
        self.clamp_scroll();
    }

    fn move_sel(&mut self, delta: i32) {
        if self.scored.is_empty() {
            return;
        }
        let n = self.scored.len() as i32;
        let next = (self.selected as i32 + delta).rem_euclid(n);
        self.selected = next as usize;
        self.clamp_scroll();
    }

    fn clamp_scroll(&mut self) {
        let margin = 2;
        if self.selected < self.scroll + margin {
            self.scroll = self.selected.saturating_sub(margin);
        }
        if self.selected > self.scroll + 20 {
            self.scroll = self.selected.saturating_sub(20);
        }
    }

    /// True iff our own plugin pane is marked is_suppressed in the manifest.
    /// Means another instance has replaced us; we should bail.
    fn is_self_suppressed(&self) -> bool {
        let Some(manifest) = self.pane_manifest.as_ref() else {
            return false;
        };
        manifest
            .panes
            .values()
            .flatten()
            .any(|p| p.is_plugin && p.id == self.own_plugin_id && p.is_suppressed)
    }

    /// True iff some *other* suppressed plugin pane sits in our tab. That
    /// would be a previous picker instance that hasn't self-closed yet.
    /// Caveat: any unrelated suppressed plugin pane in the same tab also
    /// trips this — fine in practice, since the picker is normally invoked
    /// in tabs that don't already host other suppressed plugins.
    fn has_orphan_picker_in_tab(&self) -> bool {
        let Some(manifest) = self.pane_manifest.as_ref() else {
            return false;
        };
        let Some(my_tab) = manifest.panes.iter().find_map(|(tab, panes)| {
            panes
                .iter()
                .any(|p| p.is_plugin && p.id == self.own_plugin_id)
                .then_some(*tab)
        }) else {
            return false;
        };
        let Some(panes) = manifest.panes.get(&my_tab) else {
            return false;
        };
        panes
            .iter()
            .any(|p| p.is_plugin && p.id != self.own_plugin_id && p.is_suppressed)
    }

    /// If load() flagged us as a `Ctrl p Ctrl p` replacement and the previous
    /// picker has finished self-closing, activate scored[0]. If the orphan is
    /// still around, do nothing — its self-close will trigger a fresh
    /// PaneUpdate and we'll re-enter here.
    fn maybe_alt_tab(&mut self) {
        if !self.alt_tab_pending {
            return;
        }
        if self.has_orphan_picker_in_tab() {
            log_event!("alt_tab_wait_for_orphan", "id" => self.own_plugin_id);
            return;
        }
        if self.scored.is_empty() || self.last_terminal_focus.is_none() {
            return;
        }
        log_event!("alt_tab_fire", "scored_len" => self.scored.len());
        self.alt_tab_pending = false;
        self.activate_top();
    }

    /// Quick Alt-Tab: ignore wherever the user's selection has wandered and
    /// activate scored[0]. With current-pane filtering, scored[0] is the
    /// most-recently-visited *other* pane.
    fn activate_top(&mut self) {
        self.selected = 0;
        self.activate();
    }

    fn activate(&mut self) {
        let Some(item) = self.scored.get(self.selected) else {
            return;
        };
        let cand = &self.candidates[item.candidate_idx];
        let id = cand.id;
        let prev = self.last_terminal_focus;

        log_event!(
            "activate",
            "target" => id,
            "prev_ltf" => prev,
            "combined" => item.combined,
        );

        self.frecency.bump(id, now_secs());
        if let Err(e) = self.frecency.save_to_disk() {
            log_event!("frecency_save_failed", "err" => e.to_string());
        }
        // Treat the activate target as the new current pane immediately.
        // Otherwise the rescore in close() runs with the stale pre-activate
        // ltf, doesn't filter the target, and renders the target at rank=0
        // because we just bumped its frecency — the user sees their
        // just-selected pane at the top of the list as the picker closes.
        self.last_terminal_focus = Some(id);
        self.expected_focus = Some(id);

        // Order matters: close_self FIRST while the picker is still the
        // active pane. zellij's tab.close_pane checks suppressed_panes for
        // the picker as the key and runs replace_pane_with_suppressed_pane,
        // restoring the displaced terminal in the picker's slot. If we
        // shift focus first, the picker is no longer the active pane and
        // the close logic can't find it in tiled_panes — leaving a zombie
        // tile behind. Observed once with plugin_48 stuck in tab "review in
        // context"; see zellij.log "failed to remove unknown pane with ID".
        self.close();
        focus_pane_with_id(id, false, false);
    }

    fn close(&mut self) {
        self.reset_picker_state();
        // Clear lock so `Ctrl p Enter Ctrl p` opens fresh instead of
        // alt-tabbing on the second press.
        quickopen::clear();
        close_self();
    }

    fn cancel(&mut self) {
        self.reset_picker_state();
        // Same reasoning: `Ctrl p Esc Ctrl p` should open fresh.
        quickopen::clear();
        close_self();
    }

    /// One log line per top-5 scored candidate so the ranking decision is
    /// reviewable by tailing /tmp/zellij_nav.log.
    fn log_render_snapshot(&self) {
        let now = now_secs();
        log_event!(
            "render",
            "q" => self.query,
            "sel" => self.selected,
            "scroll" => self.scroll,
            "candidates" => self.candidates.len(),
            "scored" => self.scored.len(),
            "current" => self.last_terminal_focus,
        );
        for (rank, s) in self.scored.iter().take(5).enumerate() {
            let cand = &self.candidates[s.candidate_idx];
            let frecency_score = self.frecency.score(cand.id, now);
            let age = self
                .frecency
                .last_access(cand.id)
                .map(|t| now.saturating_sub(t))
                .map(|secs| {
                    if secs < 60 {
                        format!("{secs}s")
                    } else if secs < 3600 {
                        format!("{}m", secs / 60)
                    } else if secs < 86400 {
                        format!("{}h", secs / 3600)
                    } else {
                        format!("{}d", secs / 86400)
                    }
                })
                .unwrap_or_else(|| "never".to_string());
            log_event!(
                "candidate",
                "rank" => rank,
                "id" => cand.id,
                "tab" => cand.tab_name,
                "combined" => s.combined,
                "frecency" => frecency_score,
                "last_access" => age,
            );
        }
    }
}

fn now_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}
