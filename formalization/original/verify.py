#!/usr/bin/env python3
"""Exact verifier for a polynomial minimum-autocorrelation certificate.

All decisive arithmetic uses fractions.Fraction and Python arbitrary-size
integers. No numerical optimizer, quadrature, floating-point tolerance, or
third-party package enters verification. Decimal displays are informational.

Usage: python verify.py [certificate.json]
"""
import argparse, hashlib, json, sys, time
from decimal import Decimal, localcontext
from fractions import Fraction as F
from math import comb
from pathlib import Path

def require(condition, message):
 if not condition: raise ValueError(message)

# Dense polynomial operations in Q[t], least degree first. All are exact.
def trim(p):
 p=list(p)
 while len(p)>1 and p[-1]==0:p.pop()
 return p

def add(p,q):
 r=[F(0)]*max(len(p),len(q))
 for i,x in enumerate(p):r[i]+=x
 for i,x in enumerate(q):r[i]+=x
 return trim(r)

def scale(p,c):return trim([c*x for x in p])
def mul(p,q):
 r=[F(0)]*(len(p)+len(q)-1)
 for i,x in enumerate(p):
  if x:
   for j,y in enumerate(q):r[i+j]+=x*y
 return trim(r)

def compose(p,q):
 r=[F(0)]
 for x in p[::-1]:r=add(mul(r,q),[x])
 return r

def integ(p):return [F(0)]+[x/F(i+1) for i,x in enumerate(p)]
def deriv(p):return [F(i)*p[i] for i in range(1,len(p))] or [F(0)]
def evalp(p,x):
 r=F(0)
 for a in p[::-1]:r=r*x+a
 return r

def cheb_to_power(coeff):
 ts=[[F(1)],[F(0),F(1)]]
 for i in range(2,len(coeff)):
  ts.append(add(mul([F(0),F(2)],ts[-1]),scale(ts[-2],-1)))
 out=[F(0)]
 for a,t in zip(coeff,ts):out=add(out,scale(t,a))
 return out

def bernstein(p,lo=F(0),hi=F(1)):
 """p(lo+(hi-lo)s) in the degree-d Bernstein basis on [0,1]."""
 q=compose(p,[lo,hi-lo]);d=len(q)-1
 return [sum(q[j]*F(comb(k,j),comb(d,j)) for j in range(k+1)) for k in range(d+1)]

def split_bernstein(beta):
 left=[beta[0]];right=[beta[-1]]
 row=list(beta)
 while len(row)>1:
  row=[(row[i]+row[i+1])/2 for i in range(len(row)-1)]
  left.append(row[0]);right.append(row[-1])
 return left,list(reversed(right))

def prove_nonnegative(p,lo,hi,max_depth=28):
 """Exact de Casteljau subdivision; every accepted leaf has all coefficients >=0."""
 stack=[(bernstein(p,lo,hi),0)];leaves=0;depth=0
 while stack:
  beta,d=stack.pop();depth=max(depth,d)
  if min(beta)>=0:leaves+=1;continue
  if beta[0]<0 or beta[-1]<0:raise ValueError('Negative endpoint in positivity certificate')
  if d>=max_depth:raise ValueError('Subdivision depth exhausted')
  l,r=split_bernstein(beta);stack.append((r,d+1));stack.append((l,d+1))
 return {'leaves':leaves,'maximum_depth':depth}

def build_profile(a,b,q):
 # P(s)=2s-s^2+s(1-s)^2 sum q_j T_j(2s-1).
 Q=compose(cheb_to_power(q),[F(-1),F(2)])
 P=add([F(0),F(2),F(-1)],mul([F(0),F(1),F(-2),F(1)],Q))
 return P

def autocorrelation_polynomials(P,a,b):
 """B(t)=correlation of P((x-b)/w) on [b,c], followed by 1 on [c,1].

 Positive-shift pieces use rr+ramp-plateau+plateau-plateau. The breakpoints
 are 0,b,w,c,1, with c=1-b and w=1-2b, here 0<b<w<c<1.
 """
 c=1-b;w=1-2*b;d=len(P)-1
 require(F(0)<b<w<c<F(1),'Unexpected breakpoint order')
 # Integral from 0 to u of P(s)P(s+t/w)ds. Represent coefficient at s^k
 # as a polynomial in t.
 product=[[F(0)] for _ in range(2*d+1)]
 for i,pi in enumerate(P):
  for j,pj in enumerate(P):
   for k in range(j+1):
    term=[F(0)]*(j-k)+[pi*pj*comb(j,k)/(w**(j-k))]
    product[i+k]=add(product[i+k],term)
 u=[F(1),-1/w]
 rr=[F(0)];upower=[F(1)]
 for k,coef in enumerate(product):
  upower=mul(upower,u)
  rr=add(rr,scale(mul(coef,upower),w/F(k+1)))
 I=integ(P);I1=evalp(I,F(1));Iu=compose(I,u)
 v=[c/w,-1/w];Iv=compose(I,v)
 # rr active for t<w. rp lower=max(0,1-t/w), upper=min(1,(c-t)/w).
 # On [0,b]: upper=1, lower=u.
 # On [b,w]: upper=v, lower=u.
 # On [w,c]: upper=v, lower=0.
 B0=add(add(rr,scale(add([I1],scale(Iu,-1)),w)),[b,F(-1)])
 B1=add(rr,scale(add(Iv,scale(Iu,-1)),w))
 B2=scale(Iv,w)
 # atom contribution is zero below b, P((t-b)/w) on [b,c], one above c.
 atom=compose(P,[-b/w,1/w])
 g0=scale(B0,1/(a*a))
 g1=add(atom,scale(B1,1/(a*a)))
 g2=add(atom,scale(B2,1/(a*a)))
 g3=[F(1)]
 return [(F(0),b,g0),(b,w,g1),(w,c,g2),(c,F(1),g3)]

def verify(data,verbose=True):
 require(data['schema']=='atomic-polynomial-certificate-v1','Unrecognized schema')
 a=F(data['a']);b=F(data['b']);q=list(map(F,data['chebyshev_coefficients']))
 require(a>0,'Nonpositive atom mass')
 gamma=F(data['gamma']);P=build_profile(a,b,q)
 require(0<gamma<=1,'Invalid lower bound')
 require(evalp(P,F(0))==0 and evalp(P,F(1))==1 and evalp(deriv(P),F(1))==0,'Endpoint identity failed')
 monotone=prove_nonnegative(deriv(P),F(0),F(1))
 pieces=autocorrelation_polynomials(P,a,b)
 cert=[]
 for lo,hi,g in pieces:
  p=add(g,[-gamma]);out=prove_nonnegative(p,lo,hi)
  cert.append(out)
  if verbose:print('PASS interval',float(lo),float(hi),'degree',len(g)-1,out,flush=True)
 # Check continuity independently at every breakpoint.
 for (_,hi,g),(_,_,gg) in zip(pieces,pieces[1:]):
  require(evalp(g,hi)==evalp(gg,hi),'Continuity identity failed')
 w=1-2*b;mass=a+(w*evalp(integ(P),F(1))+b)/a
 ratio=gamma/(mass*mass)
 delta=F(data['rectangle_width']);require(delta>0,'Invalid rectangle width');function_mass=mass+delta/a
 function_ratio=gamma/(function_mass*function_mass)
 require(ratio==F(data['atomic_ratio']) and function_ratio==F(data['function_ratio']),'Stored ratio mismatch')
 require(function_ratio>F(data['claimed_bound']),'Claimed strict bound failed')
 if verbose:
  print('PASS monotonicity',monotone)
  print('mass',float(mass),'gamma',float(gamma))
  print('Atomic ratio (exact) =',ratio)
  print('Function ratio bound (exact) =',function_ratio)
  with localcontext() as ctx:
   ctx.prec=55
   display=lambda r: Decimal(r.numerator)/Decimal(r.denominator)
   print('Atomic ratio (decimal) =',display(ratio))
   print('Function ratio bound (decimal) =',display(function_ratio))
   print('Squared mass / gamma (decimal) =',display(1/ratio))
   print('Normalized mass bound (decimal) =',display(1/ratio).sqrt())
  print('PASS: actual L1 function ratio >',data['claimed_bound'])
 return cert


if __name__ == '__main__':
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('certificate',nargs='?',type=Path,default=Path(__file__).with_name('certificate.json'))
 args=parser.parse_args()
 try:
  raw=args.certificate.read_bytes()
  data=json.loads(raw)
  start=time.perf_counter()
  verify(data)
  print('Certificate SHA256 =',hashlib.sha256(raw).hexdigest())
  print('Verification seconds =',round(time.perf_counter()-start,3))
 except (ValueError,KeyError,TypeError,OSError,ZeroDivisionError) as error:
  print('VERIFICATION FAILED:',error,file=sys.stderr)
  sys.exit(1)
