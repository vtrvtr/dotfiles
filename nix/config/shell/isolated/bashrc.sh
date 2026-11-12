vtr_nix_isolated=${BASH_SOURCE[0]%/*}
source "$vtr_nix_isolated/env.sh"
source "$VTR_NIX_HOME_FILES/.bashrc"
source "$vtr_nix_isolated/post-rc.sh"
unset vtr_nix_isolated
