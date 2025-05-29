[private]
default:
    @just --list

# Install all VeneOS apps
[group('Install')]
barb-install: barb-install-flatpaks

# Install Flatpaks
[group('Install')]
barb-install-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Flatpaks..."
  xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/gagbo/barbatos/main/etc/flatpaks) flatpak --system -y install
  echo "Flatpaks installation complete."

