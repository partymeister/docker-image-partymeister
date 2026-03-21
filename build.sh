#!/usr/bin/env bash
set -euo pipefail
[[ -f .env ]] && set -a && source .env && set +a

BUILDER="my-builder"
PLATFORMS="linux/amd64,linux/arm64"

IMAGE="${1:?Usage: $0 <php-84|php-85|screenshots> <version> [prod|dev|all]}"
VERSION="${2:?Usage: $0 <php-84|php-85|screenshots> <version> [prod|dev|all]}"
TARGET="${3:-all}"

case "$IMAGE" in
    php-84)
        REPO="dfox288/partymeister-php-84"
        CONTEXT="php-84"
        ;;
    php-85)
        REPO="dfox288/partymeister-php-85"
        CONTEXT="php-85"
        ;;
    screenshots)
        REPO="dfox288/partymeister-screenshots-base"
        CONTEXT="screenshots"
        ;;
    *)
        echo "Unknown image: $IMAGE (use php-84, php-85, or screenshots)" && exit 1
        ;;
esac

build() {
    local target="$1" suffix="$2"
    echo "Building ${IMAGE}/${target} v${VERSION}..."
    docker buildx build \
        --builder "$BUILDER" \
        --platform "$PLATFORMS" \
        --target "$target" \
        -f "${CONTEXT}/Dockerfile" \
        -t "${REPO}-${suffix}:${VERSION}" \
        -t "${REPO}-${suffix}:latest" \
        --push --no-cache --pull "${CONTEXT}"
}

build_single() {
    echo "Building ${IMAGE} v${VERSION}..."
    docker buildx build \
        --builder "$BUILDER" \
        --platform "$PLATFORMS" \
        -f "${CONTEXT}/Dockerfile" \
        -t "${REPO}:${VERSION}" \
        -t "${REPO}:latest" \
        --push --no-cache --pull "${CONTEXT}"
}

if [[ "$IMAGE" == "screenshots" ]]; then
    build_single
else
    case "$TARGET" in
        prod) build production prod ;;
        dev)  build dev dev ;;
        all)  build production prod && build dev dev ;;
        *)    echo "Unknown target: $TARGET (use prod, dev, or omit for both)" && exit 1 ;;
    esac
fi

echo "Done"
