#!/usr/bin/env bash

set -euo pipefail

[[ $# -eq 2 ]] || {
  printf 'usage: %s SOURCE TARGET\n' "$0" >&2
  exit 2
}

source_file=$1
target_file=$2

atuin_home=${VTR_ATUIN_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/atuin}

mkdir -p "$atuin_home" "$(dirname -- "$target_file")"
tmp=$(mktemp "${target_file}.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT

write_setting() {
  local name=$1
  local value=$2

  [[ -n "$value" ]] || return 0
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s = "%s"\n' "$name" "$value"
}

{
  write_setting db_path "$atuin_home/history.db"
  write_setting key_path "$atuin_home/.key"
  write_setting session_path "$atuin_home/session"
  write_setting sync_address "${VTR_ATUIN_SYNC_ADDRESS-}"
  awk '!/^(db_path|key_path|session_path|sync_address)[[:space:]]*=/' "$source_file"
} > "$tmp"

chmod 600 "$tmp"
mv -- "$tmp" "$target_file"
trap - EXIT
