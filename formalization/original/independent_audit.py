#!/usr/bin/env python3
"""Independent exact construction of every correlation polynomial using SymPy.

This audit does not reuse the hand-derived ramp/ramp and ramp/plateau formula.
It integrates all pairs of polynomial segments over their actual overlaps.
The final comparison is coefficient-by-coefficient over Q, not numerical.
"""
import json
import sys
import time
from pathlib import Path
import sympy as s

ROOT = Path(__file__).resolve().parent
import verify as reference

path = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'certificate.json'
d = json.loads(path.read_text())
a = s.Rational(d['a']); b = s.Rational(d['b']); c = 1-b; w = 1-2*b
x,t,z = s.symbols('x t z')
coeff = list(map(s.Rational,d['chebyshev_coefficients']))
P = s.Poly(2*z-z*z+z*(1-z)**2*sum(q*s.chebyshevt(j,2*z-1) for j,q in enumerate(coeff)),z).as_expr()
reference.require(P.subs(z,0)==0 and P.subs(z,1)==1,'Endpoint identity failed')
ramp=s.Poly(P.subs(z,(x-b)/w)/a,x).as_expr()
segments=[(b,c,ramp),(c,s.Integer(1),1/a)]
breaks=[s.Integer(0),b,w,c,s.Integer(1)]
ref = reference.autocorrelation_polynomials(
    reference.build_profile(reference.F(d['a']),reference.F(d['b']),list(map(reference.F,d['chebyshev_coefficients']))),
    reference.F(d['a']), reference.F(d['b']))
start=time.time()
for k,(tl,tr) in enumerate(zip(breaks,breaks[1:])):
    mid=(tl+tr)/2
    total=s.Integer(0)
    for l1,r1,f in segments:
        for l2,r2,g in segments:
            lower=max([l1,l2-t], key=lambda v:v.subs(t,mid))
            upper=min([r1,r2-t], key=lambda v:v.subs(t,mid))
            if (upper-lower).subs(t,mid)<=0:
                continue
            product=s.Poly(f*g.subs(x,x+t),x,t)
            for (px,pt),v in product.terms():
                total += v*t**pt*(upper**(px+1)-lower**(px+1))/s.Integer(px+1)
    if b<mid<c:
        total += P.subs(z,(t-b)/w)
    elif c<mid<1:
        total += 1
    result=s.Poly(total,t)
    want=s.Poly(sum(s.Rational(v.numerator,v.denominator)*t**i for i,v in enumerate(ref[k][2])),t)
    reference.require(result==want,'Exact polynomial mismatch')
    print('PASS: independent exact overlap integral on interval', k, 'degree',result.degree(),flush=True)
print('PASS: all coefficient identities over Q independently reproduced')
print('elapsed seconds =',round(time.time()-start,3))

# A different positivity proof: exact Sturm root counts, not Bernstein bounds.
# The lower-bound polynomials have positive endpoint values and no real roots
# on the relevant interval. This independently certifies strict positivity.
gamma=s.Rational(d['gamma'])
for k,(tl,tr) in enumerate(zip(breaks,breaks[1:])):
    coeff_ref=ref[k][2]
    lower=s.Poly(sum(s.Rational(v.numerator,v.denominator)*t**i for i,v in enumerate(coeff_ref))-gamma,t)
    reference.require(lower.eval(tl)>0 and lower.eval(tr)>0,'Nonpositive endpoint')
    roots=lower.count_roots(tl,tr)
    reference.require(roots==0,'Root in lower-bound polynomial interval')
    print('PASS: exact Sturm count = 0 on lower-bound interval',k,flush=True)
quotient,remainder=s.div(s.Poly(s.diff(P,z),z),s.Poly(1-z,z))
reference.require(remainder.is_zero,'Derivative missing factor 1-z')
reference.require(quotient.eval(0)>0 and quotient.eval(1)>0,'Derivative quotient endpoint failed')
reference.require(quotient.count_roots(0,1)==0,'Derivative quotient has a root')
print('PASS: monotonicity independently verified by exact Sturm count')
print('PASS: polynomial identities and all positivity claims audited independently')
