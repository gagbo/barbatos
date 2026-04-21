#!/usr/bin/bash
set ${SET_X:+-x} -euo pipefail

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

log "Starting system cleanup"

# Clean package manager cache
dnf5 clean all

# Clean temporary files
rm -rf /usr/etc
rm -rf ~/rpmbuild

log "Cleanup completed"

bootc container lint
ostree container commit
