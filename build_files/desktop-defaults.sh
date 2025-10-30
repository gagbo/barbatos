#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  set +x
  echo "=== $* ==="
  set -x
}

log "Enable podman socket"
systemctl enable podman.socket
