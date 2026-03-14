#!/usr/bin/env bash
set -euo pipefail

BUILDER="my-builder"
PLATFORMS="linux/amd64,linux/arm64"
REPO="dfox288/partymeister-screenshots-base"
VERSION="${1:?Usage: $0 <version>}"

echo "Building screenshots base v${VERSION}..."
docker buildx build \
    --builder "$BUILDER" \
    --platform "$PLATFORMS" \
    -f Dockerfile.screenshots \
    -t "${REPO}:${VERSION}" \
    --push --no-cache --pull .

echo "Done"
