#!/usr/bin/env bash

set -euo pipefail

for command_name in jj git; do
    command -v "$command_name" >/dev/null || {
        printf 'workspaces: missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

jj root >/dev/null
git rev-parse --show-toplevel >/dev/null

current_root=$(jj workspace root)
jj_output=$(jj workspace list --ignore-working-copy --color=never \
    -T 'name ++ "\t" ++ if(root, root.absolute(), "<missing>") ++ "\t" ++ target.commit_id().short() ++ "\t" ++ target.current_working_copy() ++ "\n"')
git_output=$(git worktree list --porcelain)

declare -a paths=()
declare -A sources=()
declare -A details=()

normalize_path() {
    (cd -- "$1" && pwd -P)
}

add_record() {
    local path=$1
    local source=$2
    local detail=$3

    if [[ -z ${sources["$path"]+set} ]]; then
        paths+=("$path")
        sources["$path"]=$source
        details["$path"]=$detail
        return
    fi

    sources["$path"]+=" + $source"
    details["$path"]+="; $detail"
}

while IFS=$'\t' read -r name path revision current; do
    [[ -n "$name" ]] || continue
    if [[ "$path" == '<missing>' && "$current" == 'true' ]]; then
        path=$current_root
    fi
    [[ "$path" != '<missing>' && -d "$path" ]] || continue
    path=$(normalize_path "$path")
    add_record "$path" jj "$name @ $revision"
done <<< "$jj_output"

path=''
revision=''
ref='detached'
while IFS= read -r line; do
    case "$line" in
        'worktree '*)
            if [[ -n "$path" ]]; then
                add_record "$(normalize_path "$path")" git "$ref @ $revision"
            fi
            path=${line#worktree }
            revision=''
            ref='detached'
            ;;
        'HEAD '*)
            revision=${line#HEAD }
            revision=${revision:0:12}
            ;;
        'branch refs/heads/'*)
            ref=${line#branch refs/heads/}
            ;;
        bare)
            ref='bare'
            ;;
    esac
done <<< "$git_output"

if [[ -n "$path" ]]; then
    add_record "$(normalize_path "$path")" git "$ref @ $revision"
fi

for path in "${paths[@]}"; do
    printf '%s\t%s\t%s\n' "$path" "${sources["$path"]}" "${details["$path"]}"
done
