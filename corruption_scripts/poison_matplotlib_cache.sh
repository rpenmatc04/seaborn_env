#!/usr/bin/env bash
#
# Overwrite the matplotlib configuration so that plots default to an
# off-screen backend and a deliberately garish style. This can surface tests
# that implicitly rely on fonts, DPI, or backends.
#
# Usage:
#   ./corruption_scripts/poison_matplotlib_cache.sh

set -euo pipefail

mpl_config_dir="${MPLCONFIGDIR:-$HOME/.config/matplotlib}"
mkdir -p "${mpl_config_dir}"

cat <<'RC' > "${mpl_config_dir}/matplotlibrc"
backend: agg
figure.figsize: 10, 4
figure.dpi: 54
savefig.dpi: 54
axes.facecolor: #330022
axes.edgecolor: #ffcc00
axes.prop_cycle: cycler(color=['#ff0066', '#00ffaa', '#ffaa00'])
font.family: Comic Sans MS
text.color: #ffeeff
rc: lines.linewidth=4
RC

echo "[corruption] Matplotlib configuration overwritten in ${mpl_config_dir}."
