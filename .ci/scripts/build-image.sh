#!/usr/bin/env bash

set -euxo pipefail

# Build container image with buildah, then rechunk for optimal bootc updates.

source build.env

echo "Building container image: ${IMAGE_NAME}"
echo "Labels: ${LABEL_ARGS[*]}"
echo "Tags: ${TAGS[*]}"
echo "Build: ${BUILD_DATE}"
echo "Date: ${DATE_TAG}"

buildah build \
    --file ./Containerfile \
    --format docker \
    --layers \
    "${LABEL_ARGS[@]}" \
    --tag "${IMAGE_NAME}:latest" \
    .

echo "Image built successfully: ${IMAGE_NAME}:latest"

# Rechunk for smaller incremental updates (bootc-base-imagectl).
# The binary ships inside the built image itself.
echo "Rechunking image for optimal bootc delta updates"
podman run --rm --privileged \
    -v /var/lib/containers:/var/lib/containers \
    --entrypoint /usr/libexec/bootc-base-imagectl \
    "${IMAGE_NAME}:latest" \
    rechunk --max-layers 67 \
    "${IMAGE_NAME}:latest" \
    "${IMAGE_NAME}:latest"

echo "Rechunking complete"

for tag in "${TAGS[@]}"; do
    echo "Tagging image as ${IMAGE_NAME}:${tag}"
    buildah tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${tag}"
done

echo "Image build and tagging complete"
