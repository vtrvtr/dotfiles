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

state_root=${VTR_NIX_ROOT:-$HOME/.local/share/vtr-nix/$profile}
home_path=$(nix build "$(home_path_ref "$profile")" --no-link --print-out-paths)

# Resolve the jj identity from the host config before XDG points at the isolated root.
export JJ_USER=${JJ_USER:-$(jj config get user.name 2>/dev/null || true)}
export JJ_EMAIL=${JJ_EMAIL:-$(jj config get user.email 2>/dev/null || true)}
export VTR_NIX_ROOT=$state_root
export VTR_NIX_WEZTERM_LAUNCHER=$REPO_ROOT/scripts/nix-shell.sh
export VTR_NIX_WEZTERM_PROFILE=$profile
export XDG_CONFIG_HOME=$state_root/config
export XDG_DATA_HOME=$state_root/data
export XDG_STATE_HOME=$state_root/state
export XDG_CACHE_HOME=$state_root/cache
export PATH=$home_path/bin:$PATH

# Prepare the isolated config tree before WezTerm reads it.
VTR_NIX_SHELL=bash "$REPO_ROOT/scripts/nix-shell.sh" "$profile" -c true

exec "$home_path/bin/wezterm" start "$@"
