[private]
default:
    @just --list

# Install all Barbatos apps
[group('Barbatos')]
@barb-install-all:
  just barb-install-generic
  just barb-install-gaming
  just barb-install-work

[private]
@barb-install_helper file:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing {{file}} Flatpaks..."
  xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/gagbo/barbatos/main/etc/flatpaks/{{file}}) flatpak --system -y install
  echo "Flatpaks installation complete."

# Install Generic Flatpaks
[group('Barbatos')]
@barb-install-generic:
  just barb-install_helper generic

# Install Gaming Flatpaks
[group('Barbatos')]
@barb-install-gaming:
  just barb-install_helper gaming

# Install Work Flatpaks
[group('Barbatos')]
@barb-install-work:
  just barb-install_helper work

