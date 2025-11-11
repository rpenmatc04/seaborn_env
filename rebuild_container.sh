#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "Rebuilding Seaborn Docker Container"
echo "=========================================="
echo ""
echo "This will rebuild the Docker container with the"
echo "current pyproject.toml dependencies."
echo ""
echo "All dependencies are installed during the Docker"
echo "build - the test scripts do NOT install anything."
echo ""
echo "=========================================="
echo ""

# Remove old images to force clean rebuild
echo "Cleaning up old images..."
docker rmi seaborn-env:canonical 2>/dev/null || true
echo ""

echo "Building new container..."
echo "Command: docker build -t seaborn-env:canonical -f Dockerfile ."
echo ""

docker build -t seaborn-env:canonical -f Dockerfile .

echo ""
echo "=========================================="
echo "✓ Container rebuilt successfully!"
echo "=========================================="
echo ""
echo "Now you can enter the container and run tests:"
echo "  ./docker_shell.sh"
echo "  ./run_tests.sh"
echo ""
echo "All dependencies should be pre-installed from"
echo "the Docker build. No additional installation"
echo "should be needed."
echo ""

