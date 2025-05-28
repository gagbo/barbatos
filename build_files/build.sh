#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tailscale

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 -y copr enable alternateved/ghostty
# file /usr/share/terminfo/g/ghostty from install of ghostty-1.1.3-1.git8a00aa8.20250528git8a00aa8.fc42.x86_64 conflicts with file from package ncurses-term-6.5-5.20250125.fc42.noarch
dnf5 remove -y ncurses-term
dnf5 install -y ghostty
dnf5 -y copr disable alternateved/ghostty

#### Example for enabling a System Unit File

systemctl enable podman.socket
