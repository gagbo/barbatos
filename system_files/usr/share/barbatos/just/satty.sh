#!/usr/bin/env bash

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

log() {
	echo "=== $* ==="
}

log "Installing Satty (screenshot annotation tool)"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

LATEST_SATTY_VERSION=$(
	curl -s https://api.github.com/repos/Satty-org/Satty/releases/latest |
		grep tag_name |
		cut -d : -f2 |
		tr -d "\" ,"
)

log "Fetched Satty version: ${LATEST_SATTY_VERSION}"

curl -o "${TMPDIR}/satty-${LATEST_SATTY_VERSION}.flatpak" -L "https://github.com/Satty-org/Satty/releases/download/${LATEST_SATTY_VERSION}/satty-${LATEST_SATTY_VERSION}.flatpak"
if ! flatpak info --system org.satty.Satty &>/dev/null; then
	flatpak install --system -y "${TMPDIR}/satty-${LATEST_SATTY_VERSION}.flatpak"
else
	flatpak update --system -y org.satty.Satty || true
fi

flatpak info --system org.satty.Satty >/dev/null
log "Satty Flatpak installed"
