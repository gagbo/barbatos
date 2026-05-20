#!/usr/bin/bash
# Phase 15 - Upgrade kernel to latest stable
#
# The base image (silverblue-main) ships a kernel that may lag behind the
# latest stable release in the Fedora updates repo. We upgrade early so that
# every subsequent phase (DKMS, depmod, etc.) targets the final kernel.
#
# TMPDIR is set to /var/tmp because the Containerfile mounts /tmp as a
# separate tmpfs. rpm-ostree's kernel-install hook generates the initramfs
# via a tempfile and then renames it into /usr/lib/modules/<kver>/. A rename
# across filesystem boundaries fails with EXDEV (error 18), leaving the
# image without an initramfs and causing "VFS: cannot mount root fs" panics
# on boot.

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

OLD_KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
log "Current kernel: ${OLD_KVER}"

log "Upgrading kernel packages (TMPDIR=/var/tmp to avoid cross-device rename)"
export TMPDIR=/var/tmp
dnf5 upgrade -y --refresh \
	kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra \
	|| log "No kernel upgrade available, continuing with ${OLD_KVER}"

NEW_KVER="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
log "Kernel after upgrade: ${NEW_KVER}"

INITRAMFS="/usr/lib/modules/${NEW_KVER}/initramfs.img"
if [[ ! -s "${INITRAMFS}" ]]; then
	log "initramfs missing or empty, regenerating via kernel-install"
	kernel-install add "${NEW_KVER}" "/usr/lib/modules/${NEW_KVER}/vmlinuz"
fi

log "Verifying initramfs exists"
if [[ ! -s "${INITRAMFS}" ]]; then
	log "FATAL: ${INITRAMFS} still missing after kernel-install" >&2
	exit 1
fi
ls -lh "${INITRAMFS}"
