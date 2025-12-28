#!/usr/bin/env bash

set -euo pipefail

# Generate metadata for container image builds
# This script generates tags and labels for the container image

# Generate current date in ISO 8601 format
export BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
export DATE_TAG=$(date -u +%Y%m%d)

echo "Build date: ${BUILD_DATE}"
echo "Date tag: ${DATE_TAG}"

# Generate tags based on pipeline context
if [ "${CI_PIPELINE_SOURCE:-}" == "merge_request_event" ]; then
    # For merge requests, use SHA and MR number
    TAGS=("sha-${CI_COMMIT_SHORT_SHA}" "mr-${CI_MERGE_REQUEST_IID}")
    echo "Merge request build detected"
else
    # For main branch and schedules, use standard tags
    TAGS=("latest" "latest.${DATE_TAG}" "${DATE_TAG}")
    echo "Standard build detected"
fi

export TAGS
echo "Generated tags: ${TAGS[@]}"

# Generate label arguments for buildah
LABEL_ARGS=(
    --label "io.artifacthub.package.readme-url=https://gitlab.com/${CI_PROJECT_PATH}/-/blob/${CI_DEFAULT_BRANCH}/README.md"
    --label "org.opencontainers.image.created=${BUILD_DATE}"
    --label "org.opencontainers.image.description=\"${IMAGE_DESC}\""
    --label "org.opencontainers.image.documentation=https://gitlab.com/${CI_PROJECT_PATH}/-/blob/${CI_DEFAULT_BRANCH}/README.md"
    --label "org.opencontainers.image.source=https://gitlab.com/${CI_PROJECT_PATH}/-/blob/${CI_DEFAULT_BRANCH}/Containerfile"
    --label "org.opencontainers.image.title=${IMAGE_NAME}"
    --label "org.opencontainers.image.url=https://gitlab.com/${CI_PROJECT_PATH}"
    --label "org.opencontainers.image.vendor=${CI_PROJECT_NAMESPACE}"
    --label "org.opencontainers.image.version=latest"
    --label "org.opencontainers.image.revision=${CI_COMMIT_SHA}"
    --label "io.artifacthub.package.deprecated=false"
    --label "io.artifacthub.package.keywords=bootc,ublue,universal-blue"
    --label "io.artifacthub.package.license=Apache-2.0"
    --label "io.artifacthub.package.logo-url=${ARTIFACTHUB_LOGO_URL}"
    --label "io.artifacthub.package.prerelease=false"
    --label "containers.bootc=1"
)

export LABEL_ARGS
echo "Generated label arguments: ${LABEL_ARGS[@]}"

# Save to environment file for GitLab CI
{
    declare -p BUILD_DATE
    declare -p DATE_TAG
    declare -p TAGS
    declare -p LABEL_ARGS
} >> build.env

cat build.env

{
    echo "BUILD_DATE=${BUILD_DATE@Q}"
    echo "DATE_TAG=${DATE_TAG@Q}"
    echo "TAGS=${TAGS[*]@Q}"
    echo "LABEL_ARGS=${LABEL_ARGS[*]@Q}"
} >> report.env

echo "Metadata generation complete"
