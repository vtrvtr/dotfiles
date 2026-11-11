if [[ -r /etc/profile ]]; then
  source /etc/profile
fi

if [[ ${VTR_NIX_PROFILE-} == al && -r ${VTR_NIX_HOST_BASHRC-} ]]; then
  export VTR_BASH_INITIALIZED=true
  source "$VTR_NIX_HOST_BASHRC"
  export VTR_AL_ENV_INITIALIZED=true
fi

for name in ${!DEVBOX_@} ${!__DEVBOX@}; do
  unset "$name"
done
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vi devbox | awk 'NF && !seen[$0]++' | paste -sd: -)

unset ATUIN_CONFIG_DIR
export XDG_CONFIG_HOME="$VTR_NIX_CONFIG_HOME"
export XDG_DATA_HOME="$VTR_NIX_DATA_HOME"
export XDG_STATE_HOME="$VTR_NIX_STATE_HOME"
export XDG_CACHE_HOME="$VTR_NIX_CACHE_HOME"
export PATH="$VTR_NIX_HOME_PATH/bin:$PATH"

source "$VTR_NIX_REPO_ROOT/nix/config/shell/atuin-private.sh"
source "$VTR_NIX_HOME_FILES/.bashrc"

export XDG_CONFIG_HOME="$VTR_NIX_CONFIG_HOME"
export XDG_DATA_HOME="$VTR_NIX_DATA_HOME"
export XDG_STATE_HOME="$VTR_NIX_STATE_HOME"
export XDG_CACHE_HOME="$VTR_NIX_CACHE_HOME"
export PATH="$VTR_NIX_HOME_PATH/bin:$PATH"

unset VTR_NIX_CONFIG_HOME VTR_NIX_DATA_HOME VTR_NIX_STATE_HOME VTR_NIX_CACHE_HOME
unset VTR_NIX_HOME_FILES VTR_NIX_HOME_PATH VTR_NIX_HOST_BASHRC VTR_NIX_REPO_ROOT
