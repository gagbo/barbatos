#!/usr/bin/env bash

set -euxo pipefail

# Sign container images with cosign
# This script signs all tagged images using the cosign private key

source build.env

echo "Signing images with cosign..."

# Verify cosign is available
if ! command -v cosign &> /dev/null; then
    echo "Error: cosign command not found"
    exit 1
fi

echo "Cosign version:"
cosign version

set +x
export SIGNING_KEY=`echo "${COSIGN_PRIVATE_KEY:?private key unset}" | base64 -d`
set -x

# Sign each tagged image
for tag in "${TAGS[@]}"; do
    IMAGE_FULL="${IMAGE_REGISTRY}/${IMAGE_NAME}:${tag}"
    echo "Signing image: ${IMAGE_FULL}"
    cosign sign -y --key env://SIGNING_KEY "${IMAGE_FULL}"
    echo "Successfully signed: ${IMAGE_FULL}"
done

unset SIGNING_KEY

echo "All images signed successfully"
