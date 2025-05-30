#!/bin/bash

set -ouex pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

## Set a group for github actions logs
function echo_group() {
    local WHAT
    WHAT="$(
        basename "$1" .sh |
            tr "-" " " |
            tr "_" " "
    )"
    echo "::group:: == ${WHAT^^} =="
    "$1"
    echo "::endgroup::"
}

log() {
  echo "== $* =="
}

log "Starting Barbatos build process - Inspired by VeneOS, AmyOS and m2os"

case "$BASE_IMAGE" in
*"/bazzite"*)
    echo_group /ctx/desktop-packages.sh
    echo_group /ctx/just-files.sh
    echo_group /ctx/desktop-defaults.sh
    ;;
*"/ucore"*) ;;
esac


log "Post build cleanup"
echo_group /ctx/cleanup.sh
