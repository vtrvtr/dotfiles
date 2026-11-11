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
home_files=$(nix build "$(home_files_ref "$profile")" --no-link --print-out-paths)
home_path=$(nix build "$(home_path_ref "$profile")" --no-link --print-out-paths)

export VTR_NIX_ISOLATED=1
export VTR_NIX_PROFILE=$profile
export XDG_CONFIG_HOME=$state_root/config
export XDG_DATA_HOME=$state_root/data
export XDG_STATE_HOME=$state_root/state
export XDG_CACHE_HOME=$state_root/cache
export PATH=$home_path/bin:$PATH

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

link_config() {
  local source=$1
  local target=$2

  mkdir -p "$(dirname -- "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    [[ -L "$target" && $(readlink -- "$target") == "$source" ]] && return
    printf 'isolated config target already exists: %s\n' "$target" >&2
    exit 1
  fi
  ln -s -- "$source" "$target"
}

# Link generated configuration while keeping runtime state under the isolated root.
while IFS= read -r -d '' source; do
  relative=${source#"$home_files/.config/"}
  if [[ "$relative" == "atuin" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/atuin"
    cp --no-preserve=mode -- "$home_files/.config/atuin/config.toml" "$XDG_CONFIG_HOME/atuin/config.toml"
    sed -i \
      -e '/^db_path =/d' \
      -e '/^key_path =/d' \
      -e '/^session_path =/d' \
      -e '/^sync_address =/d' \
      "$XDG_CONFIG_HOME/atuin/config.toml"
    cat >> "$XDG_CONFIG_HOME/atuin/config.toml" <<EOF

db_path = "$XDG_DATA_HOME/atuin/history.db"
key_path = "$XDG_DATA_HOME/atuin/key"
session_path = "$XDG_DATA_HOME/atuin/session"
EOF
    continue
  fi
  link_config "$source" "$XDG_CONFIG_HOME/$relative"
done < <(find "$home_files/.config" -mindepth 1 -maxdepth 1 -print0)

if [[ ! -e "$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json" ]]; then
  nvim_config=$XDG_CONFIG_HOME/nvim
  if [[ -L "$nvim_config" ]]; then
    rm -- "$nvim_config"
    mkdir -p "$nvim_config"
    cp -R --no-preserve=mode -- "$home_files/.config/nvim/." "$nvim_config/"
    find "$nvim_config" -type d -exec chmod u+rwx {} +
    find "$nvim_config" -type f -exec chmod u+rw {} +
  fi
  cp -- "$REPO_ROOT/nvim-pack/nvim-pack-lock.json" "$nvim_config/nvim-pack-lock.json"
fi

shell=${VTR_NIX_SHELL:-${SHELL##*/}}
case "$shell" in
  bash)
    exec bash --noprofile --rcfile "$home_files/.bashrc" -i "$@"
    ;;
  fish)
    exec fish --init-command "source '$home_files/.config/fish/config.fish'" -i "$@"
    ;;
  zsh)
    export ZDOTDIR=$state_root/zsh
    mkdir -p "$ZDOTDIR"
    for file in .zprofile .zshenv .zshrc; do
      ln -sfn -- "$home_files/$file" "$ZDOTDIR/$file"
    done
    exec zsh -i "$@"
    ;;
  *)
    usage_error "unsupported shell '$shell'; choose bash, fish, or zsh"
    ;;
esac
