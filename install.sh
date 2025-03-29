#!/usr/bin/env bash
set -euo pipefail

# 1. Install devbox if it's not already installed.
if ! command -v devbox >/dev/null 2>&1; then
	echo "Installing devbox..."
	curl -fsSL https://get.jetify.com/devbox | bash
else
	echo "devbox is already installed."
fi

# 1b. Ensure the devbox shellenv init hook is present in .bashrc.
SHELL_RC="$HOME/.bashrc"
INIT_LINE='eval "$(devbox global shellenv --init-hook)"'
if [ -f "$SHELL_RC" ]; then
	if ! grep -Fq "$INIT_LINE" "$SHELL_RC"; then
		echo "$INIT_LINE" >>"$SHELL_RC"
		echo "Added devbox shellenv init hook to $SHELL_RC"
	else
		echo "devbox shellenv init hook already present in $SHELL_RC"
	fi
else
	echo "$SHELL_RC not found. Creating it and adding init hook."
	echo "$INIT_LINE" >"$SHELL_RC"
fi

# Immediately load the devbox environment for the current session.
eval "$(devbox global shellenv --init-hook)"

# 2. Add dotter via devbox if not already added.
if ! command -v dotter >/dev/null 2>&1; then
	echo "Adding dotter via devbox..."
	devbox add dotter
else
	echo "dotter is already added."
fi

# 3. Deploy dotter configurations (should be run from the repository root).
echo "Deploying dotter configuration..."
dotter deploy

echo "All steps completed."
