if [[ $- == *i* && ( -n ${APPTAINER_NAME-} || -n ${SINGULARITY_NAME-} ) ]]; then
  if [[ -n ${LD_PRELOAD-} && -z ${VTR_HOST_LD_PRELOAD-} ]]; then
    export VTR_HOST_LD_PRELOAD="$LD_PRELOAD"
    unset LD_PRELOAD
  fi
fi

with-preload() {
  LD_PRELOAD="${VTR_HOST_LD_PRELOAD-}" "$@"
}
