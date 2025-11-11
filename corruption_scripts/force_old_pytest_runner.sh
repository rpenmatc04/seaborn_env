#!/usr/bin/env bash
#
# Force the project to use an older pytest runner and enable strict
# configuration flags that tend to surface brittle tests.
#
# Usage:
#   ./corruption_scripts/force_old_pytest_runner.sh

set -euo pipefail

echo "[corruption] Installing legacy pytest stack..."
python -m pip install --no-cache-dir --force-reinstall "pytest==6.2.5" "pytest-randomly==3.12.0"

echo "[corruption] Enabling strict pytest options via /etc/profile.d..."
profile_snippet="/etc/profile.d/pytest_corruption.sh"
cat <<'SH' > "${profile_snippet}"
export PYTEST_ADDOPTS="--maxfail=1 --strict-config --strict-markers --disable-warnings"
SH

chmod +x "${profile_snippet}"
echo "[corruption] Old pytest installed and strict flags enabled. Open a new shell for them to apply."
