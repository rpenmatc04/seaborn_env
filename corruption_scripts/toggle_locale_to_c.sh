#!/usr/bin/env bash
#
# Force the container to use the POSIX "C" locale. Many libraries assume a
# UTF-8 locale and may emit mojibake or fail to parse numbers when this is
# active.
#
# Usage:
#   ./corruption_scripts/toggle_locale_to_c.sh

set -euo pipefail

profile_snippet="/etc/profile.d/locale_corruption.sh"
cat <<'SH' > "${profile_snippet}"
export LANG=C
export LC_ALL=C
SH

chmod +x "${profile_snippet}"
echo "[corruption] Locale forced to C. Spawn a new shell to observe the effects."
