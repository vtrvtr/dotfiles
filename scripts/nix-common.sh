#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly REPO_ROOT
readonly USER_NAME=vitorh
readonly PROFILES=(generic-linux al trpc macos macos-intel)

usage_error() {
  printf '%s\n' "$1" >&2
  exit 2
}

list_profiles() {
  printf '%s\n' "${PROFILES[@]}"
}

require_profile() {
  local requested=${1-}
  local profile

  [[ -n "$requested" ]] || usage_error "profile required; choose: ${PROFILES[*]}"
  for profile in "${PROFILES[@]}"; do
    [[ "$requested" == "$profile" ]] && return
  done
  usage_error "unknown profile '$requested'; choose: ${PROFILES[*]}"
}

flake_ref() {
  printf '%s#%s@%s' "$REPO_ROOT" "$USER_NAME" "$1"
}

activation_ref() {
  printf '%s#homeConfigurations."%s".activationPackage' "$REPO_ROOT" "$USER_NAME@$1"
}

home_files_ref() {
  printf '%s#homeConfigurations."%s".config.home-files' "$REPO_ROOT" "$USER_NAME@$1"
}

home_path_ref() {
  printf '%s#homeConfigurations."%s".config.home.path' "$REPO_ROOT" "$USER_NAME@$1"
}

bash_ref() {
  printf '%s#homeConfigurations."%s".pkgs.bashInteractive^out' "$REPO_ROOT" "$USER_NAME@$1"
}
