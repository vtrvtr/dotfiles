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

config_home=$state_root/config
data_home=$state_root/data
state_home=$state_root/state
cache_home=$state_root/cache
mkdir -p "$config_home" "$data_home" "$state_home" "$cache_home"

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
    mkdir -p "$config_home/atuin"
    cp --no-preserve=mode -- "$home_files/.config/atuin/config.toml" "$config_home/atuin/config.toml"
    sed -i \
      -e '/^db_path =/d' \
      -e '/^key_path =/d' \
      -e '/^session_path =/d' \
      -e '/^sync_address =/d' \
      "$config_home/atuin/config.toml"
    cat >> "$config_home/atuin/config.toml" <<EOF

db_path = "$data_home/atuin/history.db"
key_path = "$data_home/atuin/key"
session_path = "$data_home/atuin/session"
EOF
    continue
  fi
  link_config "$source" "$config_home/$relative"
done < <(find "$home_files/.config" -mindepth 1 -maxdepth 1 -print0)

if [[ ! -e "$config_home/nvim/nvim-pack-lock.json" ]]; then
  nvim_config=$config_home/nvim
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
[[ "$shell" == bash ]] || usage_error "clean launcher currently supports bash; requested '$shell'"

host_bashrc=$state_root/host-bashrc
if [[ "$profile" == al && ! -e "$host_bashrc" ]]; then
  cp --no-preserve=mode -- "$HOME/.bashrc" "$host_bashrc"
fi

readonly forwarded=(
  ALL_PROXY CURL_CA_BUNDLE COLORTERM DBUS_SESSION_BUS_ADDRESS DISPLAY GIT_ASKPASS
  GIT_SSL_CAINFO KRB5CCNAME LANG LC_ALL NO_PROXY REQUESTS_CA_BUNDLE SSH_AGENT_PID
  SSH_AUTH_SOCK SSL_CERT_DIR SSL_CERT_FILE TERM WAYLAND_DISPLAY XAUTHORITY
  XDG_RUNTIME_DIR all_proxy http_proxy https_proxy no_proxy
)
child=(
  "HOME=$HOME"
  "USER=${USER:-$(id -un)}"
  "LOGNAME=${LOGNAME:-${USER:-$(id -un)}}"
  "SHELL=$home_path/bin/bash"
  "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
  "VTR_NIX_ISOLATED=1"
  "VTR_NIX_PROFILE=$profile"
  "VTR_NIX_CONFIG_HOME=$config_home"
  "VTR_NIX_DATA_HOME=$data_home"
  "VTR_NIX_STATE_HOME=$state_home"
  "VTR_NIX_CACHE_HOME=$cache_home"
  "VTR_NIX_HOME_FILES=$home_files"
  "VTR_NIX_HOME_PATH=$home_path"
  "VTR_NIX_HOST_BASHRC=$host_bashrc"
)

for name in "${forwarded[@]}"; do
  [[ -v $name ]] && child+=("$name=${!name}")
done
while IFS='=' read -r name value; do
  child+=("$name=$value")
done < <(env | grep -E '^(APPTAINER|SINGULARITY)_' || true)

exec env -i "${child[@]}" \
  "$home_path/bin/bash" --noprofile --rcfile "$REPO_ROOT/nix/config/shell/isolated-bashrc.sh" -i "$@"
