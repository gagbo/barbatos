#!/usr/bin/bash
# Phase 10 - Copy OCI container content into the image
#
# Modelled after upstream Bluefin's build_files/shared/build.sh.
# Files arrive in /ctx via the Containerfile bind mount:
#
#   /ctx/build         (this directory)
#   /ctx/custom        (Brewfiles, flatpak lists, ujust recipes)
#   /ctx/system_files  (Barbatos hardware/service files)
#   /ctx/oci/common    (projectbluefin/common  -> ublue-os shared config)
#   /ctx/oci/brew      (ublue-os/brew          -> homebrew integration)

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

log "Removing rpms whose files are owned by projectbluefin/common"
# These ublue-os-* packages ship files under /etc and /usr/share that we are
# about to overwrite. Removing the rpm DB entries first avoids file conflicts
# and stale tracking. -- mirrors Bluefin upstream.
dnf5 remove -y \
	ublue-os-luks \
	ublue-os-just \
	ublue-os-udev-rules \
	ublue-os-signing \
	ublue-os-update-services 2>/dev/null || true

log "Swapping fedora-logos for generic-logos so Barbatos can ship its own"
dnf5 -y swap fedora-logos generic-logos 2>/dev/null || true
rpm --erase --nodeps --nodb generic-logos 2>/dev/null || true

log "Copying projectbluefin/common (shared ublue-os config)"
# common ships its files under /system_files/shared in the OCI image.
rsync -rvK /ctx/oci/common/shared/ /

log "Copying ublue-os/brew (homebrew integration)"
rsync -rvK /ctx/oci/brew/ /

log "Copying Barbatos system_files (hardware-specific units, fan profiles, satty)"
rsync -rvK /ctx/system_files/ /

log "Installing custom Brewfile, flatpak lists and ujust recipes"
install -d -m 0755 /usr/share/barbatos/homebrew /usr/share/barbatos/flatpaks

install -m 0644 /ctx/custom/brew/main.Brewfile \
	/usr/share/barbatos/homebrew/main.Brewfile

for list in /ctx/custom/flatpaks/*; do
	install -m 0644 "${list}" "/usr/share/barbatos/flatpaks/$(basename "${list}")"
done

# 00-entry.just uses `import? "/usr/share/ublue-os/just/60-custom.just"`, so we
# ship a 60-custom.just shim that imports our barbatos-*.just recipe files.
# There is no auto-discovery — the entry point has an explicit import list.
install -d -m 0755 /usr/share/ublue-os/just
for recipe in /ctx/custom/ujust/*.just; do
	install -m 0644 "${recipe}" "/usr/share/ublue-os/just/$(basename "${recipe}")"
done
