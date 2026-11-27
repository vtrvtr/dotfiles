use zellij_tile::prelude::{PaneId, PaneInfo, PaneManifest, TabInfo};

/// A focusable terminal pane. Tabs aren't separate candidates — searching a
/// tab name surfaces every pane in it via `search_text` (the haystack starts
/// with `tab_name`, and nucleo's `prefer_prefix` is on).
#[derive(Debug, Clone)]
pub struct Candidate {
    pub id: PaneId,           // always PaneId::Terminal — plugins are filtered out
    pub tab_name: String,
    pub label: String,
    pub search_text: String,
}

pub fn build(
    manifest: &PaneManifest,
    tabs: &[TabInfo],
    _own_plugin_id: u32,
) -> Vec<Candidate> {
    let mut out: Vec<Candidate> = Vec::with_capacity(16);

    let mut tab_positions: Vec<&usize> = manifest.panes.keys().collect();
    tab_positions.sort_unstable();
    for &tab_pos in tab_positions {
        let tab_name = tabs
            .iter()
            .find(|t| t.position == tab_pos)
            .map(|t| t.name.as_str())
            .unwrap_or("?");
        let panes = &manifest.panes[&tab_pos];
        let mut sorted: Vec<&PaneInfo> = panes.iter().filter(|p| !is_skippable(p)).collect();
        sorted.sort_by_key(|p| (p.pane_y, p.pane_x));

        for pane in sorted {
            let cmd = pane.terminal_command.clone();
            let title = pane.title.clone();
            let label = match cmd.as_deref() {
                Some(c) if !c.is_empty() => format!("{tab_name}  {title}  {c}"),
                _ => format!("{tab_name}  {title}"),
            };
            let search_text = match cmd.as_deref() {
                Some(c) if !c.is_empty() => format!("{tab_name} {title} {c}"),
                _ => format!("{tab_name} {title}"),
            };
            out.push(Candidate {
                id: PaneId::Terminal(pane.id),
                tab_name: tab_name.to_string(),
                label,
                search_text,
            });
        }
    }

    out
}

fn is_skippable(pane: &PaneInfo) -> bool {
    if !pane.is_selectable {
        return true;
    }
    pane.is_plugin
}
