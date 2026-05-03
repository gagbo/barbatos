#!/usr/bin/bash
# Phase 55 - Generate /usr/share/ublue-os/image-info.json
#
# The motd system and several ujust recipes (changelog, toggle-devmode)
# expect this file. Upstream Bluefin generates it during their build;
# since Barbatos builds on silverblue-main directly, we must create it.

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

log "Generating image-info.json"

IMAGE_NAME="${IMAGE_NAME:-barbatos}"
IMAGE_VENDOR="${IMAGE_VENDOR:-gagbo}"
FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-43}"
SHA_HEAD_SHORT="${SHA_HEAD_SHORT:-}"

# image-ref follows the OCI reference convention used by bootc
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_TAG="stable"
IMAGE_FLAVOR="main"

install -d -m 0755 /usr/share/ublue-os

cat > /usr/share/ublue-os/image-info.json <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "${IMAGE_REF}",
  "image-tag": "${IMAGE_TAG}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "fedora-version": "${FEDORA_MAJOR_VERSION}",
  "sha-head-short": "${SHA_HEAD_SHORT}"
}
EOF

log "image-info.json written:"
cat /usr/share/ublue-os/image-info.json
