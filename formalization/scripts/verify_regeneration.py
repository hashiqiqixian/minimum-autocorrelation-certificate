"""Regenerate exact certificate artifacts and reject source drift.

Run before the clean Lean rebuild, never concurrently with a Lean build.
This is a reproducibility check, not a replacement for Lean verification.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
paths = sorted((ROOT / 'Autocorrelation').rglob('*.lean')) + [ROOT / 'bernstein_leaves.json']
before = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
result = subprocess.run([sys.executable, str(ROOT / 'scripts/generate.py')], cwd=ROOT)
if result.returncode:
    sys.exit(result.returncode)
after = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
changed = [name for name in before if before[name] != after[name]]
report = {'scope': 'exact_generator_reproducibility_not_Lean_proof',
          'changed_artifacts': changed, 'source_sha256': after, 'passed': not changed}
(ROOT / 'logs/current-run/regeneration-check.json').write_text(
    json.dumps(report, indent=2) + '\n', encoding='utf-8')
if changed:
    sys.exit('FAIL: regeneration changed artifacts: ' + ', '.join(changed))
print('PASS: regeneration preserves every existing project Lean source and certificate leaf artifact.')
