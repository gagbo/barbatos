#!/usr/bin/env bash

set -euxo pipefail

# Push container images to GitLab Container Registry
# This script handles registry login and pushing all tagged images

source build.env

echo "Logging in to GitLab Container Registry..."
echo "${CI_REGISTRY_PASSWORD}" | buildah login -u "${CI_REGISTRY_USER}" --password-stdin "${CI_REGISTRY}"

echo "Pushing images to registry..."

# Push all tagged images
for tag in "${TAGS[@]}"; do
    IMAGE_FULL="${IMAGE_REGISTRY}/${IMAGE_NAME}:${tag}"
    echo "Pushing ${IMAGE_FULL}"
    buildah push "${IMAGE_NAME}:${tag}" "${IMAGE_FULL}"
done

echo "All images pushed successfully"
