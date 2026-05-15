# devbox `update` is a no-op for github:/flake refs: the resolved commit is
# baked into the generated flake.lock `original`, so `nix flake update` has
# nothing to advance and devbox never re-checks upstream HEAD. Stripping the
# lock entries and reinstalling forces a fresh resolve to the latest commit
# (same effect as `devbox global rm` + `add`, without touching devbox.json).
#
# Usage:
#   devbox-flake-update           # refresh every flakeref in the global lock
#   devbox-flake-update claude    # only refs whose key contains "claude"
devbox-flake-update() {
  local filter="${1:-}" gp lock removed
  gp="$(devbox global path)" || { echo "devbox global path failed" >&2; return 1; }
  lock="$gp/devbox.lock"
  [ -f "$lock" ] || { echo "no lockfile at $lock" >&2; return 1; }

  cp -- "$lock" "$lock.bak" || return 1

  # Drop matching flakeref entries, emit "<ref>\t<oldrev>" per line.
  removed="$(FILTER="$filter" python3 - "$lock" <<'PY'
import json, os, re, sys
flt = os.environ.get("FILTER", "")
is_flakeref = re.compile(r"^(github|gitlab|sourcehut|git|path|flake|tarball|file)[:+]").match
data = json.load(open(sys.argv[1]))
pkgs = data.get("packages", {})
hits = [k for k in pkgs if is_flakeref(k) and (flt in k if flt else True)]
lines = []
for k in hits:
    resolved = pkgs[k].get("resolved", "")
    rev = resolved.split("/")[-1].split("?")[0] if resolved else "?"
    lines.append(f"{k}\t{rev}")
    del pkgs[k]
with open(sys.argv[1], "w") as f:
    json.dump(data, f, indent="  ")
    f.write("\n")
print("\n".join(lines))
PY
)" || { mv -- "$lock.bak" "$lock"; echo "lock edit failed; restored from backup" >&2; return 1; }

  if [ -z "$removed" ]; then
    echo "no flakerefs matched${filter:+ filter '$filter'}; nothing to do"
    rm -f -- "$lock.bak"
    return 0
  fi

  echo "refreshing:"
  printf '%s\n' "$removed" | cut -f1 | sed 's/^/  /'

  if ! devbox global install; then
    echo "install failed; lock backup kept at $lock.bak" >&2
    return 1
  fi

  echo "result (old -> new):"
  OLD="$removed" python3 - "$lock" <<'PY'
import json, os, sys
data = json.load(open(sys.argv[1]))
pkgs = data.get("packages", {})
for line in os.environ.get("OLD", "").splitlines():
    if not line.strip():
        continue
    k, old = line.split("\t")
    resolved = pkgs.get(k, {}).get("resolved", "")
    new = resolved.split("/")[-1].split("?")[0] if resolved else "?"
    note = "  (unchanged, already latest)" if old == new else ""
    print(f"  {k}: {old[:12]} -> {new[:12]}{note}")
PY
  rm -f -- "$lock.bak"
}
