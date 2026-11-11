#!/usr/bin/env bash

set -euo pipefail

[[ $# -eq 2 ]] || {
  printf 'usage: %s SOURCE TARGET\n' "$0" >&2
  exit 2
}

source_file=$1
target_file=$2
[[ "$source_file" == "$target_file" ]] && exit
mkdir -p "$(dirname -- "$target_file")"
cp --no-preserve=mode -- "$source_file" "$target_file"
chmod 600 "$target_file"
