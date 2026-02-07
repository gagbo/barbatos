
#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  set +x
  echo "=== $* ==="
  set -x
}

log "Installing RPM packages"

log "Enable Copr repos"

COPR_REPOS=(
    scottames/ghostty
    errornointernet/quickshell
    ulysg/xwayland-satellite
    ublue-os/akmods
    avengemedia/dms
)
for repo in "${COPR_REPOS[@]}"; do
    dnf5 -y copr enable "$repo"
done

log "Enable repositories"
# Bazzite disabled this for some reason so lets re-enable it again
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1 || true

log "Install layered applications"

# Layered Applications
LAYERED_PACKAGES=(
    ansible git cosign
    chezmoi
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

    dms
    polkit-kde brightnessctl
    xdg-desktop-portal evolution-data-server
    ddcutil

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
