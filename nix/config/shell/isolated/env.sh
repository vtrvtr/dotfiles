# Environment shared by every isolated shell, sourced by bash before the shell's own startup.
if [[ -r /etc/profile ]]; then
  source /etc/profile
fi

if [[ ${VTR_NIX_PROFILE-} == al && -r ${VTR_NIX_HOST_BASHRC-} ]]; then
  export VTR_BASH_INITIALIZED=true
  source "$VTR_NIX_HOST_BASHRC"
  export VTR_AL_ENV_INITIALIZED=true
fi

source "$VTR_NIX_REPO_ROOT/nix/config/shell/drop-devbox.sh"

source "$VTR_NIX_REPO_ROOT/scripts/load-private-config.sh" \
  "$VTR_NIX_PROFILE" \
  "$VTR_NIX_REPO_ROOT/config/private-vars.conf"

unset ATUIN_CONFIG_DIR
export XDG_CONFIG_HOME="$VTR_NIX_CONFIG_HOME"
export XDG_DATA_HOME="$VTR_NIX_DATA_HOME"
export XDG_STATE_HOME="$VTR_NIX_STATE_HOME"
export XDG_CACHE_HOME="$VTR_NIX_CACHE_HOME"
export PATH="$VTR_NIX_HOME_PATH/bin:$PATH"

source "$VTR_NIX_HOME_PATH/etc/profile.d/hm-session-vars.sh"
source "$VTR_NIX_REPO_ROOT/nix/config/shell/atuin-private.sh"
export JJ_CONFIG="$XDG_CONFIG_HOME/jj/config.toml"
