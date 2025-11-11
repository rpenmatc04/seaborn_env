#!/usr/bin/env bash
#
# Artificially restrict the level of threading available to BLAS-backed
# numerical libraries. This can expose performance assumptions in code that
# expects wide parallelism.
#
# Usage:
#   ./corruption_scripts/limit_numpy_threads.sh

set -euo pipefail

profile_snippet="/etc/profile.d/blas_thread_limits.sh"
cat <<'SH' > "${profile_snippet}"
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
SH

chmod +x "${profile_snippet}"
echo "[corruption] Configured BLAS libraries to run single-threaded. Restart your shell." 
