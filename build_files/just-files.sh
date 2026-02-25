#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  set +x
  echo "=== $* ==="
  set -x
}

log "Adding Barbatos just recipes"

BARB_IMPORT='import "/usr/share/barbatos/just/barbatos.just"'
ENTRY_JUST="/usr/share/ublue-os/just/00-entry.just"
CUSTOM_JUST="/usr/share/ublue-os/just/60-custom.just"
LEGACY_JUSTFILE="/usr/share/ublue-os/justfile"

# Aurora's ujust loads 00-entry.just, which includes 60-custom.just.
# Write our import there so recipes are visible in `ujust --list`.
if [[ -f "${ENTRY_JUST}" ]]; then
  touch "${CUSTOM_JUST}"
  if ! grep -Fxq "${BARB_IMPORT}" "${CUSTOM_JUST}"; then
    echo "${BARB_IMPORT}" >> "${CUSTOM_JUST}"
  fi
else
  # Fallback for layouts that still load /usr/share/ublue-os/justfile directly.
  if ! grep -Fxq "${BARB_IMPORT}" "${LEGACY_JUSTFILE}"; then
    echo "${BARB_IMPORT}" >> "${LEGACY_JUSTFILE}"
  fi
fi

log "Hide incompatible Bazzite just recipes"
for recipe in "bazzite-cli" "install-coolercontrol" "install-openrgb" ; do
  if ! grep -l "^$recipe:" /usr/share/ublue-os/just/*.just | grep -q .; then
    echo "Warning: Recipe $recipe not found in any just file"
    continue
  fi
  sed -i "s/^$recipe:/_$recipe:/" /usr/share/ublue-os/just/*.just
done
