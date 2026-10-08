#!/usr/bin/env python3
"""Generate proof candidates from the exact, original certificate.

This program is UNTRUSTED as a Lean proof producer. Each generated identity is
intended to be checked by Lean's kernel via ring/norm_num, never native_decide.
The generator also audits every generated Bernstein identity over Q.
Generation and successful Python tests are NOT a successful Lean compilation.
"""
from __future__ import annotations
import hashlib, json, math, sys
from fractions import Fraction as F
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'original'))
import verify as v
DATA = json.loads((ROOT / 'certificate.json').read_text())
a, b, gamma = F(DATA['a']), F(DATA['b']), F(DATA['gamma'])
w, c = 1-2*b, 1-b
P = v.build_profile(a,b,list(map(F,DATA['chebyshev_coefficients'])))
DP, I = v.deriv(P), v.integ(P)
pieces = v.autocorrelation_polynomials(P,a,b)


def rat(r: F | int) -> str:
    r=F(r)
    if r.denominator == 1:
        return f'({r.numerator} : ℝ)'
    return f'(({r.numerator} : ℝ) / {r.denominator})'


def expr(poly: list[F], var: str) -> str:
    terms=[]
    for k,coef in enumerate(poly):
        if coef == 0: continue
        terms.append(rat(coef) if k==0 else f'{rat(coef)} * {var} ^ {k}')
    return '(' + ' + '.join(terms) + ')' if terms else '(0 : ℝ)'


def write(name: str, text: str) -> None:
    p=ROOT/name
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(text.rstrip()+'\n',encoding='utf-8')

MODEL_IMPORTS='''import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
'''
BERNSTEIN_IMPORTS='''import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
'''
HEADER='''
/-!
PROOF CANDIDATE — NOT COMPILED in the generation environment.
All real coefficients below are exact rational expressions.
See README_zh.md and STATUS.json for the scope and verification boundary.
-/
set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation
'''

# An explicit primitive of P(s) P(s+v), zero at s=0.
product = [[F(0)] for _ in range(2*(len(P)-1)+1)]
for i,pi in enumerate(P):
    for j,pj in enumerate(P):
        for k in range(j+1):
            product[i+k]=v.add(product[i+k],[F(0)]*(j-k)+[pi*pj*math.comb(j,k)])
rr_terms=[]
rr_deriv=[]
rr_proofs=[]
rr_deriv_raw_terms=[]
for k,coef in enumerate(product):
    if all(x==0 for x in coef): continue
    ci=v.scale(coef,F(1,k+1))
    rr_terms.append(f'{expr(ci,"v")} * u ^ {k+1}')
    rr_deriv.append(f'{expr(coef,"v")} * u ^ {k}')
    rr_proofs.append(f'((hasDerivAt_pow {k+1} u).const_mul {expr(ci,"v")})')
    rr_deriv_raw_terms.append(
        f'{expr(ci,"v")} * ((({k+1} : ℕ) : ℝ) * u ^ ({k+1}-1))')
rr_expr='('+' +\n    '.join(rr_terms)+')'
rrd_expr='('+' +\n    '.join(rr_deriv)+')'

model=MODEL_IMPORTS+HEADER+'\n'
for name,r in [('a',a),('b',b),('gamma',gamma),('delta0',F(DATA['rectangle_width']))]:
    model+=f'def {name} : ℝ := {rat(r)}\n'
model+='def w : ℝ := 1 - 2*b\ndef c : ℝ := 1-b\n\n'
model+='''def cheb (z : ℝ) : ℕ → ℝ
  | 0 => 1
  | 1 => z
  | n+2 => 2*z*cheb z (n+1) - cheb z n

'''
qs=' +\n    '.join(f'{rat(F(q))} * cheb (2*x-1) {j}' for j,q in enumerate(DATA['chebyshev_coefficients']))
model+=f'def paperP (x : ℝ) : ℝ := 2*x-x^2+x*(1-x)^2*({qs})\n\n'
for name,p in [('P',P),('DP',DP),('I',I)]:
    model+=f'def {name} (x : ℝ) : ℝ :=\n  {expr(p,"x")}\n\n'
model+='''theorem P_matches_paper (x : ℝ) : P x = paperP x := by
  norm_num [P, paperP, cheb] <;> ring

theorem P_zero : P 0 = 0 := by norm_num [P]
theorem P_one : P 1 = 1 := by norm_num [P]
theorem DP_one : DP 1 = 0 := by norm_num [DP]
theorem I_zero : I 0 = 0 := by norm_num [I]
theorem a_pos : 0 < a := by norm_num [a]
theorem gamma_pos : 0 < gamma := by norm_num [gamma]
theorem w_pos : 0 < w := by norm_num [w, b]
theorem breakpoint_order : 0 < b ∧ b < w ∧ w < c ∧ c < 1 := by
  norm_num [b, w, c]

'''
def sum_proofs(terms: list[str]) -> str:
    if not terms: raise ValueError('empty derivative proof')
    ans=terms[0]
    for t in terms[1:]: ans=f'({ans}.add {t})'
    return ans

def deriv_proof(poly: list[F], base: str='x') -> str:
    ps=[]
    for n,k in enumerate(poly):
        if k==0: continue
        if n==0: ps.append(f'(hasDerivAt_const {base} {rat(k)})')
        else: ps.append(f'((hasDerivAt_pow {n} {base}).const_mul {rat(k)})')
    return sum_proofs(ps)

def deriv_raw_expr(poly: list[F], base: str='x') -> str:
    terms=[]
    for n,k in enumerate(poly):
        if k==0: continue
        terms.append('(0 : ℝ)' if n==0 else
                     f'{rat(k)} * ((({n} : ℕ) : ℝ) * {base} ^ ({n}-1))')
    return '('+' + '.join(terms)+')'

# Normalize derivatives without loading calculus, then reuse the resulting
# equalities through HasDerivAt.congr_deriv in the calculus module.
derivative_algebra = 'import Autocorrelation.PrimitivePolynomials\n'+HEADER+f'''
def P_deriv_raw (x : ℝ) : ℝ :=
  {deriv_raw_expr(P)}

theorem P_deriv_raw_eq (x : ℝ) : P_deriv_raw x = DP x := by
  unfold P_deriv_raw DP
  ring

def I_deriv_raw (x : ℝ) : ℝ :=
  {deriv_raw_expr(I)}

theorem I_deriv_raw_eq (x : ℝ) : I_deriv_raw x = P x := by
  unfold I_deriv_raw P
  ring

def RR_deriv_raw (u v : ℝ) : ℝ :=
  ({' + '.join(rr_deriv_raw_terms)})

theorem RR_deriv_raw_eq (u v : ℝ) : RR_deriv_raw u v = DRR u v := by
  unfold RR_deriv_raw DRR
  ring

end Autocorrelation
'''

model+=f'''theorem hasDerivAt_P (x : ℝ) : HasDerivAt P (DP x) x := by
  have h : HasDerivAt P (P_deriv_raw x) x :=
    {deriv_proof(P)}
  exact h.congr_deriv (P_deriv_raw_eq x)

theorem hasDerivAt_I (x : ℝ) : HasDerivAt I (P x) x := by
  have h : HasDerivAt I (I_deriv_raw x) x :=
    {deriv_proof(I)}
  exact h.congr_deriv (I_deriv_raw_eq x)

/-- Algebraic primitive, not a definition of a Lebesgue integral. -/
def RR (u v : ℝ) : ℝ :=
  {rr_expr}

def DRR (u v : ℝ) : ℝ :=
  {rrd_expr}

theorem RR_zero (v : ℝ) : RR 0 v = 0 := by norm_num [RR]

theorem DRR_identity (u v : ℝ) : DRR u v = P u * P (u+v) := by
  norm_num [DRR, P] <;> ring

theorem hasDerivAt_RR (u v : ℝ) :
    HasDerivAt (fun s => RR s v) (P u * P (u+v)) u := by
  have h : HasDerivAt (fun s => RR s v) (RR_deriv_raw u v) u :=
    {sum_proofs(rr_proofs)}
  exact h.congr_deriv ((RR_deriv_raw_eq u v).trans (DRR_identity u v))

def H (t : ℝ) : ℝ := w * RR (1-t/w) (t/w)
def g0 (t : ℝ) : ℝ := (H t + w*(I 1-I (1-t/w)) + b-t)/a^2
def g1 (t : ℝ) : ℝ := P ((t-b)/w) +
  (H t + w*(I ((c-t)/w)-I (1-t/w)))/a^2
def g2 (t : ℝ) : ℝ := P ((t-b)/w) + w*I ((c-t)/w)/a^2
def g3 (_ : ℝ) : ℝ := 1

'''
for k,(_,_,gp) in enumerate(pieces):
    model+=f'''def G{k} (t : ℝ) : ℝ :=
  {expr(gp,'t')}

theorem g{k}_expansion (t : ℝ) : g{k} t = G{k} t := by
  norm_num [g{k}, H, RR, I, P, a, b, w, c, G{k}] <;> ring

'''
model+='end Autocorrelation\n'
# Preserve every original declaration, but compile algebra independently of the
# calculus imports and release elaborator state between the larger proofs.
body = model.split('namespace Autocorrelation\n', 1)[1].rsplit('end Autocorrelation', 1)[0]
profile, rest = body.split('theorem hasDerivAt_P', 1)
deriv_pi, rest = rest.split('/-- Algebraic primitive', 1)
primitives, rest = rest.split('theorem hasDerivAt_RR', 1)
deriv_rr, correlation = rest.split('def H (t : ℝ)', 1)
write('Autocorrelation/Profile.lean',
      'import Mathlib.Data.Real.Basic\nimport Mathlib.Tactic.NormNum\nimport Mathlib.Tactic.Ring\n'
      + HEADER + profile + 'end Autocorrelation\n')
write('Autocorrelation/PrimitivePolynomials.lean',
      'import Autocorrelation.Profile\n' + HEADER + '/-- Algebraic primitive' + primitives
      + 'end Autocorrelation\n')
write('Autocorrelation/Derivatives.lean',
      'import Autocorrelation.DerivativeAlgebra\n' + MODEL_IMPORTS + HEADER
      + 'theorem hasDerivAt_P' + deriv_pi + 'theorem hasDerivAt_RR' + deriv_rr
      + 'end Autocorrelation\n')
write('Autocorrelation/DerivativeAlgebra.lean', derivative_algebra)
write('Autocorrelation/CorrelationModel.lean',
      'import Autocorrelation.PrimitivePolynomials\n' + HEADER + 'def H (t : ℝ)' + correlation
      + 'end Autocorrelation\n')
write('Autocorrelation/Model.lean',
      'import Autocorrelation.CorrelationModel\nimport Autocorrelation.Derivatives\n'
      '\n/-! Re-exports every declaration of the original model; proofs are split to limit peak memory. -/\n')

write('Autocorrelation/Bernstein.lean',BERNSTEIN_IMPORTS+HEADER+'''
/-- The binomial weights have already been absorbed into these natural
    coefficients. This is a homogeneous polynomial evaluated by Horner's rule. -/
def hom : List ℕ → ℝ → ℝ → ℝ
  | [], _, _ => 0
  | k::ks, x, y => (k : ℝ) * y^ks.length + x * hom ks x y

theorem hom_nonneg (ks : List ℕ) (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    0 ≤ hom ks x y := by
  induction ks with
  | nil => simp [hom]
  | cons k ks ih =>
    exact add_nonneg
      (mul_nonneg (Nat.cast_nonneg k) (pow_nonneg hy _))
      (mul_nonneg hx ih)

/-- This lemma carries a whole-interval proof, not a sampled-point test. -/
theorem affine_nonneg (p : ℝ → ℝ) (lo hi : ℝ) (hspan : lo < hi)
    (hcert : ∀ s : ℝ, 0 ≤ s → s ≤ 1 → 0 ≤ p (lo+(hi-lo)*s))
    (t : ℝ) (hlo : lo ≤ t) (hhi : t ≤ hi) : 0 ≤ p t := by
  have hd : 0 < hi-lo := sub_pos.mpr hspan
  have hs0 : 0 ≤ (t-lo)/(hi-lo) := div_nonneg (sub_nonneg.mpr hlo) hd.le
  have hs1 : (t-lo)/(hi-lo) ≤ 1 := (div_le_one hd).2 (by linarith)
  have he : lo+(hi-lo)*((t-lo)/(hi-lo)) = t := by
    field_simp [ne_of_gt hd] <;> ring
  have h := hcert ((t-lo)/(hi-lo)) hs0 hs1
  rw [he] at h
  exact h

end Autocorrelation
''')

# Export leaves and verify the mathematical identities independently of the
# original de Casteljau recurrence by exact coefficient reconstruction.
def accepted_leaves(p: list[F],lo: F,hi: F,depth: int=0):
    beta=v.bernstein(p,lo,hi)
    if min(beta)>=0: return [(lo,hi,beta,depth)]
    if depth>=28: raise ValueError('depth limit')
    mid=(lo+hi)/2
    return accepted_leaves(p,lo,mid,depth+1)+accepted_leaves(p,mid,hi,depth+1)

manifest=[]
all_groups=[('DP',DP,F(0),F(1))]+[(f'G{k}',v.add(gp,[-gamma]),lo,hi) for k,(lo,hi,gp) in enumerate(pieces)]
cert_imports=[]
proof_groups=[]
for group,poly,lo,hi in all_groups:
    leaves=accepted_leaves(poly,lo,hi)
    modules=[]
    for j,(l,r,beta,depth) in enumerate(leaves):
        degree=len(beta)-1
        bern=[be*math.comb(degree,k) for k,be in enumerate(beta)]
        den=math.lcm(*(be.denominator for be in bern))
        nums=[int(be*den) for be in bern]
        assert all(n>=0 for n in nums)
        # Reconstruct through a separate homogeneous Horner recurrence.
        reconstructed=[F(0)]
        for idx,n in reversed(list(enumerate(nums))):
            ypower=[F((-1)**k*math.comb(degree-idx,k)) for k in range(degree-idx+1)]
            reconstructed=v.add(v.scale(ypower,F(n)),v.mul([F(0),F(1)],reconstructed))
        reconstructed=v.scale(reconstructed,F(1,den))
        assert v.trim(reconstructed)==v.trim(v.compose(poly,[l,r-l]))
        name=f'{group}_{j:02d}'
        module=f'Autocorrelation.Leaves.{name}'
        modules.append(name);cert_imports.append(f'import {module}')
        target=(lambda xx:f'DP {xx}') if group=='DP' else (lambda xx,group=group:f'{group} {xx} - gamma')
        coefflist='['+',\n    '.join(map(str,nums))+']'
        identity=f'{name}_identity'
        sarg=f'({rat(l)}+({rat(r)}-{rat(l)})*s)'
        leaf=f'''import Autocorrelation.CorrelationModel
import Autocorrelation.Bernstein

set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

-- Proof candidate. All literals were produced with rational arithmetic.
def {name}_coeffs : List ℕ :=
  {coefflist}

theorem {identity} (s : ℝ) :
    {target(sarg)} = hom {name}_coeffs s (1-s) / {den} := by
  norm_num [{group}, gamma, hom, {name}_coeffs] <;> ring

theorem {name}_unit_nonneg (s : ℝ) (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    0 ≤ {target(sarg)} := by
  rw [{identity}]
  exact div_nonneg
    (hom_nonneg {name}_coeffs s (1-s) hs0 (sub_nonneg.mpr hs1))
    (by norm_num)

theorem {name}_nonneg (t : ℝ) (hlo : {rat(l)} ≤ t) (hhi : t ≤ {rat(r)}) :
    0 ≤ {target('t')} := by
  exact affine_nonneg (fun z => {target('z')}) {rat(l)} {rat(r)}
    (by norm_num) {name}_unit_nonneg t hlo hhi

end Autocorrelation
'''
        write(module.replace('.','/')+'.lean',leaf)
        manifest.append(dict(group=group,name=name,lo=str(l),hi=str(r),degree=degree,depth=depth,
                             denominator=str(den),coefficients=list(map(str,nums)),
                             power_coefficients=list(map(str,poly))))
    statement=f'0 ≤ DP t' if group=='DP' else f'gamma ≤ {group} t'
    text=f'''theorem {group}_nonnegative_on_interval (t : ℝ)
    (hlo : {rat(lo)} ≤ t) (hhi : t ≤ {rat(hi)}) : {statement} := by
'''
    if group!='DP': text+='  apply sub_nonneg.mp\n'
    # Serial decisions give the exact leaf cover; no unverified finite cover data.
    for j,(l,r,_,_) in enumerate(leaves):
        lower='hlo' if j==0 else f'(le_of_lt (lt_of_not_ge h{j-1}))'
        if j==len(leaves)-1:
            text+=f'  exact {modules[j]}_nonneg t {lower} hhi\n'
        else:
            text+=f'  by_cases h{j} : t ≤ {rat(r)}\n'
            text+=f'  · exact {modules[j]}_nonneg t {lower} h{j}\n'
    proof_groups.append(text)

finite='\n'.join(cert_imports)+'''

set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

'''+ '\n'.join(proof_groups)+'\n'
for k,(lo,hi,gp) in enumerate(pieces):
    endpoints=[('0','b'),('b','w'),('w','c'),('c','1')][k]
    finite+=f'''theorem g{k}_lower (t : ℝ) (hlo : {endpoints[0]} ≤ t)
    (hhi : t ≤ {endpoints[1]}) : gamma ≤ g{k} t := by
  rw [g{k}_expansion]
  apply G{k}_nonnegative_on_interval t
  · norm_num [b, w, c] at hlo ⊢ <;> exact hlo
  · norm_num [b, w, c] at hhi ⊢ <;> exact hhi

'''
finite+='''/-- The finite part of Lemma 1, with the algebraic definitions tied to the paper.
    This declaration is not Theorem 3: it contains no autocorrelation integral. -/
theorem finite_certificate :
    (∀ x : ℝ, 0 ≤ x → x ≤ 1 → 0 ≤ DP x) ∧
    (∀ t : ℝ, 0 ≤ t → t ≤ b → gamma ≤ g0 t) ∧
    (∀ t : ℝ, b ≤ t → t ≤ w → gamma ≤ g1 t) ∧
    (∀ t : ℝ, w ≤ t → t ≤ c → gamma ≤ g2 t) ∧
    (∀ t : ℝ, c ≤ t → t ≤ 1 → gamma ≤ g3 t) := by
  exact ⟨DP_nonnegative_on_interval, g0_lower, g1_lower, g2_lower, g3_lower⟩

end Autocorrelation
'''
write('Autocorrelation/FiniteCertificate.lean',finite)

N,D=F(DATA['atomic_ratio']).numerator,F(DATA['atomic_ratio']).denominator
NF,DF=F(DATA['function_ratio']).numerator,F(DATA['function_ratio']).denominator
mass=a+(w*v.evalp(I,F(1))+b)/a
ratios='''import Autocorrelation.CorrelationModel

set_option autoImplicit false
set_option maxHeartbeats 0
noncomputable section
namespace Autocorrelation

'''+f'''def mass : ℝ := a + (w*I 1+b)/a
def limitingRatio : ℝ := ({N} : ℝ)/{D}
def explicitRatio : ℝ := ({NF} : ℝ)/{DF}

theorem mass_exact : mass = {rat(mass)} := by
  norm_num [mass, a, b, w, I]

theorem mass_pos : 0 < mass := by rw [mass_exact]; norm_num

theorem limiting_ratio_identity : gamma / mass^2 = limitingRatio := by
  rw [mass_exact]
  norm_num [gamma, limitingRatio]

theorem explicit_ratio_identity :
    gamma / (mass+delta0/a)^2 = explicitRatio := by
  rw [mass_exact]
  norm_num [gamma, delta0, a, explicitRatio]

theorem limiting_ratio_gt : (4103779 : ℝ)/10000000 < limitingRatio := by
  norm_num [limitingRatio]

theorem explicit_ratio_gt : (4103779 : ℝ)/10000000 < explicitRatio := by
  norm_num [explicitRatio]

theorem relaxation_mass_arithmetic : mass^2/gamma < (2436778 : ℝ)/1000000 := by
  rw [mass_exact]
  norm_num [gamma]

end Autocorrelation
'''
write('Autocorrelation/Ratios.lean',ratios)
write('bernstein_leaves.json',json.dumps(manifest,indent=2))
write('logs/generation_audit.json',json.dumps({
    'certificate_sha256':hashlib.sha256((ROOT/'certificate.json').read_bytes()).hexdigest(),
    'exact_polynomial_identity_checks':'PASS (Python Fraction, NOT Lean)',
    'number_of_leaves':len(manifest),
    'coefficient_count':sum(len(x['coefficients']) for x in manifest),
    'groups':{g:{'leaves':sum(x['group']==g for x in manifest),'max_depth':max(x['depth'] for x in manifest if x['group']==g)} for g,*_ in all_groups},
    'lean_compilation':'NOT RUN BY THIS GENERATOR; see separate current-run build logs'
},indent=2))
print(f'Generated {len(manifest)} leaves; every emitted homogeneous identity rechecked over Q.')
print('This generator does not invoke Lean. Consult VERIFICATION_REPORT.md and current-run build logs.')
