#!/usr/bin/bash
set ${SET_X:+-x} -euo pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  set +x
  echo "=== $* ==="
  set -x
}

log "Starting system cleanup"

# Clean package manager cache
dnf5 clean all

# Clean temporary files
rm -rf /usr/etc
rm -rf ~/rpmbuild

log "Cleanup completed"

bootc container lint
ostree container commit
