#!/usr/bin/env python3
"""Independent exact audit of generated leaf DATA and their complete covers.

Does not reuse the original polynomial arithmetic or Bernstein transformation.
This is a Python/SymPy audit, NOT Lean verification.
"""
from __future__ import annotations
import json,math,re,sys
from collections import defaultdict
from pathlib import Path
import sympy as sp
ROOT=Path(__file__).resolve().parents[1]
S,T,Z=sp.symbols('S T Z')
R=sp.Rational

def check(condition, description):
    if not condition: raise AssertionError(description)

def original_polynomials():
    """Rebuild from Chebyshev input and direct pairwise segment integration.
    This code does not import the generator or its rational polynomial library.
    """
    d=json.loads((ROOT/'certificate.json').read_text())
    a,b,gamma=R(d['a']),R(d['b']),R(d['gamma'])
    w,c=1-2*b,1-b
    q=list(map(R,d['chebyshev_coefficients']))
    profile=sp.Poly(2*Z-Z**2+Z*(1-Z)**2*sum(
        v*sp.chebyshevt(j,2*Z-1) for j,v in enumerate(q)),Z).as_expr()
    X=sp.Symbol('X')
    segments=[(b,c,sp.Poly(profile.subs(Z,(X-b)/w)/a,X).as_expr()),
              (c,sp.Integer(1),1/a)]
    breaks=[sp.Integer(0),b,w,c,sp.Integer(1)]
    result={'DP':sp.Poly(sp.diff(profile,Z).subs(Z,T),T)}
    for k,(tl,tr) in enumerate(zip(breaks,breaks[1:])):
        mid=(tl+tr)/2
        total=sp.Integer(0)
        for l1,r1,f in segments:
            for l2,r2,g in segments:
                lower=max([l1,l2-T],key=lambda e:e.subs(T,mid))
                upper=min([r1,r2-T],key=lambda e:e.subs(T,mid))
                if (upper-lower).subs(T,mid)<=0: continue
                for (px,pt),coef in sp.Poly(f*g.subs(X,X+T),X,T).terms():
                    total+=coef*T**pt*(upper**(px+1)-lower**(px+1))/(px+1)
        if b<mid<c: total+=profile.subs(Z,(T-b)/w)
        elif c<mid<1: total+=1
        result['G'+str(k)]=sp.Poly(total-gamma,T)
    return result


def audit(data, reference):
    bygroup=defaultdict(list)
    for leaf in data:
        lo,hi=R(leaf['lo']),R(leaf['hi']);den=int(leaf['denominator'])
        nums=list(map(int,leaf['coefficients']));d=leaf['degree']
        check(den>0 and hi>lo,'invalid leaf denominator/interval')
        check(len(nums)==d+1 and min(nums)>=0,'invalid leaf natural coefficients')
        p=sum(R(q)*T**j for j,q in enumerate(leaf['power_coefficients']))
        check(sp.Poly(p,T)==reference[leaf['group']],
              'leaf polynomial differs from original certificate: '+leaf['name'])
        bern=sum(n*S**j*(1-S)**(d-j) for j,n in enumerate(nums))/den
        check(sp.Poly(p.subs(T,lo+(hi-lo)*S)-bern,S).is_zero,'identity failed: '+leaf['name'])
        bygroup[leaf['group']].append((lo,hi))
    certificate=json.loads((ROOT/'certificate.json').read_text())
    b=R(certificate['b']);w=1-2*b;c=1-b
    expected={'DP':(0,1),'G0':(0,b),'G1':(b,w),'G2':(w,c),'G3':(c,1)}
    check(set(bygroup)==set(expected),'group mismatch')
    for name,intervals in bygroup.items():
        intervals.sort()
        check((intervals[0][0],intervals[-1][1])==expected[name],'cover endpoints wrong')
        check(all(p[1]==q[0] for p,q in zip(intervals,intervals[1:])),'gap/overlap in cover')
    return bygroup

def main():
    data=json.loads((ROOT/'bernstein_leaves.json').read_text())
    reference=original_polynomials()
    groups=audit(data,reference)
    # Bind the exported natural-number literals in .lean to the audited JSON.
    for leaf in data:
        text=(ROOT/'Autocorrelation'/'Leaves'/(leaf['name']+'.lean')).read_text()
        m=re.search(r'def '+re.escape(leaf['name'])+r'_coeffs : List ℕ :=\s*\[([\d,\s]+)\]',text)
        check(m is not None,'coefficient literal block absent')
        parsed=[int(n.strip()) for n in m.group(1).split(',')]
        check(parsed==list(map(int,leaf['coefficients'])),'emitted Lean coefficient mismatch')
    print('PASS: all leaf polynomials tied to the original Chebyshev certificate via independent exact overlap integration.')
    print(f'PASS: {len(data)} generated identities over Q; all interval covers exact.')
    print('PASS: emitted Lean coefficient literal lists match audited certificate data.')
    # Make sure that this audit rejects a modified certificate, rather than
    # merely displaying precomputed PASS messages.
    bad=json.loads(json.dumps(data))
    bad[0]['coefficients'][0]=str(int(bad[0]['coefficients'][0])+1)
    try: audit(bad,reference)
    except AssertionError: print('PASS negative-control: deliberately modified coefficient rejected.')
    else: raise AssertionError('negative control was accepted')
    print('This audit does NOT execute Lean or check the analytical bridge.')

if __name__=='__main__': main()
