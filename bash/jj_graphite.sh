#!/bin/bash
#
# Track the current jj bookmark stack in Graphite and submit it.
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
	# `reachable(@, ...)` is the whole connected stack around @ (both directions, so
	# it doesn't matter where @ sits in the stack). Restrict to mutable() so trunk
	# and anything already merged stays out.
	if [ -n "$stop" ]; then
	  revset="ancestors($stop) & mutable()"
	else
	  revset="reachable(@, mutable())"
	fi

	# Bookmarks in range, parents-first (topological order). jj lists bookmarks
	# alphabetically by default, which mis-parents any stack whose branch names
	# don't sort topologically; `--reversed` walks oldest-first so each branch is
	# tracked after its parent.
	branches_raw=$(
	  jj log -r "$revset" --reversed --no-graph \
	    -T 'if(bookmarks, bookmarks ++ "\n")'
	)

	if [ -z "$branches_raw" ]; then
	  echo "jj_graphite: no mutable bookmarks to submit (${stop:-current stack})." >&2
	  exit 0
	fi

	# Track each branch parents-first. `--force` parents it on the nearest already
	# tracked ancestor (the real parent given topological order) and skips the
	# interactive parent picker. Graphite needs one branch per commit, so bail
	# clearly if a commit carries several (they arrive space-separated).
	tip=""
	while IFS= read -r branch; do
	  [ -z "$branch" ] && continue
	  if [[ "$branch" == *" "* ]]; then
	    echo "jj_graphite: a commit has multiple bookmarks ($branch); leave one." >&2
	    exit 1
	  fi
	  HUSKY=0 gt track --force "$branch"
	  tip="$branch"
	done <<< "$branches_raw"

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
