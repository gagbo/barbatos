#!/usr/bin/bash
# Phase 90 - Final cleanup + bootc lint

set ${SET_X:+-x} -euo pipefail

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '=== %s ===\n' "$*"
	if ((had_xtrace)); then set -x; fi
}

log "Cleaning package manager caches"
dnf5 clean all

log "Removing scratch directories"
rm -rf /usr/etc /tmp/barbatos
rm -rf ~/rpmbuild

log "Running bootc container lint"
bootc container lint

ostree container commit
