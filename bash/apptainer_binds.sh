#!/usr/bin/env bash
#
# Apptainer fix: ensure required host paths are bound into every container.
#
# Adds `bind path` entries to apptainer.conf so the listed host paths are
# visible inside containers. Idempotent: safe to re-run at any time. Only binds
# host paths that actually exist; a `bind path` pointing at a missing host path
# makes apptainer fail on every container launch, so missing paths are skipped
# with a warning instead.
#
set -euo pipefail

readonly CONF="/etc/apptainer/apptainer.conf"
readonly TEST_IMAGE="/film/tools/container_images/rockylinux-97/standard/latest.sif"

# Host paths to expose inside every container.
readonly BIND_PATHS=(
	/nix                       # host nix store + daemon
	/usr/local/bin/devbox      # Jetify launcher (single-file; home holds its cache)
)

# Re-exec under sudo if not already root.
if [[ ${EUID} -ne 0 ]]; then
	exec sudo "$0" "$@"
fi

if [[ ! -f ${CONF} ]]; then
	echo "error: ${CONF} not found; is apptainer installed on this host?" >&2
	exit 1
fi

added=0
for path in "${BIND_PATHS[@]}"; do
	line="bind path = ${path}"

	if grep -qxF "${line}" "${CONF}"; then
		echo "already present: ${line}"
		continue
	fi

	if [[ ! -e ${path} ]]; then
		echo "! skipping (host path missing): ${path}" >&2
		continue
	fi

	printf '%s\n' "${line}" >>"${CONF}"
	echo "+ added: ${line}"
	added=$((added + 1))
done

echo "done: ${added} bind path(s) added."

# Verify the binds resolve inside a real container (best-effort).
if [[ -f ${TEST_IMAGE} ]]; then
	echo "verifying inside ${TEST_IMAGE} ..."
	apptainer exec "${TEST_IMAGE}" bash -c '
		for p in /nix /usr/local/bin/devbox; do
			if [[ -e ${p} ]]; then echo "  visible: ${p}"; else echo "  MISSING: ${p}" >&2; fi
		done
	'
else
	echo "note: test image ${TEST_IMAGE} not found; skipping in-container verification." >&2
fi
