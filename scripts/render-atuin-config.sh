#!/usr/bin/env bash

set -euo pipefail

[[ $# -eq 2 ]] || {
  printf 'usage: %s SOURCE TARGET\n' "$0" >&2
  exit 2
}

source_file=$1
target_file=$2

: "${VTR_ATUIN_HOME:?set VTR_ATUIN_HOME to the private Atuin directory}"
if [[ ${VTR_NIX_PROFILE-} == al ]]; then
  : "${VTR_ATUIN_SYNC_ADDRESS:?set VTR_ATUIN_SYNC_ADDRESS for the AL profile}"
fi

mkdir -p "$VTR_ATUIN_HOME" "$(dirname -- "$target_file")"
tmp=$(mktemp "${target_file}.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT

write_setting() {
  local name=$1
  local value=$2

  [[ -n "$value" ]] || return
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s = "%s"\n' "$name" "$value"
}

{
  write_setting db_path "$VTR_ATUIN_HOME/history.db"
  write_setting key_path "$VTR_ATUIN_HOME/.key"
  write_setting session_path "$VTR_ATUIN_HOME/session"
  write_setting sync_address "${VTR_ATUIN_SYNC_ADDRESS-}"
  awk '!/^(db_path|key_path|session_path|sync_address)[[:space:]]*=/' "$source_file"
} > "$tmp"

chmod 600 "$tmp"
mv -- "$tmp" "$target_file"
trap - EXIT
