#!/usr/bin/env bash
# VTR collection of configurations — Starship init

set -euo pipefail

# Optional override if you ever want to force a path:
# export STARSHIP_BIN_OVERRIDE="/root/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/starship"

# 1) explicit override wins
if [ "${STARSHIP_BIN_OVERRIDE-}" != "" ] && [ -x "$STARSHIP_BIN_OVERRIDE" ]; then
	STARSHIP_BIN="$STARSHIP_BIN_OVERRIDE"
# 2) normal PATH
elif STARSHIP_BIN="$(command -v starship 2>/dev/null)"; then
	:
# 3) a few common spots (add more if you like)
elif [ -x "$HOME/.nix-profile/bin/starship" ]; then
	STARSHIP_BIN="$HOME/.nix-profile/bin/starship"
elif [ -x "$HOME/.local/bin/starship" ]; then
	STARSHIP_BIN="$HOME/.local/bin/starship"
elif [ -x "/nix/var/nix/profiles/default/bin/starship" ]; then
	STARSHIP_BIN="/nix/var/nix/profiles/default/bin/starship"
elif [ -x "$HOME/.devbox/nix/profile/default/bin/starship" ]; then
	STARSHIP_BIN="$HOME/.devbox/nix/profile/default/bin/starship"
elif [ -x "/root/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/starship" ]; then
	STARSHIP_BIN="/root/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/starship"
else
	echo "starship not found; skipping init" >&2
	return 0 2>/dev/null || exit 0
fi

# Init for bash (this file is sourced by bashrc)
eval -- "$("$STARSHIP_BIN" init bash --print-full-init)"
