if [[ -r /etc/profile ]]; then
  source /etc/profile
fi

readonly vtr_nix_config_home=$VTR_NIX_CONFIG_HOME
readonly vtr_nix_data_home=$VTR_NIX_DATA_HOME
readonly vtr_nix_state_home=$VTR_NIX_STATE_HOME
readonly vtr_nix_cache_home=$VTR_NIX_CACHE_HOME
readonly vtr_nix_home_files=$VTR_NIX_HOME_FILES
readonly vtr_nix_home_path=$VTR_NIX_HOME_PATH
readonly vtr_nix_repo_root=$VTR_NIX_REPO_ROOT

if [[ ${VTR_NIX_PROFILE-} == al && -r ${VTR_NIX_HOST_BASHRC-} ]]; then
  export VTR_BASH_INITIALIZED=true
  source "$VTR_NIX_HOST_BASHRC"
  export VTR_AL_ENV_INITIALIZED=true
fi

for name in ${!DEVBOX_@} ${!__DEVBOX@}; do
  unset "$name"
done
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vi devbox | awk 'NF && !seen[$0]++' | paste -sd: -)

source "$vtr_nix_repo_root/scripts/load-private-config.sh" \
  "$VTR_NIX_PROFILE" \
  "$vtr_nix_repo_root/config/private-vars.conf"

unset ATUIN_CONFIG_DIR
export XDG_CONFIG_HOME="$vtr_nix_config_home"
export XDG_DATA_HOME="$vtr_nix_data_home"
export XDG_STATE_HOME="$vtr_nix_state_home"
export XDG_CACHE_HOME="$vtr_nix_cache_home"
export PATH="$vtr_nix_home_path/bin:$PATH"

source "$vtr_nix_home_path/etc/profile.d/hm-session-vars.sh"
source "$vtr_nix_repo_root/nix/config/shell/atuin-private.sh"
export JJ_CONFIG="$XDG_CONFIG_HOME/jj/config.toml"
source "$vtr_nix_home_files/.bashrc"

export XDG_CONFIG_HOME="$vtr_nix_config_home"
export XDG_DATA_HOME="$vtr_nix_data_home"
export XDG_STATE_HOME="$vtr_nix_state_home"
export XDG_CACHE_HOME="$vtr_nix_cache_home"
export PATH="$vtr_nix_home_path/bin:$PATH"

unset VTR_NIX_CONFIG_HOME VTR_NIX_DATA_HOME VTR_NIX_STATE_HOME VTR_NIX_CACHE_HOME
unset VTR_NIX_HOME_FILES VTR_NIX_HOME_PATH VTR_NIX_HOST_BASHRC VTR_NIX_REPO_ROOT
