"""Check installed git revisions against the locked Lake manifest."""
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT / 'lake-manifest.json').read_text(encoding='utf-8'))
results = {}

def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args],
                                   timeout=20, text=True, encoding='utf-8').strip()

for package in manifest['packages']:
    path = ROOT / '.lake/packages' / package['name']
    revision = git(path, 'rev-parse', 'HEAD')
    if revision != package['rev']:
        raise SystemExit('FAIL locked revision: ' + package['name'])
    changed = git(path, 'diff', 'HEAD', '--name-only').splitlines()
    allowed = ['Cache/IO.lean'] if package['name'] == 'mathlib' else []
    if changed != allowed:
        raise SystemExit('FAIL unexpected tracked modifications: ' + package['name'] + ': ' + repr(changed))
    results[package['name']] = {'revision': revision, 'tracked_changes': changed}

mathlib = ROOT / '.lake/packages/mathlib'
if git(mathlib, 'rev-parse', 'v4.19.0^{commit}') != results['mathlib']['revision']:
    raise SystemExit('FAIL: mathlib official tag does not match the lock')
patch = (ROOT / 'scripts/patches/mathlib-cache-single-worker.patch').read_text(encoding='utf-8')
actual = git(mathlib, 'diff', '--', 'Cache/IO.lean')
if actual.strip() != patch.strip():
    raise SystemExit('FAIL: cache tooling modification differs from recorded patch')
(ROOT / 'logs/current-run/dependency-final-check.json').write_text(
    json.dumps({'passed': True, 'packages': results,
                'cache_patch_matches_record': True}, indent=2) + '\n', encoding='utf-8')
print('PASS: all %d dependency revisions match; the only tracked change is the recorded cache worker patch.' % len(results))
