#!/bin/bash

set -ouex pipefail

# trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

## Set a group for github actions logs
function echo_group() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	local WHAT
	WHAT="$(
		basename "$1" .sh |
			tr "-" " " |
			tr "_" " "
	)"
	echo "::group:: == ${WHAT^^} =="
	if (( had_xtrace )); then
		set -x
	fi
	"$1"
	if (( had_xtrace )); then
		set +x
	fi
	echo "::endgroup::"
	if (( had_xtrace )); then
		set -x
	fi
}

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '== %s ==\n' "$*"
	if (( had_xtrace )); then
		set -x
	fi
}

set +x
log "Starting Barbatos build process - Inspired by VeneOS, AmyOS and m2os"
set -x

case "$BASE_IMAGE" in
*"/bazzite"* | *"/aurora"*)
	# Removing the Tuxedo step until we figure out the build error on Fedora 43.
	# Example: https://github.com/gagbo/barbatos/actions/runs/18904270020/job/53974623145
	# echo_group /ctx/tuxedo.sh
	echo_group /ctx/displaylink.sh
	echo_group /ctx/desktop-packages.sh
	echo_group /ctx/just-files.sh
	echo_group /ctx/desktop-defaults.sh
	;;
*"/ucore"*) ;;
esac

set +x
log "Post build cleanup"
set -x
echo_group /ctx/cleanup.sh
