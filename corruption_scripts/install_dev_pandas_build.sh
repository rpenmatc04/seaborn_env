#!/usr/bin/env bash
#
# Replace the stable pandas release with a bleeding-edge nightly build.
# The API surface occasionally changes in subtle ways, which can expose
# assumptions hidden in downstream libraries.
#
# Usage:
#   ./corruption_scripts/install_dev_pandas_build.sh

set -euo pipefail

echo "[corruption] Installing pandas nightly build from PyPI..."
python -m pip install --no-cache-dir --pre --upgrade --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple pandas

echo "[corruption] pandas nightly installed."
