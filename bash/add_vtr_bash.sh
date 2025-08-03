#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: $0 --bashrc /path/to/bashrc   (or)   $0 /path/to/bashrc" >&2
	exit 2
}

# Allow either "--bashrc PATH" or just "PATH"
if [[ "${1-}" == "--bashrc" ]]; then
	shift
fi
target="${1-}"
[[ -n "${target:-}" ]] || usage

# Expand ~ safely and enforce it stays under $HOME
target="${target/#\~/$HOME}"
case "$target" in
"$HOME"/*) ;;
*)
	echo "Refusing non-home path: $target" >&2
	exit 1
	;;
esac

# Require the file to already exist (avoids accidental creation)
[[ -f "$target" ]] || {
	echo "Target rc file does not exist: $target" >&2
	exit 1
}

comment="# VTR collection of configurations"
line='source "$HOME/.vtr_bash.sh"'

# Idempotent: do nothing if exact line already present
if grep -Fqx "$line" "$target"; then
	echo "Already present in $target"
	exit 0
fi

tmp="$(mktemp)"
{
	echo "$comment"
	echo "$line"
	cat "$target"
} >"$tmp"
mv "$tmp" "$target"
echo "Inserted VTR block at top of $target"
