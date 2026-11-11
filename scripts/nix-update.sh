#!/usr/bin/env bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/nix-common.sh"

cd "$REPO_ROOT"
nix flake update "$@"
exec "$REPO_ROOT/scripts/nix-check.sh"
