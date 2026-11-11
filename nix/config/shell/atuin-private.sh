if [[ ${VTR_NIX_PROFILE-} != al ]]; then
  export VTR_ATUIN_HOME="$XDG_DATA_HOME/atuin"
fi

"$VTR_NIX_REPO_ROOT/scripts/render-atuin-config.sh" \
  "$VTR_NIX_REPO_ROOT/atuin/config.toml" \
  "$XDG_CONFIG_HOME/atuin/config.toml"
