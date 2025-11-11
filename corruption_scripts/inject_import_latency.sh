#!/usr/bin/env bash
#
# Inject a small delay into every Python interpreter startup to simulate
# high-latency environments. This makes import-heavy workloads noticeably
# slower without preventing the container from functioning.
#
# Usage:
#   ./corruption_scripts/inject_import_latency.sh
#
# Run this after the docker image has finished building.

set -euo pipefail

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
sitecustomize_file="${sitecustomize_dir}/sitecustomize.py"

touch "${sitecustomize_file}"
if ! grep -q "import time" "${sitecustomize_file}"; then
  echo "import time" >> "${sitecustomize_file}"
fi

if ! grep -q "inject_import_latency" "${sitecustomize_file}"; then
  cat <<'PY' >> "${sitecustomize_file}"
# Added by inject_import_latency.sh
try:
    time.sleep(0.35)
except Exception:  # pragma: no cover - defensive fallback
    pass
PY
fi

echo "[corruption] Injected import latency via sitecustomize."
