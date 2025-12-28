#!/usr/bin/env bash

set -euxo pipefail

# Install cosign for container image signing
COSIGN_VERSION="${COSIGN_VERSION:-v2.4.1}"
COSIGN_BINARY="cosign-linux-amd64"
COSIGN_URL="https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/${COSIGN_BINARY}"

echo "Installing cosign ${COSIGN_VERSION}..."

curl -sLO "${COSIGN_URL}"
chmod +x "${COSIGN_BINARY}"
mv "${COSIGN_BINARY}" /usr/local/bin/cosign

# Verify installation
cosign version

echo "Cosign installed successfully"
