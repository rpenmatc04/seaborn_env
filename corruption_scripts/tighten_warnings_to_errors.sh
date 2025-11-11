#!/usr/bin/env bash
#
# Elevate common categories of warnings to errors in order to surface
# deprecated code paths immediately.
#
# Usage:
#   ./corruption_scripts/tighten_warnings_to_errors.sh

set -euo pipefail

profile_snippet="/etc/profile.d/python_warnings_as_errors.sh"
cat <<'SH' > "${profile_snippet}"
export PYTHONWARNINGS="error::FutureWarning,error::DeprecationWarning,error::PendingDeprecationWarning"
SH

chmod +x "${profile_snippet}"
echo "[corruption] Configured Python to treat deprecation warnings as errors."
