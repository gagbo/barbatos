#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  local had_xtrace=0
  if [[ $- == *x* ]]; then
    had_xtrace=1
    set +x
  fi
  printf '=== %s ===\n' "$*"
  if (( had_xtrace )); then
    set -x
  fi
}

log "Enable podman socket"
systemctl enable podman.socket
