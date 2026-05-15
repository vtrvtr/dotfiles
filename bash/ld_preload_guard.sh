# shellcheck shell=bash
# Houdini/DCC rez contexts inject LD_PRELOAD (jemalloc + houdini's libtbb.so.2).
# Inside the apptainer container libtbb needs a libstdc++.so.6 that isn't
# resolvable, so every foreign-toolchain binary (nix atuin/starship/zoxide,
# devbox, ...) aborts at startup. Drop the preload for the interactive shell;
# keep it reachable for the few tools that genuinely need it.

if [[ $- == *i* && ( -n ${APPTAINER_NAME-} || -n ${SINGULARITY_NAME-} ) ]]; then
	if [[ -n ${LD_PRELOAD-} && -z ${VTR_HOST_LD_PRELOAD-} ]]; then
		export VTR_HOST_LD_PRELOAD="$LD_PRELOAD"
		unset LD_PRELOAD
	fi
fi

# Run a command with the original DCC LD_PRELOAD restored (e.g. relaunching
# houdini/hython from this shell).
with-preload() {
	LD_PRELOAD="${VTR_HOST_LD_PRELOAD-}" "$@"
}
