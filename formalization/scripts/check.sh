#!/usr/bin/env bash
# Build the project and require axiom reports for all six analytical theorems.
# This Unix entry point was not executed during the Windows verification run.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p logs
python3 scripts/static_check.py | tee logs/static-check.txt
if ! command -v lake >/dev/null 2>&1; then
  echo 'BLOCKED: lake/Lean toolchain is not installed. No Lean compilation performed.' | tee logs/lean-build.log
  exit 127
fi
lake --version | tee logs/lean-version.txt
lake env lean --version | tee -a logs/lean-version.txt
# Run lake update and lake exe cache get beforehand on first setup.
lake build 2>&1 | tee logs/lean-build.log
lake env lean Audit.lean 2>&1 | tee logs/lean-axioms.log
python3 scripts/check_axioms.py --require-core --output logs/lean-axiom-status.json
printf '%s\n' 'PROJECT BUILD AND REQUIRED CORE AXIOM AUDIT PASSED.' \
  'See VERIFICATION_REPORT.md for the exact theorem statements and verified scope.'
