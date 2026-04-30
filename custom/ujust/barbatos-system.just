# vim: set ft=make :
###########################
### barbatos-system.just
###########################
## System configuration commands for Barbatos

# Set up swap partition big enough to hibernate (consumes RAM-size disk space)
[group('System')]
setup-hibernate:
    #!/usr/bin/env bash
    set -euo pipefail

    SWAP_FILE=/var/swap/swapfile
    SWAP_FOLDER=/var/swap
    TOTAL_RAM=$(free -g | grep Mem: | awk '{print $2}')

    if [[ ! -s /etc/systemd/zram-generator.conf ]]; then
      echo "zram generator configuration doesn't exist"
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
