#!/bin/bash
# Barbatos build orchestrator
#
# Runs inside the container build on top of a Universal Blue base image
# (silverblue-main by default). The companion OCI containers
# projectbluefin/common and ublue-os/brew are copied into /ctx/oci/* by the
# Containerfile.
#
# Phases:
#   10  Copy OCI container content (common, brew) and our system_files
#   20  Repos (Copr + Terra)
#   30  Layered packages
#   40  Hardware drivers (DisplayLink)
#   50  Just files (drop barbatos.just into ujust's directory)
#   60  Service units (enable podman.socket, etc.)
#   90  Cleanup + bootc lint
#
# Inspired by VeneOS, AmyOS, m2os and modeled after upstream Bluefin's
# build_files/shared/build.sh.

set -ouex pipefail

# Group output for GitHub Actions logs while preserving xtrace state.
echo_group() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	local what
	what="$(basename "$1" .sh | tr -- '-_' '  ')"
	echo "::group:: == ${what^^} =="
	if ((had_xtrace)); then set -x; fi
	"$1"
	if ((had_xtrace)); then set +x; fi
	echo "::endgroup::"
	if ((had_xtrace)); then set -x; fi
}

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '== %s ==\n' "$*"
	if ((had_xtrace)); then set -x; fi
}

set +x
log "Starting Barbatos build (multi-stage / finpilot pattern)"
set -x

echo_group /ctx/build/10-copy-oci.sh
echo_group /ctx/build/20-repos.sh
echo_group /ctx/build/30-packages.sh
echo_group /ctx/build/40-displaylink.sh
echo_group /ctx/build/50-just-files.sh
echo_group /ctx/build/60-services.sh
echo_group /ctx/build/90-cleanup.sh
