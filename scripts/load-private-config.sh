#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
  printf 'usage: %s PROFILE CONTRACT\n' "${BASH_SOURCE[0]}" >&2
  return 2 2>/dev/null || exit 2
fi

profile=$1
contract=$2
repo_root=${contract%/config/private-vars.conf}
private_file=${VTR_PRIVATE_CONFIG:-$HOME/.config/vtr/private.env}

if [[ -r "$private_file" ]]; then
  source "$private_file"
fi

missing=()
while IFS='|' read -r name profiles description; do
  [[ -n "$name" && ${name:0:1} != '#' ]] || continue
  [[ "$profiles" == '*' || ",$profiles," == *",$profile,"* ]] || continue
  [[ -n ${!name-} ]] || missing+=("$name|$description")
done < "$contract"

if (( ${#missing[@]} )); then
  printf 'Missing host configuration for profile %s:\n' "$profile" >&2
  for entry in "${missing[@]}"; do
    printf '  %-24s %s\n' "${entry%%|*}" "${entry#*|}" >&2
  done
  printf '\nExport these in the host environment or override them in %s.\n' "$private_file" >&2
  printf 'See %s/config/private.env.example.\n' "$repo_root" >&2
  return 1 2>/dev/null || exit 1
fi

unset profile contract repo_root private_file missing name profiles description entry
