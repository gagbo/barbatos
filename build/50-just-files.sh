#!/usr/bin/bash
# Phase 50 - Verify that Barbatos ujust recipes landed correctly
#
# In the Aurora-based world we appended an `import` line to the legacy
# 60-custom.just shim. With the new projectbluefin/common layout there is
# no entry/custom shim - ujust auto-discovers every `.just` file in
# /usr/share/ublue-os/just. Phase 10 already copied our recipe file there;
# this phase only sanity-checks the install and runs `just --fmt --check`
# so a malformed recipe fails the build instead of a running system.

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

log "Validating Barbatos recipes with 'just --fmt --check'"
for recipe in "${UJUST_DIR}"/barbatos*.just; do
	just --unstable --fmt --check -f "${recipe}"
done
