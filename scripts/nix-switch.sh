#!/usr/bin/env bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/nix-common.sh"

if [[ ${1-} == --list ]]; then
  list_profiles
  exit
fi

profile=${1-}
require_profile "$profile"
shift

cd "$REPO_ROOT"
if command -v home-manager >/dev/null 2>&1; then
  exec home-manager --flake ".#$USER_NAME@$profile" switch "$@"
fi
exec nix run github:nix-community/home-manager -- \
  --flake ".#$USER_NAME@$profile" switch "$@"
