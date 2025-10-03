
#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing RPM packages"

log "Enable Copr repos"

COPR_REPOS=(
    alternateved/ghostty
    ulysg/xwayland-satellite
)
for repo in "${COPR_REPOS[@]}"; do
    dnf5 -y copr enable "$repo"
done

log "Enable repositories"
# Bazzite disabled this for some reason so lets re-enable it again
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1
tee /etc/yum.repos.d/tuxedo.repo <<EOF
[repository]
name=tuxedo
baseurl=https://rpm.tuxedocomputers.com/fedora/${FEDORA_VERSION:-43}/x86_64/base
enabled=1
gpgcheck=0
EOF

log "Install layered applications"

# file /usr/share/terminfo/g/ghostty from install of ghostty-1.1.3-1.git8a00aa8.20250528git8a00aa8.fc42.x86_64 conflicts with file from package ncurses-term-6.5-5.20250125.fc42.noarch
dnf5 remove -y ncurses-term

# Layered Applications
LAYERED_PACKAGES=(
    dkms tuxedo-drivers tuxedo-control-center
    
    ansible git cosign
    podman-compose
    podman-remote

    fish
    starship zoxide
    zsh

    atuin bat btop direnv
    eza gh ripgrep jq

    cockpit
    cockpit-machines
    cockpit-ostree
    cockpit-sosreport

    ghostty
    helix neovim
    fira-code-fonts

    niri waybar wlsunset swaylock swayidle
    mako fuzzel swaybg light flameshot foot
    xwayland-satellite

    nodejs nodejs-npm pnpm

    sqlite
    yubikey-manager
)
dnf5 install --setopt=install_weak_deps=False -y "${LAYERED_PACKAGES[@]}"

log "Disable Copr repos as we do not need it anymore"

for repo in "${COPR_REPOS[@]}"; do
    dnf5 -y copr disable "$repo"
done
# Use flatpak steam with some addons instead
# rpm-ostree override remove steam
log "Removing Steam from Bazzite install, please use flatpak instead"
dnf5 -y remove steam
