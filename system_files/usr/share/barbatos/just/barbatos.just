[private]
default:
    @just --list

# Install all Barbatos apps
[group('Barbatos')]
@barb-install-apps:
  just barb-install-generic
  just barb-install-gaming
  just barb-install-work

# Install all Barbatos CLIs
[group('Barbatos')]
@barb-install-clis:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Installing Brews"
  brew bundle install --upgrade --file /usr/share/barbatos/homebrew/main.Brewfile
  echo "Brew installation complete."

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

# Ensure swap partition big enough to hibernate (useful for laptops)
# Note: This consumes the RAM size as disk space
[group('Barbatos')]
barb-enable-hibernate:
  #!/usr/bin/env bash
  set -exuo pipefail
  
  SWAP_FILE=/var/swap/swapfile
  SWAP_FOLDER=/var/swap
  TOTAL_RAM=$(free -g | grep Mem: | awk '{print $2}')
  
  # We run the script if zram is active
  
  if [[ ! -s /etc/systemd/zram-generator.conf ]]; then
    echo "zram generator configuration doesn’t exist"
  fi
  
  if [[ $(swapon --show --noheadings | grep -v zram) ]]; then
    echo "Found a non-zram swap volume, skipping the rest."
    exit 0
  fi
  
  sudo btrfs subvolume create "$SWAP_FOLDER"
  sudo semanage fcontext -a -t var_t "$SWAP_FOLDER"
  sudo restorecon "$SWAP_FOLDER"
  
  sudo btrfs filesystem mkswapfile --size "${TOTAL_RAM}g" "$SWAP_FILE"
  sudo semanage fcontext -a -t swapfile_t "$SWAP_FILE"
  sudo restorecon "$SWAP_FILE"
  
  sudo swapon "$SWAP_FILE"
  
  sudo mv /etc/fstab{,.bak}
  
  echo "${SWAP_FILE} none swap defaults,nofail 0 0" | sudo tee --append /etc/fstab
  
  sudo truncate -s 0 /etc/systemd/zram-generator.conf
  
