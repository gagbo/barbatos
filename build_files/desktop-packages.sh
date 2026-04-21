#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '=== %s ===\n' "$*"
	if (( had_xtrace )); then
		set -x
	fi
}

retry_dnf() {
	local max_attempts="$1"
	shift

	local attempt=1
	local status=0
	until "$@"; do
		status="$?"
		if (( attempt >= max_attempts )); then
			return "$status"
		fi

		log "DNF command failed, cleaning metadata and retrying (${attempt}/${max_attempts})"
		dnf5 clean all || true
		sleep $(( attempt * 5 ))
		((attempt++))
	done
}

configure_terra_repos() {
	for i in /etc/yum.repos.d/terra*.repo; do
		if [[ -f "$i" ]]; then
			sed -i \
				-e 's@enabled=0@enabled=1@g' \
				-e 's@skip_if_unavailable=True@skip_if_unavailable=False@g' \
				-e 's@skip_if_unavailable=true@skip_if_unavailable=False@g' \
				"$i"
		fi
	done
}

log "Installing RPM packages"

log "Enable Copr repos"

COPR_REPOS=(
	scottames/ghostty
	ulysg/xwayland-satellite
	ublue-os/akmods
	quadratech188/vicinae
)
for repo in "${COPR_REPOS[@]}"; do
	dnf5 -y copr enable "$repo"
done

log "Enable repositories"
# Reenable Terra repos (installed on F42 and earlier)
configure_terra_repos
retry_dnf 5 dnf5 -y install --refresh --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} || true
configure_terra_repos
retry_dnf 5 dnf5 makecache --refresh

log "Install layered applications"

# Cosign is special (= unavailable in repos)
LATEST_COSIGN_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-${LATEST_COSIGN_VERSION}-1.x86_64.rpm"
rpm -ivh cosign-${LATEST_COSIGN_VERSION}-1.x86_64.rpm

# Other Layered Applications
LAYERED_PACKAGES=(
	ansible git
	chezmoi
	podman-compose
	podman-remote

	fish
	starship
	zsh

	jq

	cockpit
	cockpit-machines
	cockpit-ostree
	cockpit-sosreport

	ghostty helix kitty
	fira-code-fonts

	niri noctalia-shell
	xdg-desktop-portal-gnome xdg-desktop-portal-gtk
	python3 cliphist
	wlsunset swaylock swayidle
	mako fuzzel swaybg light foot
	grim slurp wl-clipboard
	xwayland-satellite vicinae
	qt6-qtmultimedia cava
	ImageMagick

	matugen
	polkit-kde brightnessctl
	xdg-desktop-portal evolution-data-server
	ddcutil

	nodejs nodejs-npm pnpm

	sqlite
	yubikey-manager

	syncthing syncthing-tools

	thinkfan
)
retry_dnf 5 dnf5 install --refresh --setopt=install_weak_deps=False -y "${LAYERED_PACKAGES[@]}"

log "Disable Copr repos as we do not need it anymore"

for repo in "${COPR_REPOS[@]}"; do
	dnf5 -y copr disable "$repo"
done
# Use flatpak steam with some addons instead
# rpm-ostree override remove steam
log "Removing Steam from Bazzite install, please use flatpak instead"
dnf5 -y remove steam

# Disable terra repos
for i in /etc/yum.repos.d/terra*.repo; do
	if [[ -f "$i" ]]; then
		sed -i 's@enabled=1@enabled=0@g' "$i"
	fi
done
