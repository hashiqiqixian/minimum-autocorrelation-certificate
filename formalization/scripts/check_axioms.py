#!/usr/bin/env python3
"""Parse actual axiom reports; never infer mathematical completion from names.

check.ps1 runs Lean immediately before this parser. --runner-metadata can also
bind an audit log to a specific successful run_logged.py invocation. --require-core
requires reports for all six planned core theorems; it does not prove their types.
"""
import argparse,json,re,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--audit-source',default='Audit.lean')
parser.add_argument('--log',default='logs/lean-axioms.log')
parser.add_argument('--output',default='logs/lean-axiom-status.json')
parser.add_argument('--runner-metadata')
parser.add_argument('--require-core',action='store_true')
args=parser.parse_args()
def resolve(value):
    p=Path(value)
    return p if p.is_absolute() else root/p
p=resolve(args.log)
audit_source=resolve(args.audit_source)
if not p.exists(): sys.exit('FAIL: no Lean axiom output exists.')
if not audit_source.exists(): sys.exit('FAIL: no requested audit source exists.')
if args.runner_metadata:
    metadata=json.loads(resolve(args.runner_metadata).read_text(encoding='utf-8-sig'))
    if metadata.get('status')!='passed' or metadata.get('child_exit_code')!=0:
        sys.exit('FAIL: the specified Lean run did not succeed.')
    argv=metadata.get('argv',[])
    if len(argv)<4 or [str(x).lower() for x in argv[1:3]]!=['env','lean']:
        sys.exit('FAIL: metadata does not describe lake env lean.')
    run_cwd=Path(metadata['cwd'])
    run_source=Path(argv[3])
    if not run_source.is_absolute(): run_source=run_cwd/run_source
    if run_source.resolve()!=audit_source.resolve():
        sys.exit('FAIL: runner metadata refers to a different audit source.')
    if Path(metadata['log']).read_bytes()!=p.read_bytes():
        sys.exit('FAIL: audit log differs from the actual runner output.')
text=p.read_text(encoding='utf-8-sig')
if re.search(r'\bsorryAx\b|\bLean\.ofReduceBool\b|\berror:',text):
    sys.exit('FAIL: forbidden axiom or Lean error in output.')
allowed={'propext','Classical.choice','Quot.sound'}
# #print axioms output is expected to contain one of these for every requested theorem.
blocks=re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]",text,re.S)
empty=re.findall(r"'([^']+)' does not depend on any axioms",text)
expected=re.findall(r'^\s*#print\s+axioms\s+(\S+)',audit_source.read_text(encoding='utf-8-sig'),re.M)
if not expected: sys.exit('FAIL: audit source requests no axiom reports.')
seen={name for name,_ in blocks}|set(empty)
missing=set(expected)-seen
if missing: sys.exit('FAIL: missing axiom reports: '+', '.join(sorted(missing)))
actual={name:[] for name in empty}
for name,body in blocks:
    axioms={s.strip() for s in body.split(',') if s.strip()}
    if axioms-allowed: sys.exit(f'FAIL: unexpected axioms for {name}: {axioms-allowed}')
    if name in actual and actual[name]!=sorted(axioms):
        sys.exit('FAIL: conflicting axiom reports for '+name)
    actual[name]=sorted(axioms)
base_components=['Autocorrelation.'+name for name in [
  'finite_certificate','P_matches_paper','hasDerivAt_P','hasDerivAt_I','hasDerivAt_RR',
  'P_monotoneOn','P_bounds','integral_P','integral_PP','g0_g1_match','g1_g2_match',
  'g2_g3_match','limiting_ratio_identity','explicit_ratio_identity','limiting_ratio_gt',
  'explicit_ratio_gt','relaxation_mass_arithmetic','monotone_extension_comparison',
  'autocorrelation_product_lower'
]]
core={
  'OverlapIntegralClaim':'Autocorrelation.overlap_integral',
  'WitnessAdmissibilityClaim':'Autocorrelation.witness_admissibility',
  'MassIntegralClaim':'Autocorrelation.mass_integral',
  'UniformCorrelationClaim':'Autocorrelation.uniform_correlation',
  'ExplicitMainClaim':'Autocorrelation.explicit_main',
  'LimitingMainClaim':'Autocorrelation.limiting_main'
}
covered={claim:name for claim,name in core.items() if name in seen and name in expected}
missing_core={claim:name for claim,name in core.items() if claim not in covered}
required_full=set(base_components)|set(core.values())
missing_full=required_full-(seen&set(expected))
if args.require_core and missing_full:
    sys.exit('FAIL: incomplete 25-theorem audit; missing reports: '+', '.join(sorted(missing_full)))
print(f'PASS actual axiom output: {len(set(expected))} requested declarations use only allowed axioms.')
print(f'Core theorem axiom coverage: {len(covered)}/6. Declaration types and proof scope require separate verification.')
output=resolve(args.output)
output.parent.mkdir(parents=True,exist_ok=True)
output.write_text(json.dumps({
  'audit_source':str(audit_source),'audit_log':str(p),
  'runner_metadata':str(resolve(args.runner_metadata)) if args.runner_metadata else None,
  'axiom_reports_passed':True,'scope':'axiom_dependencies_only',
  'checked_component_theorems':expected,'allowed_axioms':sorted(allowed),
  'actual_axioms':{name:actual[name] for name in expected},
  'core_theorems_with_allowed_axiom_reports':covered,
  'core_theorems_missing_axiom_reports':missing_core,
  'complete_25_theorem_axiom_coverage':not missing_full,
  'mathematical_completion_assessed':False
},indent=2)+'\n',encoding='utf-8')
