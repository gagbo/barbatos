#!/usr/bin/bash
# Phase 20 - Enable third-party repos (Copr + Terra)
#
# Repos are disabled again at the end of phase 30 so they do not stay enabled
# on running systems.

set ${SET_X:+-x} -eou pipefail

log() {
	local had_xtrace=0
	if [[ $- == *x* ]]; then
		had_xtrace=1
		set +x
	fi
	printf '=== %s ===\n' "$*"
	if ((had_xtrace)); then set -x; fi
}

retry_dnf() {
	local max_attempts="$1"
	shift

	local attempt=1
	local status=0
	until "$@"; do
		status="$?"
		if ((attempt >= max_attempts)); then
			return "$status"
		fi
		log "DNF command failed, cleaning metadata and retrying (${attempt}/${max_attempts})"
		dnf5 clean all || true
		sleep $((attempt * 5))
		((attempt++))
	done
}

configure_terra_repos() {
	for repo in /etc/yum.repos.d/terra*.repo; do
		if [[ -f "${repo}" ]]; then
			sed -i \
				-e 's@enabled=0@enabled=1@g' \
				-e 's@skip_if_unavailable=True@skip_if_unavailable=False@g' \
				-e 's@skip_if_unavailable=true@skip_if_unavailable=False@g' \
				"${repo}"
		fi
	done
}

log "Enabling Copr repos"
COPR_REPOS=(
	scottames/ghostty
	ulysg/xwayland-satellite
	ublue-os/akmods
	quadratech188/vicinae
)
for repo in "${COPR_REPOS[@]}"; do
	dnf5 -y copr enable "${repo}"
done

log "Enabling Terra repo"
configure_terra_repos
retry_dnf 5 dnf5 -y install --refresh --nogpgcheck \
	--repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
	terra-release{,-extras} || true
configure_terra_repos
retry_dnf 5 dnf5 makecache --refresh

# Persist the list of repos for phase 30 to disable later.
mkdir -p /tmp/barbatos
printf '%s\n' "${COPR_REPOS[@]}" >/tmp/barbatos/copr-repos
