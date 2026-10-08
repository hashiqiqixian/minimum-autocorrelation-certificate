"""Package the verified source project and real logs, excluding rebuildable caches.

Run only after the clean verification has finished. The installed tools and
dependency cache remain in the local workspace; the archive pins their versions.
"""
import hashlib
import json
import os
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
clean_files = sorted((ROOT / 'logs/current-run').glob('*_clean-check.json'))
if not clean_files:
    raise SystemExit('No actual clean verification metadata exists')
clean = json.loads(clean_files[-1].read_text(encoding='utf-8-sig'))
if clean['status'] != 'passed' or clean['child_exit_code'] != 0:
    raise SystemExit('Latest clean verification has not passed')
for relative, expected in clean['source_sha256'].items():
    if hashlib.sha256((ROOT / relative).read_bytes()).hexdigest() != expected:
        raise SystemExit('Source changed after clean verification: ' + relative)

omitted = {'.tools', '.lake', '.git', '__pycache__'}
paths = []
for directory, dirs, files in os.walk(ROOT):
    dirs[:] = sorted(d for d in dirs if d not in omitted)
    for name in sorted(files):
        path = Path(directory) / name
        if path.is_symlink():
            raise SystemExit('Unexpected source symlink: ' + str(path))
        if path.suffix == '.pyc' or name == 'runner.lock':
            continue
        if path.stat().st_size > 10 * 1024 * 1024:
            raise SystemExit('Unexpectedly large delivery file: ' + str(path))
        paths.append(path)
if sum(p.stat().st_size for p in paths) > 50 * 1024 * 1024:
    raise SystemExit('Unexpectedly large delivery; inspect before packaging')
checksums = ROOT / 'SHA256SUMS.txt'
paths = sorted(set(paths) - {checksums})
checksums.write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' +
                            p.relative_to(ROOT).as_posix() + '\n' for p in paths), encoding='utf-8')
paths.append(checksums)
output = ROOT.parent / 'autocorrelation_lean_verified.zip'
if output.exists():
    raise SystemExit('Delivery archive already exists; refusing to overwrite: ' + str(output))
with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for path in paths:
        archive.write(path, (Path(ROOT.name) / path.relative_to(ROOT)).as_posix())
with zipfile.ZipFile(output) as archive:
    damaged = archive.testzip()
    if damaged:
        raise SystemExit('Archive CRC failed: ' + damaged)
digest = hashlib.sha256(output.read_bytes()).hexdigest()
output.with_suffix('.zip.sha256').write_text(digest + '  ' + output.name + '\n', encoding='utf-8')
print(json.dumps({'archive': str(output), 'files': len(paths),
                  'bytes': output.stat().st_size, 'sha256': digest,
                  'crc_check': 'passed', 'clean_source_hashes_match': True,
                  'excluded_rebuildable_directories': sorted(omitted)}, indent=2))
