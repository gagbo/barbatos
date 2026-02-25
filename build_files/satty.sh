#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

log() {
	set +x
	echo "=== $* ==="
	set -x
}

log "Installing Satty (screenshot annotation tool)"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

LATEST_SATTY_VERSION=$(curl -s https://api.github.com/repos/Satty-org/Satty/releases/latest | grep tag_name | cut -d : -f2 | tr -d "\" ,")
log "Fetched Satty version: ${LATEST_SATTY_VERSION}"

curl -O -L "https://github.com/Satty-org/Satty/releases/download/${LATEST_SATTY_VERSION}/satty-${LATEST_SATTY_VERSION}.flatpak"
flatpak install --system -y satty-${LATEST_SATTY_VERSION}.flatpak
rm satty-${LATEST_SATTY_VERSION}.flatpak

satty --version
