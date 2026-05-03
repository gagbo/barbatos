#!/usr/bin/bash
# Phase 50 - Verify that Barbatos ujust recipes landed correctly
#
# The upstream 00-entry.just uses `import?` for 60-custom.just, which in
# turn imports our barbatos-*.just recipe files. Phase 10 copies all of
# them into /usr/share/ublue-os/just; this phase sanity-checks the install
# and runs `just --fmt --check` so a malformed recipe fails the build
# instead of a running system.

set ${SET_X:+-x} -eou pipefail

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '=== %s ===\n' "$*"
	if ((had_xtrace)); then set -x; fi
}

UJUST_DIR="/usr/share/ublue-os/just"

log "Listing ujust recipe files shipped on this image"
ls -1 "${UJUST_DIR}"

if ! ls "${UJUST_DIR}"/barbatos*.just >/dev/null 2>&1; then
	log "ERROR: no barbatos*.just file found under ${UJUST_DIR}" >&2
	exit 1
fi

if [[ ! -f "${UJUST_DIR}/60-custom.just" ]]; then
	log "ERROR: 60-custom.just shim not found under ${UJUST_DIR}" >&2
	exit 1
fi

log "Validating Barbatos recipes with 'just --fmt --check'"
for recipe in "${UJUST_DIR}"/barbatos*.just "${UJUST_DIR}"/60-custom.just; do
	just --unstable --fmt --check -f "${recipe}"
done
