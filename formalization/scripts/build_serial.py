"""Build project modules one at a time in import order (Python 3.9+).

Use directly, NOT under run_logged.py: every individual build uses that runner.
By default build every Autocorrelation library module. Positional module names
restrict the run to those modules and their project-local dependencies. --list
prints the plan without invoking Lean. check.ps1 performs the final lake build
and axiom audit after this script finishes successfully.

The +Module:leanArts syntax is documented by the installed Lean 4.19 source:
src/lean/lake/Lake/CLI/Help.lean (helpBuild), and resolved in CLI/Build.lean.
Matching mathlib/dependency caches should be installed before using this script.
"""

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import subprocess
import sys
import uuid


ROOT = Path(__file__).resolve().parent.parent


def without_comments(text):
    # Preserve newlines so only real, line-leading import commands are examined.
    result = []
    depth = 0
    i = 0
    while i < len(text):
        if text.startswith('/-', i):
            depth += 1
            result.append('  ')
            i += 2
        elif depth and text.startswith('-/', i):
            depth -= 1
            result.append('  ')
            i += 2
        elif depth:
            result.append('\n' if text[i] == '\n' else ' ')
            i += 1
        elif text.startswith('--', i):
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        else:
            result.append(text[i])
            i += 1
    if depth:
        raise ValueError('Unclosed Lean block comment')
    return ''.join(result)


def build_plan(selected):
    paths = [ROOT / 'Autocorrelation.lean'] + sorted((ROOT / 'Autocorrelation').rglob('*.lean'))
    sources = {'.'.join(path.relative_to(ROOT).with_suffix('').parts): path for path in paths}
    dependencies = {}
    for module, path in sources.items():
        text = without_comments(path.read_text(encoding='utf-8-sig'))
        imports = []
        for match in re.finditer(r'^\s*import\s+([^\n]+)', text, re.M):
            imports.extend(match.group(1).split())
        local = [name for name in imports if name == 'Autocorrelation' or name.startswith('Autocorrelation.')]
        missing = [name for name in local if name not in sources]
        if missing:
            raise ValueError('%s imports missing project modules: %s' % (module, ', '.join(missing)))
        dependencies[module] = local
    unknown = sorted(set(selected) - sources.keys())
    if unknown:
        raise ValueError('Unknown project module(s): ' + ', '.join(unknown))
    done, active, ordered = set(), set(), []

    def visit(module):
        if module in done:
            return
        if module in active:
            raise ValueError('Cyclic project imports at ' + module)
        active.add(module)
        for dependency in dependencies[module]:
            visit(dependency)
        active.remove(module)
        done.add(module)
        ordered.append(module)

    for module in selected or sorted(sources):
        visit(module)
    return ordered


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('modules', nargs='*', help='optional exact module names, with their dependencies')
    parser.add_argument('--list', action='store_true', help='only print the topological build plan')
    parser.add_argument('--timeout', type=float, default=600, help='timeout for each module command')
    parser.add_argument('--memory-estimate-mb', type=float, default=800)
    args = parser.parse_args()
    if args.timeout <= 0 or args.memory_estimate_mb < 0:
        parser.error('timeout must be positive and memory estimate nonnegative')
    try:
        plan = build_plan(args.modules)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    print('Project module build plan: %d modules' % len(plan), flush=True)
    if args.list:
        for module in plan:
            print('lake build +%s:leanArts' % module)
        return 0
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    token = uuid.uuid4().hex
    log_dir = ROOT / 'logs/current-run'
    log_dir.mkdir(parents=True, exist_ok=True)
    summary_path = log_dir / (stamp + '_serial-build.json')
    summary = {'started_utc': datetime.now(timezone.utc).isoformat(),
               'requested_modules': args.modules, 'planned_modules': plan,
               'completed_modules': [], 'status': 'running', 'exit_code': None}

    def save():
        summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    save()
    for number, module in enumerate(plan, 1):
        label = 'serial-%02d-%s-%s' % (number, module, token)
        command = [sys.executable, str(ROOT / 'scripts/run_logged.py'),
                   '--label', label, '--timeout', str(args.timeout),
                   '--memory-estimate-mb', str(args.memory_estimate_mb),
                   '--', 'lake', 'build', '+' + module + ':leanArts']
        print('[%d/%d] %s' % (number, len(plan), module), flush=True)
        try:
            code = subprocess.call(command, cwd=str(ROOT))
        except KeyboardInterrupt:
            code = 130
        reports = list(log_dir.glob('*_' + label + '.json'))
        summary['last_module'] = module
        summary['last_command_exit_code'] = code
        if code != 0:
            summary.update(status='failed', exit_code=code,
                           finished_utc=datetime.now(timezone.utc).isoformat())
            save()
            print('Stopped at first unsuccessful build. Summary: ' + str(summary_path), flush=True)
            return code
        if len(reports) != 1:
            summary.update(status='runner_metadata_error', exit_code=125,
                           finished_utc=datetime.now(timezone.utc).isoformat())
            save()
            print('Missing or ambiguous command metadata for ' + module, file=sys.stderr)
            return 125
        report = json.loads(reports[0].read_text(encoding='utf-8'))
        if report.get('status') != 'passed' or report.get('child_exit_code') != 0:
            summary.update(status='runner_metadata_error', exit_code=125,
                           finished_utc=datetime.now(timezone.utc).isoformat())
            save()
            return 125
        summary['completed_modules'].append({'module': module, 'metadata': str(reports[0]),
                                             'child_exit_code': report['child_exit_code']})
        save()
    summary.update(status='passed', exit_code=0,
                   finished_utc=datetime.now(timezone.utc).isoformat())
    save()
    print('All %d project modules built. Summary: %s' % (len(plan), summary_path), flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
