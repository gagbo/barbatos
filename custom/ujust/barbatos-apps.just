# vim: set ft=make :
########################
### barbatos-apps.just
########################
## Application installation commands for Barbatos

# Install all Barbatos apps (generic + gaming + work Flatpaks)
[group('Apps')]
install-apps: install-generic-apps install-gaming-apps install-work-apps

# Install all Barbatos CLIs via Homebrew
[group('Apps')]
install-clis:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing Brews"
    brew bundle install --upgrade --file /usr/share/barbatos/homebrew/main.Brewfile
    echo "Brew installation complete."

[private]
_install-flatpak-list file:
    #!/usr/bin/env bash
    set -euo pipefail
    FLATPAK_DIR="/usr/share/barbatos/flatpaks"
    echo "Installing {{ file }} Flatpaks..."
    while IFS= read -r app || [[ -n "$app" ]]; do
      [[ -z "$app" ]] && continue
      if ! flatpak info --system "$app" &>/dev/null; then
        flatpak --system -y install "$app"
      else
        flatpak --system -y update "$app" || true
      fi
    done < "${FLATPAK_DIR}/{{ file }}"
    echo "Flatpaks installation complete."

# Install Satty (not published on Flathub, installed from GitHub release)
[private]
_install-satty:
    ujust sudoif bash /usr/share/barbatos/just/satty.sh

# Install generic Flatpaks
[group('Apps')]
install-generic-apps: (_install-flatpak-list "generic") _install-satty

# Install gaming Flatpaks
[group('Apps')]
install-gaming-apps: (_install-flatpak-list "gaming")

# Install work Flatpaks
[group('Apps')]
install-work-apps: (_install-flatpak-list "work")

# Noctalia v5 is layered in the image.
[group('Apps')]
install-noctalia-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Noctalia v5 is installed in Barbatos as the noctalia-git package."
    echo "Run it in niri with: spawn-at-startup \"noctalia\""
    echo "Docs: https://docs.noctalia.dev/v5/compositor-settings/niri/"
