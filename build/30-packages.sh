#!/usr/bin/bash
# Phase 30 - Layered Barbatos packages
#
# Packages already shipped by silverblue-main + projectbluefin/common are
# *not* listed here. The list focuses on Barbatos's distinct identity:
#   - Niri / Wayland stack (compositor, shell, helpers)
#   - Terminals & editors (ghostty, helix, kitty)
#   - Theming (matugen, brightnessctl, ImageMagick, fonts, qt6 multimedia)
#   - Hardware (thinkfan)
#   - Shells (fish, starship, zsh)
#   - Misc (chezmoi, syncthing, sqlite, yubikey-manager)
#
# Cosign is fetched from upstream because it is not in any enabled repo.

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

retry_dnf() {
	local max_attempts="$1"
	shift

	local attempt=1
	local status=0
	until "$@"; do
		status="$?"
		if ((attempt >= max_attempts)); then
			return "$status"
		fi
		log "DNF command failed, cleaning metadata and retrying (${attempt}/${max_attempts})"
		dnf5 clean all || true
		sleep $((attempt * 5))
		((attempt++))
	done
}

if rpm -q cosign &>/dev/null; then
	log "cosign already installed ($(rpm -q cosign)), skipping"
else
	log "Installing cosign from upstream release"
	LATEST_COSIGN_VERSION=$(
		curl -fsSL https://api.github.com/repos/sigstore/cosign/releases/latest |
			grep tag_name | cut -d : -f2 | tr -d 'v", '
	)
	curl -fsSL -o /tmp/cosign.rpm \
		"https://github.com/sigstore/cosign/releases/latest/download/cosign-${LATEST_COSIGN_VERSION}-1.x86_64.rpm"
	rpm -ivh /tmp/cosign.rpm
	rm -f /tmp/cosign.rpm
fi

log "Installing Barbatos layered packages"
LAYERED_PACKAGES=(
	# Configuration / dotfiles management
	chezmoi

	# Shells
	fish
	starship
	zsh

	# Niri / Wayland session
	niri noctalia-shell
	xwayland-satellite vicinae
	mako fuzzel swaybg foot
	grim slurp wl-clipboard
	wlsunset swaylock swayidle
	light cliphist
	polkit-gnome
	cava qt6-qtmultimedia

	# Terminals & editors
	ghostty helix kitty

	# Theming / display
	matugen brightnessctl ddcutil
	ImageMagick fira-code-fonts
	python3

	# Hardware (Thinkpad fan control)
	thinkfan

	# Security / sync / storage
	yubikey-manager
	syncthing syncthing-tools
	sqlite
)
retry_dnf 5 dnf5 install --refresh --setopt=install_weak_deps=False -y \
	"${LAYERED_PACKAGES[@]}"

log "Disabling Copr repos that we only needed at build time"
if [[ -f /tmp/barbatos/copr-repos ]]; then
	while read -r repo; do
		[[ -z "${repo}" ]] && continue
		dnf5 -y copr disable "${repo}"
	done </tmp/barbatos/copr-repos
fi

log "Disabling Terra repo"
for repo in /etc/yum.repos.d/terra*.repo; do
	if [[ -f "${repo}" ]]; then
		sed -i 's@enabled=1@enabled=0@g' "${repo}"
	fi
done
