#!/usr/bin/env bash

set -euxo pipefail

# Build container image with buildah
# This script builds the container image using buildah bud command

source build.env

echo "Building container image: ${IMAGE_NAME}"
echo "Labels: ${LABEL_ARGS[@]}"
echo "Tags: ${TAGS[@]}"
echo "Build: ${BUILD_DATE}"
echo "Date: ${DATE_TAG}"

# Build the image with buildah
buildah build \
    --file ./Containerfile \
    --format docker \
    --layers \
    "${LABEL_ARGS[@]}" \
    --tag "${IMAGE_NAME}:latest" \
    .

echo "Image built successfully: ${IMAGE_NAME}:latest"

# Tag the image with all generated tags
for tag in "${TAGS[@]}"; do
    echo "Tagging image as ${IMAGE_NAME}:${tag}"
    buildah tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${tag}"
done

echo "Image build and tagging complete"
