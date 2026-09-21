#!/bin/bash
#
# Rebuild Graphite tracking from the current jj bookmark stack and submit it.
#
# Usage: jj_graphite.sh [<stop-at>] [gt-submit-args...]
#   <stop-at>  bookmark or revision to stop the stack at, inclusive
#              (default: @, the working copy). Only branches from trunk up to
#              and including this point are tracked and submitted.
#   Any remaining args are forwarded to `gt submit` (e.g. --draft).
#
# Examples:
#   jj_graphite.sh                          # whole stack up to @, ready PRs
#   jj_graphite.sh --draft                  # whole stack, draft PRs
#   jj_graphite.sh nucleus-packit-widget    # stop at widget
#   jj_graphite.sh nucleus-packit-widget --draft

jjg() (
	# Subshell so `set -e`/`exit`/option changes stay contained and a failure
	# never kills the interactive shell that sourced this; jj/gt repo operations
	# still take effect outside the subshell.
	set -euo pipefail

	# Optional first non-flag arg: a bookmark/revision to stop the stack at,
	# inclusive. With no stop, submit the whole stack that contains @.
	stop=""
	if [ "$#" -gt 0 ] && [[ "$1" != -* ]]; then
	  stop="$1"
	  shift
	fi

	# `ancestors(<stop>)` is the downstack from trunk up to <stop>; with no stop,
	# start at the current bookmark's commit. `mutable()` excludes landed history
	# and bookmarks on shared ancestors from this stack.
	if [ -n "$stop" ]; then
	  revset="ancestors($stop) & mutable()"
	else
	  current_bookmark=$(jj log -r @- --no-graph -T 'if(bookmarks, bookmarks, "")')
	  if [[ "$current_bookmark" == *" "* ]]; then
	    echo "jj_graphite: current commit has multiple bookmarks ($current_bookmark); leave one." >&2
	    exit 1
	  fi
	  revset="ancestors($current_bookmark) & mutable()"
	fi

	# Bookmarks in range, parents-first (topological order).
	branches_raw=$(
	  jj log -r "$revset" --reversed --no-graph \
	    -T 'if(bookmarks, bookmarks ++ "\n")'
	)

	if [ -z "$branches_raw" ]; then
	  echo "jj_graphite: no mutable bookmarks to submit (${stop:-current stack})." >&2
	  exit 0
	fi

	# Graphite needs one branch per commit, so bail clearly if a commit carries
	# several bookmarks (they arrive space-separated).
	mapfile -t branches <<< "$branches_raw"
	tip=""
	for branch in "${branches[@]}"; do
	  [ -z "$branch" ] && continue
	  if [[ "$branch" == *" "* ]]; then
	    echo "jj_graphite: a commit has multiple bookmarks ($branch); leave one." >&2
	    exit 1
	  fi
	  tip="$branch"
	done

	# Make jj authoritative without deleting its Git bookmarks. Clear Graphite's
	# stack metadata and stale merged/closed PR cache entries for these branches.
	for branch in "${branches[@]}"; do
	  [ -n "$branch" ] && HUSKY=0 gt untrack --force "$branch"
	done
	python3 - "$(git rev-parse --git-path .graphite_pr_info)" "${branches[@]}" <<'PY'
import json
import os
import sys

path, *branches = sys.argv[1:]
if not os.path.exists(path):
    raise SystemExit(0)
with open(path, encoding="utf-8") as file:
    data = json.load(file)
branch_set = set(branches)
merged = {"CLOSED", "MERGED"}
data["prInfos"] = [
    pr for pr in data.get("prInfos", [])
    if not (pr.get("headRefName") in branch_set and pr.get("state") in merged)
]
active_prs = {pr.get("prNumber") for pr in data["prInfos"]}
data["mergeabilityStatuses"] = [
    status for status in data.get("mergeabilityStatuses", [])
    if status.get("prNumber") in active_prs
]
temporary_path = f"{path}.jjg"
with open(temporary_path, "w", encoding="utf-8") as file:
    json.dump(data, file)
os.replace(temporary_path, path)
PY

	# Re-track parents-first. The first bookmark is the trunk child; each later
	# bookmark is parented on its immediate jj ancestor rather than Graphite's
	# prior metadata.
	parent=""
	for branch in "${branches[@]}"; do
	  [ -z "$branch" ] && continue
	  if [ -n "$parent" ]; then
	    HUSKY=0 gt track --parent "$parent" "$branch"
	  else
	    HUSKY=0 gt track --force "$branch"
	  fi
	  parent="$branch"
	done

	# Park pending working-copy changes off the tip so checkout/submit act on the
	# bookmarked commits rather than a dirty working copy.
	if [ "$(jj diff --summary | wc -l)" -gt 1 ]; then
	  jj new
	fi

	HUSKY=0 gt checkout "$tip"

	repo_root=$(git rev-parse --show-toplevel)
	if [ -f "$repo_root/.husky/pre-commit" ]; then
	  ( cd "$repo_root" && sh .husky/pre-commit )
	fi

	# `--no-stack` submits only trunk..<tip> (skips anything above it), so the stack
	# stops exactly at <stop>. `--no-interactive`/`--no-edit` keep it from blocking
	# on a TTY; PR fields come from the commit messages.
	gt submit --no-interactive --no-edit --no-stack "$@"
)
