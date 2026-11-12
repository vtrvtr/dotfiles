vtr_private_env=${VTR_PRIVATE_CONFIG:-$HOME/.config/vtr/private.env}
if [[ -r "$vtr_private_env" ]]; then
  set -a
  source "$vtr_private_env"
  set +a
fi
unset vtr_private_env
