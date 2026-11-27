//! Append-only structured log for the picker plugin.
//!
//! Writes to `/tmp/zellij_nav.log` inside the WASI sandbox, which maps to
//! `/tmp/zellij-<UID>/zellij_nav.log` on the host. Stable across `close_self`
//! cycles — every picker instance appends to the same file so
//! `tail -f /tmp/zellij-$(id -u)/zellij_nav.log` from a side terminal stays
//! useful between picker invocations.
//!
//! tracing-subscriber on wasm32-wasip1 was failing to emit anything (most
//! likely a missing time backend in the default fmt layer). A 30-line direct
//! writer is fine for our volume and gives us a single grep-friendly format.

use std::time::{SystemTime, UNIX_EPOCH};

// `/tmp` maps to `/tmp/zellij-<UID>/` on the host — shared across plugin
// instances, so every close_self/relaunch cycle appends to the same file
// and `tail -f /tmp/zellij-$(id -u)/zellij_nav.log` from a side terminal
// keeps working across picker invocations.
const LOG_PATH: &str = "/tmp/zellij_nav.log";
/// Rotated segment. When the active log reaches the cap it's moved here and
/// a fresh active log is started, so history survives one rotation.
const LOG_BACKUP_PATH: &str = "/tmp/zellij_nav.log.1";

/// Cap on the active log segment. Each `log` call reads the active file into
/// the plugin's WASM linear memory (WASI append is unreliable in this
/// sandbox), so an unbounded file eventually demands an allocation larger
/// than the memory-growth limit zellij imposes on plugins — the host then
/// kills the plugin with "growth operation limited". Rotating at this size
/// bounds both the allocation and the amortized read/write cost, while the
/// backup segment keeps roughly this much extra history.
const MAX_LOG_BYTES: usize = 256 * 1024;

/// Append a log line. Format: `Tsec.usec [tag] body`. The `tag` is the
/// callsite identifier (e.g. `render`, `activate`, `key`); `body` is whatever
/// the caller wants — usually `key1=value1 key2=value2 …` for grep-friendly
/// structured pairs.
///
/// Silently no-ops if the log file can't be opened — instrumentation must
/// never break the picker.
pub fn log(tag: &str, body: &str) {
    // Read-modify-write — wasi32-wasip1's OpenOptions::append is unreliable in
    // this sandbox (silently writes nothing), but std::fs::read + write works
    // the same as frecency.bin.
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| (d.as_secs(), d.subsec_millis()))
        .unwrap_or((0, 0));
    let line = format!("{}.{:03} [{}] {}\n", ts.0, ts.1, tag, body);
    let mut active = std::fs::read(LOG_PATH).unwrap_or_default();
    // Rotate once the active segment would exceed the cap: move it aside and
    // start fresh, so the read+write allocation stays bounded by MAX_LOG_BYTES
    // and the active segment shrinks back to near-empty after each rotation.
    if active.len() + line.len() > MAX_LOG_BYTES {
        let _ = std::fs::rename(LOG_PATH, LOG_BACKUP_PATH);
        active.clear();
    }
    active.extend_from_slice(line.as_bytes());
    let _ = std::fs::write(LOG_PATH, active);
}

/// Convenience: `kvfmt!("k1" => v1, "k2" => v2)` → `k1=v1 k2=v2`.
#[macro_export]
macro_rules! log_event {
    ($tag:expr, $($key:expr => $val:expr),+ $(,)?) => {{
        let body = [$( format!("{}={:?}", $key, $val) ),+].join(" ");
        $crate::instrument::log($tag, &body);
    }};
}
