#!/bin/bash

set -ouex pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

## Set a group for github actions logs
function echo_group() {
	set +x
	local WHAT
	WHAT="$(
		basename "$1" .sh |
			tr "-" " " |
			tr "_" " "
	)"
	echo "::group:: == ${WHAT^^} =="
	set -x
	"$1"
	set +x
	echo "::endgroup::"
	set -x
}

log() {
	echo "== $* =="
}

log "Starting Barbatos build process - Inspired by VeneOS, AmyOS and m2os"

case "$BASE_IMAGE" in
*"/bazzite"* | *"/aurora"*)
	# Removing the Tuxedo step until we figure out the build error on Fedora 43.
	# Example: https://github.com/gagbo/barbatos/actions/runs/18904270020/job/53974623145
	# echo_group /ctx/tuxedo.sh
	echo_group /ctx/desktop-packages.sh
	echo_group /ctx/just-files.sh
	echo_group /ctx/desktop-defaults.sh
	;;
*"/ucore"*) ;;
esac

log "Post build cleanup"
echo_group /ctx/cleanup.sh
