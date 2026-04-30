#!/usr/bin/bash
# Phase 40 - DisplayLink driver (DKMS-built evdi module)
#
# The upstream RPM's %post tries to talk to systemd and /sys, neither of
# which exist in a container build. We --nopost the install and run the
# DKMS steps manually for the kernel that ships in this image.

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

# Pin versions explicitly so renovate (or a human) can bump them.
# https://github.com/displaylink-rpm/displaylink-rpm/releases
DISPLAYLINK_RPM_VERSION="v6.1.1-5"
DISPLAYLINK_EVDI_VERSION="1.14.14"

RELEASE="$(rpm -E %fedora)"
log "Installing DisplayLink ${DISPLAYLINK_RPM_VERSION} (evdi ${DISPLAYLINK_EVDI_VERSION}) for Fedora ${RELEASE}"

dnf5 install -y dkms kernel-devel make

RPM_URL="https://github.com/displaylink-rpm/displaylink-rpm/releases/download/${DISPLAYLINK_RPM_VERSION}/fedora-${RELEASE}-displaylink-${DISPLAYLINK_EVDI_VERSION}-1.github_evdi.x86_64.rpm"

log "Downloading ${RPM_URL}"
curl -fsSL -o /tmp/displaylink.rpm "${RPM_URL}"
rpm -ivh --nopost /tmp/displaylink.rpm
rm -f /tmp/displaylink.rpm

log "Building evdi DKMS module"
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
dkms add "evdi/${DISPLAYLINK_EVDI_VERSION}" --rpm_safe_upgrade 2>&1 || true
dkms build "evdi/${DISPLAYLINK_EVDI_VERSION}" -k "${KERNEL_VERSION}"
dkms install "evdi/${DISPLAYLINK_EVDI_VERSION}" -k "${KERNEL_VERSION}"

log "Enabling displaylink-driver service"
systemctl enable displaylink-driver.service
