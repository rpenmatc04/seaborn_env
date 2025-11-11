#!/usr/bin/env bash
#
# Purposefully destabilize the Python environment inside the container.
#
# This script is intended to be run manually after the docker image
# finishes building. It replaces the versions of several scientific
# Python dependencies with older releases that are known to surface
# subtle incompatibilities. The container will still build, but running
# the seaborn test suite (or any code that depends on modern behaviour)
# becomes significantly more challenging.
#
# Usage:
#   ./corruption_scripts/downgrade_core_dependencies.sh
#
# The script must be executed from within the already-built docker
# container. It assumes that ``python`` and ``pip`` point to the
# environment created during ``docker_shell.sh`` / ``run_tests.sh``.

set -euo pipefail

packages=(
  "numpy==1.23.5"
  "pandas==1.5.3"
  "matplotlib==3.6.3"
  "scipy==1.9.3"
)

echo "[corruption] Downgrading scientific Python stack to stress compatibility..."

for spec in "${packages[@]}"; do
  echo "[corruption] Forcing installation of ${spec}"
  python -m pip install --no-cache-dir --force-reinstall --no-deps "${spec}"
done

echo "[corruption] Installing a stray development build of seaborn to shadow local sources..."
python -m pip install --no-cache-dir --pre seaborn==0.13.0.dev0 || true

echo "[corruption] Appending a sitecustomize shim that injects warnings at import time..."
sitecustomize_dir="$(python - <<'PY'
import site
import sys
from pathlib import Path

if site.ENABLE_USER_SITE:
    path = Path(site.getusersitepackages())
else:
    candidates = [Path(p) for p in site.getsitepackages() if "site-packages" in p]
    path = candidates[0] if candidates else Path(sys.prefix) / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages"

print(path)
PY
)"
mkdir -p "${sitecustomize_dir}"
cat <<'PY' > "${sitecustomize_dir}/sitecustomize.py"
import warnings
warnings.filterwarnings(
    "default",
    message=".*This environment has been intentionally corrupted.*",
    category=UserWarning,
)
warnings.warn("This environment has been intentionally corrupted for testing.")
PY

echo "[corruption] Done. Restart your shell to ensure the shim is active."
