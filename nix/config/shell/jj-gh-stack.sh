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

	repo_slug() {
		local url=${1#*://}
		url=${url#*@}
		[[ "$1" == *://* ]] || url=${url/:/\/}
		url=${url%/}
		echo "${url%.git}"
	}

	# Git proxies (insteadOf) are not API hosts. Map back to a gh host.
	remote_url=$(git remote get-url "$remote")
	GH_REPO=$(repo_slug "$remote_url")
	while read -r key original; do
		base=${key#url.}
		base=${base%.insteadof}
		[[ "$remote_url" == "$base"* ]] || continue
		candidate=$(repo_slug "$original${remote_url#"$base"}")
		if gh auth token --hostname "${candidate%%/*}" >/dev/null 2>&1; then
			GH_REPO=$candidate
			break
		fi
	done < <(git config --get-regexp '^url\..*\.insteadof$')
	export GH_REPO

	trunk=$(gh repo view "$GH_REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')
	# PRs target the remote trunk, which a stale local trunk may not contain.
	trunk_commit=$(jj log -r "$trunk@$remote" --no-graph -T commit_id)
	if [ -n "$stop" ]; then
		revset="ancestors($stop) ~ ancestors($trunk_commit)"
	else
		revset="reachable(@, $trunk_commit..)"
	fi
	# Untracked remote bookmarks are others' branches: stack on them, never push them.
	stack_raw=$(jj log -r "$revset" --reversed --no-graph -T 'commit_id ++ " " ++ separate(" ",
		local_bookmarks.map(|b| b.name()),
		remote_bookmarks.filter(|b| b.remote() == "'"$remote"'" && !b.tracked()).map(|b| b.name() ++ "@" ++ b.remote())) ++ "\n"' |
		awk 'NF > 1')
	if [ -z "$stack_raw" ]; then
		echo "jjgh: no bookmarks to submit (${stop:-current stack})."
		exit 0
	fi

	mapfile -t stack <<< "$stack_raw"
	parent="$trunk@$remote"
	parent_commit="$trunk_commit"
	owned=()
	links=()
	for entry in "${stack[@]}"; do
		read -r commit branch <<< "$entry"
		if [[ "$branch" == *" "* ]]; then
			echo "jjgh: multiple bookmarks on one commit ($branch). Leave one." >&2
			exit 1
		fi
		if ! git merge-base --is-ancestor "$parent_commit" "$commit"; then
			echo "jjgh: $parent -> $branch is not a linear stack. Select a stop-at revision." >&2
			exit 1
		fi
		if [[ "$branch" == *"@$remote" ]]; then
			url=$(gh pr list --head "${branch%"@$remote"}" --state open --json url --jq '.[0].url // empty')
			if [ -z "$url" ]; then
				echo "jjgh: $branch is not yours and has no open PR to stack on." >&2
				exit 1
			fi
			links+=("$url")
		else
			owned+=("$branch")
			links+=("$branch")
		fi
		printf 'jjgh: %s -> %s\n' "$parent" "$branch"
		parent="$branch"
		parent_commit="$commit"
	done

	# jj rewrites history, so push with jj's lease check. gh stack link only fast-forwards.
	if [ "${#owned[@]}" -gt 0 ]; then
		jj git push --remote "$remote" "${owned[@]/#/--bookmark=exact:}"
	fi
	gh stack link --base "$trunk" --remote "$remote" "${links[@]}" "${link_args[@]}"
)
