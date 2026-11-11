export AL_ENV="$HOME/.al_env"

if [[ ${VTR_AL_ENV_INITIALIZED-} != true && -r "$AL_ENV/bash_custom" ]]; then
  export VTR_BASH_INITIALIZED=true
  source "$AL_ENV/bash_custom"
fi

if [[ ${VTR_NIX_ISOLATED-} == 1 ]]; then
  unalias nvim vi vim v 2>/dev/null || true
fi
