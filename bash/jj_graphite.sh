#!/bin/bash
# Mirror a linear jj bookmark stack into Graphite without rewriting jj history.
# Source this file, then run: jjg [<stop-at>] [gt-submit-args...]
# With no stop, include the connected stack around @. --dry-run previews only.
# Requires an initialized Graphite repository, gh authentication, and jq.

jjg() (
	set -euo pipefail

	stop=""
	if [ "$#" -gt 0 ] && [[ "$1" != -* ]]; then
		stop="$1"
		shift
	fi
	preview=false
	for arg in "$@"; do
		case "$arg" in
			--dry-run|--dry-run=true) preview=true ;;
			--dry-run=false) preview=false ;;
			--restack*|--branch*|--stack*|-s|--target-trunk*|--update-only|-u)
				echo "jjg: $arg overrides the jj-derived stack and is not supported." >&2
				exit 1 ;;
		esac
	done

	config=$(git rev-parse --git-path .graphite_repo_config)
	trunk=$(jq -er '.trunk' "$config")
	remote=$(jq -er '.remote // "origin"' "$config")
	trunk_commit=$(git rev-parse "refs/heads/$trunk")
	if [ -n "$stop" ]; then
		revset="ancestors($stop) ~ ancestors($trunk_commit)"
	else
		revset="reachable(@, $trunk_commit..)"
	fi
	branches_raw=$(jj log -r "$revset" --reversed --no-graph \
		-T 'if(local_bookmarks, local_bookmarks.map(|b| b.name()).join(" ") ++ "\n")')
	if [ -z "$branches_raw" ]; then
		echo "jjg: no bookmarks to submit (${stop:-current stack})."
		exit 0
	fi

	mapfile -t branches <<< "$branches_raw"
	declare -A parents pr_numbers
	parent="$trunk"
	for branch in "${branches[@]}"; do
		if [[ "$branch" == *" "* ]]; then
			echo "jjg: multiple bookmarks on one commit ($branch). Leave one." >&2
			exit 1
		fi
		if ! git merge-base --is-ancestor "$parent" "$branch"; then
			echo "jjg: $parent -> $branch is not a linear stack. Select a stop-at revision." >&2
			exit 1
		fi
		parents[$branch]="$parent"
		printf 'jjg: %s -> %s\n' "$parent" "$branch"
		parent="$branch"
	done
	tip="$parent"

	repo_info=$(gh repo view "$(git remote get-url "$remote")" --json nameWithOwner,url \
		--jq '[(.url | split("/")[2]), .nameWithOwner] | @tsv')
	IFS=$'\t' read -r host repository <<< "$repo_info"
	remote_trunk=$(gh api --hostname "$host" "repos/$repository/git/ref/heads/$trunk" --jq '.object.sha')
	if [ "$remote_trunk" != "$trunk_commit" ]; then
		echo "jjg: local $trunk is out of sync with $remote/$trunk." >&2
		echo "Fetch $remote, update local $trunk, then rebase your jj stack onto $trunk and rerun jjg." >&2
		exit 1
	fi
	open_prs=$(gh api --hostname "$host" --paginate \
		"repos/$repository/pulls?state=open&per_page=100" | jq -s 'add')
	selected=$(printf '%s\n' "${branches[@]}" | jq -Rsc 'split("\n")[:-1]')

	# A push also changes the base of PRs outside the selected range.
	excluded=$(jq -r --argjson selected "$selected" --arg repo "$repository" '
		.[] | select(.base.ref as $base | $selected | index($base))
		| select(.head.repo.full_name != $repo or
			(.head.ref as $head | $selected | index($head) | not))
		| "#\(.number) (\(.head.label))"' <<< "$open_prs")
	if [ -n "$excluded" ]; then
		printf 'jjg: include dependent PRs in the stack before pushing:\n%s\n' "$excluded" >&2
		exit 1
	fi

	new_branches=()
	for branch in "${branches[@]}"; do
		pr_numbers[$branch]=$(jq -r --arg branch "$branch" --arg repo "$repository" '
			[.[] | select(.head.ref == $branch and .head.repo.full_name == $repo)]
			| if length > 1 then error("multiple open PRs for " + $branch)
			  else .[0].number // empty end' <<< "$open_prs")
		if [ -z "${pr_numbers[$branch]}" ]; then
			new_branches+=("$branch")
			printf 'jjg: %s will get a new PR.\n' "$branch"
		fi
	done

	if "$preview"; then
		echo "jjg: would protect existing PR bases with $trunk, submit through $tip, then restore the parents above."
		exit 0
	fi

	repo_root=$(git rev-parse --show-toplevel)
	if [ -f "$repo_root/.husky/pre-commit" ]; then
		( cd "$repo_root" && sh .husky/pre-commit )
	fi
	for branch in "${branches[@]}"; do
		HUSKY=0 gt track --parent "${parents[$branch]}" "$branch" --no-interactive
	done

	# GitHub can mark a PR merged if its old base gains its head during a push.
	# Keep bases on trunk until all pushes finish, including when submit fails.
	trap 'echo "jjg: submit incomplete. PRs may still target trunk. Resolve the error and rerun jjg." >&2' ERR
	for branch in "${branches[@]}"; do
		number=${pr_numbers[$branch]}
		[ -n "$number" ] || continue
		base=$(jq -r --argjson number "$number" '.[] | select(.number == $number) | .base.ref' <<< "$open_prs")
		[ "$base" != "$trunk" ] || continue
		gh api --hostname "$host" --method PATCH "repos/$repository/pulls/$number" \
			-f base="$trunk" --jq 'if .state == "open" then "PR #\(.number): base -> \(.base.ref)" else error("PR is no longer open") end'
	done

	# Graphite retains retired PR links even after branch deletion. Only detach
	# terminal cache entries for branches verified to have no open PR above.
	pr_cache=$(git rev-parse --git-path .graphite_pr_info)
	if [ "${#new_branches[@]}" -gt 0 ] && [ -f "$pr_cache" ]; then
		new_names=$(printf '%s\n' "${new_branches[@]}" | jq -Rsc 'split("\n")[:-1]')
		cache_tmp=$(mktemp "$pr_cache.jjg.XXXXXX")
		if jq --argjson names "$new_names" '
			[.prInfos[] | select(.headRefName as $name | $names | index($name))
			 | select(.state == "CLOSED" or .state == "MERGED") | .prNumber] as $retired
			| .prInfos |= map(select(.prNumber as $n | $retired | index($n) | not))
			| .mergeabilityStatuses |= map(select(.prNumber as $n | $retired | index($n) | not))
		' "$pr_cache" > "$cache_tmp"; then
			mv -- "$cache_tmp" "$pr_cache"
		else
			rm -- "$cache_tmp"
			exit 1
		fi
	fi

	gt submit --no-interactive --no-edit --no-stack --branch "$tip" "$@"

	# Graphite may report No-op from its cache even after we changed a remote base.
	for branch in "${branches[@]}"; do
		number=${pr_numbers[$branch]}
		[ -n "$number" ] || continue
		gh api --hostname "$host" --method PATCH "repos/$repository/pulls/$number" \
			-f base="${parents[$branch]}" --jq 'if .state == "open" then "PR #\(.number): base -> \(.base.ref)" else error("PR is no longer open") end'
	done
	trap - ERR
)
