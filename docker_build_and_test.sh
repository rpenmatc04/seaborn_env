#!/usr/bin/env bash
set -euo pipefail

DOCKERFILE="Dockerfile"
IMAGE_SUFFIX="canonical"

if [[ $# -gt 0 ]]; then
  INPUT="$1"
  if [[ -f "$INPUT" ]]; then
    DOCKERFILE="$INPUT"
  elif [[ -f "dockerfiles/$INPUT" ]]; then
    DOCKERFILE="dockerfiles/$INPUT"
  elif [[ -f "dockerfiles/Dockerfile.$INPUT" ]]; then
    DOCKERFILE="dockerfiles/Dockerfile.$INPUT"
  else
    echo "Unable to locate Dockerfile variant '$INPUT'." >&2
    echo "Provide an existing file path or suffix such as 'variant11'." >&2
    exit 1
  fi
  IMAGE_SUFFIX="$(basename "$DOCKERFILE" | tr '[:upper:]' '[:lower:]' | tr '/' '-')"
fi

IMAGE_NAME="seaborn-env:${IMAGE_SUFFIX}"
CONTAINER_NAME="seaborn-env-test-${IMAGE_SUFFIX}"

echo "[docker-build-and-test] Build command:" >&2
echo "docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} ." >&2

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

echo "[docker-build-and-test] Test command:" >&2
echo "docker run --rm -v \"\$(pwd)\":/app -w /app -e MPLBACKEND=Agg -e PYDEVD_DISABLE_FILE_VALIDATION=1 ${IMAGE_NAME} make test" >&2

docker run --rm --name "$CONTAINER_NAME" \
  -v "$(pwd)":/app \
  -w /app \
  -e MPLBACKEND=Agg \
  -e PYDEVD_DISABLE_FILE_VALIDATION=1 \
  "$IMAGE_NAME" \
  bash -lc "make test && pytest tests"
