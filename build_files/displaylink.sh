#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

log() {
	set +x
	echo "=== $* ==="
	set -x
}

RELEASE="$(rpm -E %fedora)"
# Check https://github.com/displaylink-rpm/displaylink-rpm/releases for versions
DISPLAYLINK_RPM_VERSION="v6.1.1-5"
DISPLAYLINK_EVDI_VERSION="1.14.14"

log "Installing DisplayLink driver (${DISPLAYLINK_RPM_VERSION}, evdi ${DISPLAYLINK_EVDI_VERSION}) for Fedora ${RELEASE}"

# DKMS needs kernel-devel to build the evdi module during image build
dnf5 install -y dkms kernel-devel make

RPM_URL="https://github.com/displaylink-rpm/displaylink-rpm/releases/download/${DISPLAYLINK_RPM_VERSION}/fedora-${RELEASE}-displaylink-${DISPLAYLINK_EVDI_VERSION}-1.github_evdi.x86_64.rpm"

log "Downloading DisplayLink RPM from ${RPM_URL}"
curl -L -o /tmp/displaylink.rpm "${RPM_URL}"

# The RPM %post scriptlet tries to access /sys and systemd, which don't exist
# during container builds. Install without running scriptlets, then manually
# perform the DKMS steps.
log "Installing DisplayLink RPM (skipping post-install scriptlets)"
rpm -ivh --nopost /tmp/displaylink.rpm
rm -f /tmp/displaylink.rpm

log "Building evdi DKMS module for current kernel"
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
dkms add evdi/${DISPLAYLINK_EVDI_VERSION} --rpm_safe_upgrade 2>&1 || true
dkms build evdi/${DISPLAYLINK_EVDI_VERSION} -k "${KERNEL_VERSION}" 2>&1
dkms install evdi/${DISPLAYLINK_EVDI_VERSION} -k "${KERNEL_VERSION}" 2>&1

log "Enabling displaylink-driver service"
systemctl enable displaylink-driver.service

log "DisplayLink driver installed successfully"
