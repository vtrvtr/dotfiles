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
config_home=$state_root/config
data_home=$state_root/data
state_home=$state_root/state
cache_home=$state_root/cache
marker=$state_root/.vtr-nix
marker_content=$(printf 'version=1\nprofile=%s' "$profile")

# Claim the root before anything (including nix's cache) can write into it.
if [[ -e "$marker" ]]; then
  [[ -f "$marker" && $(<"$marker") == "$marker_content" ]] || usage_error "invalid isolated state marker: $marker"
elif [[ -d "$state_root" && -n $(find "$state_root" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
  usage_error "unmarked isolated state exists: $state_root"
else
  mkdir -p "$state_root"
  printf '%s\n' "$marker_content" >"$marker.tmp"
  mv -- "$marker.tmp" "$marker"
fi

home_files=$(nix build "$(home_files_ref "$profile")" --no-link --print-out-paths)
home_path=$(nix build "$(home_path_ref "$profile")" --no-link --print-out-paths)
mkdir -p "$config_home" "$data_home" "$state_home" "$cache_home"

conflict() {
  printf 'isolated config target already exists: %s\n' "$1" >&2
  exit 1
}

# Store links on the path are replaced, so an older whole-directory link becomes a real directory.
ensure_dir() {
  local dir=$config_home part
  local -a parts

  IFS=/ read -ra parts <<<"$1"
  for part in "${parts[@]}"; do
    dir=$dir/$part
    if [[ -L "$dir" ]]; then
      [[ $(readlink -- "$dir") == /nix/store/* ]] || conflict "$dir"
      rm -- "$dir"
    fi
    [[ -e "$dir" && ! -d "$dir" ]] && conflict "$dir"
    [[ -d "$dir" ]] || mkdir -- "$dir"
  done
}

link_config() {
  local relative=$1
  local source=$home_files/.config/$relative
  local target=$config_home/$relative
  local current

  [[ "$relative" == */* ]] && ensure_dir "${relative%/*}"
  if [[ -L "$target" ]]; then
    current=$(readlink -- "$target")
    [[ "$current" == "$source" ]] && return
    [[ "$current" == /nix/store/* ]] || conflict "$target"
    rm -- "$target"
  elif [[ -e "$target" ]]; then
    conflict "$target"
  fi
  ln -s -- "$source" "$target"
}

# Mirror the generation like Home Manager: real directories, one store link per leaf.
# Directories stay writable for runtime state such as nvim-pack-lock.json and jj/repos.
while IFS= read -r -d '' source; do
  relative=${source#"$home_files/.config/"}
  [[ "$relative" == atuin/* ]] && continue
  link_config "$relative"
done < <(find "$home_files/.config" -mindepth 1 ! -type d -print0)

# Drop links into earlier generations and the directories they leave empty.
# Collected first so removals cannot disturb the walk.
links=()
while IFS= read -r -d '' link; do
  links+=("$link")
done < <(find "$config_home" -type l -print0)
for link in ${links[@]+"${links[@]}"}; do
  current=$(readlink -- "$link")
  [[ "$current" == /nix/store/* && "$current" != "$home_files"/* ]] || continue
  rm -- "$link"
  dir=${link%/*}
  while [[ "$dir" != "$config_home" && -z $(ls -A -- "$dir") ]]; do
    rmdir -- "$dir"
    dir=${dir%/*}
  done
done

if [[ ! -e "$config_home/nvim/nvim-pack-lock.json" ]]; then
  cp -- "$REPO_ROOT/nvim-pack/nvim-pack-lock.json" "$config_home/nvim/nvim-pack-lock.json"
fi

shell=${VTR_NIX_SHELL:-${SHELL##*/}}
[[ "$shell" == bash ]] || usage_error "clean launcher currently supports bash; requested '$shell'"

host_bashrc=$state_root/host-bashrc
if [[ "$profile" == al && ! -e "$host_bashrc" ]]; then
  cat -- "$HOME/.bashrc" >"$host_bashrc"
fi

jj_user=${JJ_USER:-$(jj config get user.name 2>/dev/null || true)}
jj_email=${JJ_EMAIL:-$(jj config get user.email 2>/dev/null || true)}

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
  "VTR_NIX_REPO_ROOT=$REPO_ROOT"
  "VTR_PRIVATE_CONFIG=${VTR_PRIVATE_CONFIG:-$HOME/.config/vtr/private.env}"
  "JJ_USER=$jj_user"
  "JJ_EMAIL=$jj_email"
)

for name in "${forwarded[@]}"; do
  [[ -n ${!name+x} ]] && child+=("$name=${!name}")
done
while IFS='=' read -r name value; do
  child+=("$name=$value")
done < <(env | grep -E '^(APPTAINER|SINGULARITY)_' || true)

exec env -i "${child[@]}" \
  "$home_path/bin/bash" --noprofile --rcfile "$REPO_ROOT/nix/config/shell/isolated/bashrc.sh" -i "$@"
