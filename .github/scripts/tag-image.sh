#!/bin/bash
# Tag and push Docker images by digest to avoid manifest lists
# Usage: tag-image.sh <digest> <registry> <username> <image-name> <platforms> <hash-tag> <version-tag>

set -e

DIGEST="${1:?Digest required}"
REGISTRY="${2:?Registry required}"
USERNAME="${3:?Username required}"
IMAGE_NAME="${4:?Image name required}"
PLATFORMS="${5:?Platforms required (e.g., amd64,arm64)}"
HASH_TAG="${6:?Hash tag required}"
VERSION_TAG="${7:?Version tag required}"

IFS=',' read -ra PLATFORM_ARRAY <<< "$PLATFORMS"

for platform in "${PLATFORM_ARRAY[@]}"; do
  # Normalize platform name (linux/amd64 -> amd64)
  arch="${platform##*/}"

  # GHCR tags
  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${HASH_TAG}-${arch}"
  docker push "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${HASH_TAG}-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${VERSION_TAG}-${arch}"
  docker push "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${VERSION_TAG}-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:latest-${arch}"
  docker push "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:latest-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:stable-${arch}"
  docker push "${REGISTRY}/${USERNAME}/${IMAGE_NAME}:stable-${arch}"

  # Docker Hub tags
  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${USERNAME}/${IMAGE_NAME}:${HASH_TAG}-${arch}"
  docker push "${USERNAME}/${IMAGE_NAME}:${HASH_TAG}-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${USERNAME}/${IMAGE_NAME}:${VERSION_TAG}-${arch}"
  docker push "${USERNAME}/${IMAGE_NAME}:${VERSION_TAG}-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${USERNAME}/${IMAGE_NAME}:latest-${arch}"
  docker push "${USERNAME}/${IMAGE_NAME}:latest-${arch}"

  docker tag "${REGISTRY}/${USERNAME}/${IMAGE_NAME}@${DIGEST}" \
    "${USERNAME}/${IMAGE_NAME}:stable-${arch}"
  docker push "${USERNAME}/${IMAGE_NAME}:stable-${arch}"
done
