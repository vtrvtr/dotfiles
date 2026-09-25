#!/bin/bash
# Publish a linear jj bookmark stack with GitHub's gh-stack extension.
# Source this file, then run: jjgh [<stop-at>] [gh-stack-link-args...]
# With no stop, include the connected stack around @.
# jj owns local history and pushes. gh stack link owns the remote stack representation.

jjgh() (
	set -euo pipefail

	stop=""
	if [ "$#" -gt 0 ] && [[ "$1" != -* ]]; then
		stop="$1"
		shift
	fi
	remote="origin"
	args=("$@")
	link_args=()
	for ((i = 0; i < ${#args[@]}; i++)); do
		arg=${args[$i]}
		case "$arg" in
		--base|--base=*)
			echo "jjgh: $arg overrides the jj-derived trunk and is not supported." >&2
			exit 1 ;;
		--remote)
			i=$((i + 1))
			if [ "$i" -ge "${#args[@]}" ] || [ -z "${args[$i]}" ]; then
				echo "jjgh: --remote requires a value." >&2
				exit 1
			fi
			remote=${args[$i]} ;;
		--remote=*)
			remote=${arg#--remote=}
			if [ -z "$remote" ]; then
				echo "jjgh: --remote requires a value." >&2
				exit 1
			fi ;;
		*) link_args+=("$arg") ;;
		esac
	done

	trunk=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	trunk_commit=$(git rev-parse "refs/heads/$trunk")
	if [ -n "$stop" ]; then
		revset="ancestors($stop) ~ ancestors($trunk_commit)"
	else
		revset="reachable(@, $trunk_commit..)"
	fi
	branches_raw=$(jj log -r "$revset" --reversed --no-graph \
		-T 'if(local_bookmarks, local_bookmarks.map(|b| b.name()).join(" ") ++ "\n")')
	if [ -z "$branches_raw" ]; then
		echo "jjgh: no bookmarks to submit (${stop:-current stack})."
		exit 0
	fi

	mapfile -t branches <<< "$branches_raw"
	parent="$trunk"
	for branch in "${branches[@]}"; do
		if [[ "$branch" == *" "* ]]; then
			echo "jjgh: multiple bookmarks on one commit ($branch). Leave one." >&2
			exit 1
		fi
		if ! git merge-base --is-ancestor "$parent" "$branch"; then
			echo "jjgh: $parent -> $branch is not a linear stack. Select a stop-at revision." >&2
			exit 1
		fi
		printf 'jjgh: %s -> %s\n' "$parent" "$branch"
		parent="$branch"
	done

	# jj rewrites history, so push with jj's lease check. gh stack link only fast-forwards.
	jj git push --remote "$remote" "${branches[@]/#/--bookmark=exact:}"
	gh stack link --base "$trunk" --remote "$remote" "${branches[@]}" "${link_args[@]}"
)
