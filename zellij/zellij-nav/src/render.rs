use zellij_tile::prelude::{print_text_with_coordinates, Text};

use crate::candidates::Candidate;
use crate::fuzzy::Scored;

// zellij-tile Text "color slots": 0..=3 are the four theme colors,
// 4 = dim modifier, 5 = unbold modifier, 6 = error, 7 = success.
const C_BASE: usize = 0;
const C_TAB: usize = 1; // tab-name highlight
const C_ACCENT: usize = 2; // primary accent (prompt, cursor, glyph)
const C_MATCH: usize = 3; // fuzzy-match highlight
const C_DIM: usize = 4; // dim modifier for chrome

const GLYPH_PROMPT: char = '\u{f002}'; // nf-fa-search
const GLYPH_CURSOR: char = '\u{f432}'; // nf-cod-triangle_right
const GLYPH_PANE: char = '\u{f489}'; // nf-oct-terminal
const GLYPH_NO_MATCH: char = '\u{f421}'; // nf-oct-no_entry

const MAX_W: usize = 100;
const MAX_H: usize = 30;

pub struct Frame {
    pub origin_x: usize,
    pub origin_y: usize,
    pub width: usize,
    pub height: usize,
    pub visible_rows: usize,
}

impl Frame {
    pub fn fit(rows: usize, cols: usize) -> Self {
        let width = cols.saturating_sub(4).clamp(20, MAX_W);
        let height = rows.saturating_sub(4).clamp(6, MAX_H);
        let origin_x = cols.saturating_sub(width) / 2;
        let origin_y = rows.saturating_sub(height) / 2;
        let visible_rows = height.saturating_sub(4);
        Self { origin_x, origin_y, width, height, visible_rows }
    }
}

pub fn render(
    rows: usize,
    cols: usize,
    query: &str,
    candidates: &[Candidate],
    scored: &[Scored],
    selected: usize,
    scroll: usize,
) {
    if cols < 32 || rows < 6 {
        render_minimal(rows, cols, query, candidates, scored, selected);
        return;
    }

    let frame = Frame::fit(rows, cols);
    let inner_w = frame.width.saturating_sub(2);

    draw_border(&frame);

    // Prompt line.
    let count_label = format!("{} / {}", scored.len(), candidates.len());
    let count_w = count_label.chars().count();
    let prompt_avail = inner_w.saturating_sub(count_w + 3);
    let typed = trim_end_with_ellipsis(query, prompt_avail);
    let prompt = format!(
        "{} {:<query_w$} {}",
        GLYPH_PROMPT,
        typed,
        count_label,
        query_w = prompt_avail,
    );
    let prompt_text = Text::new(&prompt)
        .color_range(C_ACCENT, 0..=0)
        .color_range(C_DIM, prompt.chars().count().saturating_sub(count_w)..);
    print_text_with_coordinates(
        prompt_text,
        frame.origin_x + 1,
        frame.origin_y + 1,
        Some(inner_w),
        Some(1),
    );

    // Separator.
    let sep: String = "─".repeat(inner_w);
    print_text_with_coordinates(
        Text::new(&sep).color_range(C_DIM, ..),
        frame.origin_x + 1,
        frame.origin_y + 2,
        Some(inner_w),
        Some(1),
    );

    // Body.
    if scored.is_empty() {
        let msg = format!("{}  no matches", GLYPH_NO_MATCH);
        let x = frame.origin_x + (frame.width.saturating_sub(msg.chars().count())) / 2;
        let y = frame.origin_y + frame.height / 2;
        print_text_with_coordinates(
            Text::new(&msg).color_range(C_DIM, ..),
            x,
            y,
            Some(msg.chars().count()),
            Some(1),
        );
        return;
    }

    let visible = frame.visible_rows;
    let row_y = frame.origin_y + 3;
    for (offset, scored_item) in scored.iter().skip(scroll).take(visible).enumerate() {
        let abs_idx = scroll + offset;
        let cand = &candidates[scored_item.candidate_idx];
        let is_selected = abs_idx == selected;

        let mut text = build_row(cand, scored_item, is_selected, inner_w);
        if is_selected {
            text = text.selected();
        }
        print_text_with_coordinates(
            text,
            frame.origin_x + 1,
            row_y + offset,
            Some(inner_w),
            Some(1),
        );
    }
}

fn build_row(cand: &Candidate, scored: &Scored, selected: bool, inner_w: usize) -> Text {
    let cursor = if selected { GLYPH_CURSOR } else { ' ' };

    // "<cursor> <glyph> <label>" where label is already "<tab>  <title>  <cmd>".
    let prefix = format!("{cursor} {GLYPH_PANE} ");
    let prefix_chars = prefix.chars().count();
    let body_avail = inner_w.saturating_sub(prefix_chars);
    let body = truncate_middle(&cand.label, body_avail);
    let line = format!("{prefix}{body}");

    // Highlight the tab-name span at the start of the body so it's visually
    // distinct from the title/cmd.
    let tab_name_chars = cand.tab_name.chars().count();
    let tab_start = prefix_chars;
    let tab_end = (tab_start + tab_name_chars).min(line.chars().count());

    let mut text = Text::new(&line)
        .color_range(C_BASE, ..)
        .color_range(C_ACCENT, 2..=2) // glyph
        .color_range(C_TAB, tab_start..tab_end);

    // Match indices nucleo gave us are into `search_text`, which is the same
    // content as `label` with single instead of double spaces. Close enough
    // that highlighting by index gets very close to the right characters; a
    // perfect highlight would need to recompute against the rendered label.
    let rendered_body_start = prefix_chars;
    for &idx in &scored.match_indices {
        let shifted = rendered_body_start + idx as usize;
        if shifted < line.chars().count() {
            text = text.color_range(C_MATCH, shifted..=shifted);
        }
    }

    if selected {
        text = text.color_range(C_ACCENT, 0..=0);
    }
    text
}

fn draw_border(frame: &Frame) {
    let w = frame.width;
    let inner = w.saturating_sub(2);
    let title = " Panes 2 ";
    let title_chars = title.chars().count();
    let dashes_total = inner.saturating_sub(title_chars + 1);
    let left = dashes_total / 2;
    let right = dashes_total - left;
    let top = format!("╭{}{}{}╮", "─".repeat(left), title, "─".repeat(right + 1));
    let bottom = format!("╰{}╯", "─".repeat(inner));
    let blank_side = format!("│{:width$}│", "", width = inner);

    let top_text = Text::new(&top)
        .color_range(C_DIM, ..)
        .color_range(C_ACCENT, (left + 1)..(left + 1 + title_chars));
    print_text_with_coordinates(top_text, frame.origin_x, frame.origin_y, Some(w), Some(1));

    for row in 1..frame.height.saturating_sub(1) {
        print_text_with_coordinates(
            Text::new(&blank_side).color_range(C_DIM, ..),
            frame.origin_x,
            frame.origin_y + row,
            Some(w),
            Some(1),
        );
    }

    print_text_with_coordinates(
        Text::new(&bottom).color_range(C_DIM, ..),
        frame.origin_x,
        frame.origin_y + frame.height.saturating_sub(1),
        Some(w),
        Some(1),
    );
}

fn render_minimal(
    rows: usize,
    cols: usize,
    query: &str,
    candidates: &[Candidate],
    scored: &[Scored],
    selected: usize,
) {
    let line1 = format!(
        "{} {}  ({}/{})",
        GLYPH_PROMPT,
        truncate_middle(query, cols.saturating_sub(12)),
        scored.len(),
        candidates.len(),
    );
    print_text_with_coordinates(
        Text::new(&line1).color_range(C_ACCENT, 0..=0),
        0,
        0,
        Some(cols),
        Some(1),
    );

    let body_rows = rows.saturating_sub(1);
    for (i, item) in scored.iter().take(body_rows).enumerate() {
        let cand = &candidates[item.candidate_idx];
        let cursor = if i == selected { GLYPH_CURSOR } else { ' ' };
        let line = format!("{cursor} {}", truncate_middle(&cand.label, cols.saturating_sub(3)));
        let mut t = Text::new(&line);
        if i == selected {
            t = t.selected();
        }
        print_text_with_coordinates(t, 0, 1 + i, Some(cols), Some(1));
    }
}

fn trim_end_with_ellipsis(s: &str, max: usize) -> String {
    let n = s.chars().count();
    if n <= max {
        return s.to_string();
    }
    if max <= 1 {
        return "…".to_string();
    }
    let take = max - 1;
    let mut out: String = s.chars().take(take).collect();
    out.push('…');
    out
}

fn truncate_middle(s: &str, max: usize) -> String {
    let n = s.chars().count();
    if n <= max {
        return s.to_string();
    }
    if max <= 1 {
        return "…".to_string();
    }
    let keep = max - 1;
    let head = keep / 2;
    let tail = keep - head;
    let head_str: String = s.chars().take(head).collect();
    let tail_str: String = s.chars().skip(n - tail).collect();
    format!("{head_str}…{tail_str}")
}
