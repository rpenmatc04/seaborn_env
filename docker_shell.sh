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
CONTAINER_NAME="seaborn-shell-${IMAGE_SUFFIX}"

echo "[docker-shell] Building Docker image..." >&2
echo "docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} ." >&2
echo "" >&2

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

echo "" >&2
echo "===========================================================" >&2
echo "Docker image built: ${IMAGE_NAME}" >&2
echo "===========================================================" >&2
echo "" >&2
echo "You are now entering an interactive shell in the container." >&2
echo "" >&2
echo "To run tests manually, try any of these commands:" >&2
echo "  make test           # Run Makefile test target" >&2
echo "  pytest tests/       # Run pytest on tests directory" >&2
echo "  pytest tests/test_distributions.py  # Run specific test file" >&2
echo "  python -c 'import seaborn; print(seaborn.__version__)'  # Quick import check" >&2
echo "" >&2
echo "To exit the container, type: exit" >&2
echo "===========================================================" >&2
echo "" >&2

docker run --rm -it \
  --name "$CONTAINER_NAME" \
  -v "$(pwd)":/app \
  -w /app \
  -e MPLBACKEND=Agg \
  -e PYDEVD_DISABLE_FILE_VALIDATION=1 \
  "$IMAGE_NAME" \
  bash

