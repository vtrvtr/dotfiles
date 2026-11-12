# zsh cannot source the bash environment, so build it here and hand the result to zsh.
vtr_nix_isolated=${BASH_SOURCE[0]%/*}
zsh=$VTR_NIX_HOME_PATH/bin/zsh
source "$vtr_nix_isolated/env.sh"
source "$vtr_nix_isolated/post-rc.sh"
exec "$zsh" "$@"
