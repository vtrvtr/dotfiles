export AL_ENV="$HOME/.al_env"

if [[ -r "$AL_ENV/bash_custom" ]]; then
  export VTR_BASH_INITIALIZED=true
  source "$AL_ENV/bash_custom"
fi
