#!/usr/bin/env bash
# Manual test runner script - run this inside the Docker container
set -euo pipefail

echo "========================================"
echo "Seaborn Test Runner (Full Suite)"
echo "========================================"
echo ""

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FAILED=0

# Dependency check function
check_dependency() {
  local dep_name="$1"
  local check_cmd="$2"
  
  if eval "$check_cmd" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Step 0: Check dependencies
echo -e "${BLUE}[0/4] Checking Dependencies${NC}"
echo "Verifying all required tools are installed in this container..."
echo ""


# Test 2: make test (requires pytest-cov and pytest-xdist)
echo -e "${BLUE}[2/4] Running: make test${NC}"
echo "This runs: pytest -n auto --cov=seaborn --cov=tests --cov-config=setup.cfg tests"
echo ""

if make test; then
  echo ""
  echo -e "${GREEN}✓ make test PASSED${NC}"
  echo ""
else
  echo ""
  echo -e "${RED}✗ make test FAILED${NC}"
  echo ""
  FAILED=1
fi

# Test 3: pytest tests/ (basic, no plugins required)
echo -e "${BLUE}[3/4] Running: pytest tests/${NC}"
echo "This runs all tests without coverage or parallelization"
echo ""

if pytest tests/; then
  echo ""
  echo -e "${GREEN}✓ pytest tests/ PASSED${NC}"
  echo ""
else
  echo ""
  echo -e "${RED}✗ pytest tests/ FAILED${NC}"
  echo ""
  FAILED=1
fi

# Test 4: Show installed package versions
echo -e "${BLUE}[4/4] Installed Package Versions${NC}"
echo "Showing what was installed during Docker build:"
echo ""

python3 -c "
import sys
packages = ['pytest', 'pytest_cov', 'xdist', 'numpy', 'pandas', 'matplotlib', 'scipy', 'seaborn']
for pkg in packages:
    try:
        mod = __import__(pkg)
        version = getattr(mod, '__version__', 'unknown')
        print(f'  ✓ {pkg:20} {version}')
    except ImportError:
        print(f'  ✗ {pkg:20} NOT INSTALLED')
"

echo ""

# Summary
echo "========================================"
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
else
  echo -e "${RED}✗ SOME TESTS FAILED${NC}"
fi
echo "========================================"
echo ""
echo "Other useful commands:"
echo "  pytest tests/test_<name>.py  # Run specific test file"
echo "  pytest tests/ -v             # Verbose output"
echo "  pytest tests/ -k <pattern>   # Run tests matching pattern"
echo "  pytest tests/ --maxfail=3    # Stop after 3 failures"
echo "  pytest --cov=seaborn tests/  # Run with coverage (if pytest-cov installed)"
echo ""

exit $FAILED

