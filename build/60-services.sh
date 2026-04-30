#!/usr/bin/bash
# Phase 60 - System service tweaks

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

log "Enabling podman.socket"
systemctl enable podman.socket

log "Enabling gnome-keyring socket activation (all users)"
systemctl --global enable gnome-keyring-daemon.socket

log "Enabling {niri,sway}-gated polkit agent (all users)"
systemctl --global enable polkit-agent.service
