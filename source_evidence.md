# 回传附件源码证据摘录

下列为原始附件内容，未修改。行号按源文件文本；每项 SHA-256 按原始字节。不是 Lean 重新执行输出。

## `original/research_note.tex`

SHA-256: `c34223fa4de05c69c2e952b263db9130ded638cabec1893f5c786c02c64d465e`

### Lines 32–39

```text
  32 | For a nonnegative integrable function, write
  33 | \[
  34 |  a_f(t)=\int_{\R}f(x)f(x+t)\,dx,
  35 |  \qquad
  36 |  \mathcal A=\sup_{0\ne f\in L^1(\R),\ f\ge0}
  37 |  \frac{\inf_{0\le t\le1}a_f(t)}{\left(\int_{\R}f\right)^2}.
  38 | \]
  39 | The function constructed below belongs to $L^1\cap L^2$ and has continuous autocorrelation, so no distinction between an ordinary and an essential infimum arises for the witness.
```

### Lines 110–180

```text
 110 | For $0<t<1$, the absolutely continuous part of the autocorrelation of \eqref{eq:mu} has density
 111 | \begin{equation}\label{eq:g}
 112 |  g(t)=a h(t)+\int_\R h(x)h(x+t)\,dx
 113 |      =\phi(t)+\frac{B(t)}{a^2},
 114 |  \qquad B(t)=\int_\R\phi(x)\phi(x+t)\,dx.
 115 | \end{equation}
 116 | There is also the nonnegative atom $a^2\delta_0$. The central finite claim is
 117 | \begin{equation}\label{eq:core}
 118 |  g(t)\ge\gamma\qquad(0\le t\le1),
 119 | \end{equation}
 120 | where $g$ is extended continuously to the endpoints. The following section gives all the algebra needed to verify this claim.
 121 | 
 122 | \section{Reduction to four polynomial inequalities}
 123 | Let
 124 | \[
 125 |  I(z)=\int_0^zP(s)\,ds,\qquad
 126 |  u(t)=1-\frac t w,\qquad v(t)=\frac{c_0-t}{w},
 127 | \]
 128 | and define a polynomial in $t$ by
 129 | \[
 130 |  H(t)=w\int_0^{u(t)}P(s)P(s+t/w)\,ds.
 131 | \]
 132 | Although the displayed integral makes sense algebraically for every $t$, it is used as an overlap integral only on $0\le t\le w$. Directly splitting the overlap into ramp--ramp, ramp--plateau, and plateau--plateau terms yields
 133 | \begin{equation}\label{eq:B}
 134 |  B(t)=\begin{cases}
 135 |  H(t)+w\bigl(I(1)-I(u(t))\bigr)+b-t,&0\le t\le b,\\
 136 |  H(t)+w\bigl(I(v(t))-I(u(t))\bigr),&b\le t\le w,\\
 137 |  w I(v(t)),&w\le t\le c_0,\\
 138 |  0,&c_0\le t\le1.
 139 |  \end{cases}
 140 | \end{equation}
 141 | The degrees in the first two pieces are at most $21$, and the third degree is at most $11$.
 142 | 
 143 | For completeness, the ramp--ramp integration variable ranges from $x=b$ to $x=c_0-t$, which becomes $s\in[0,u(t)]$. For the ramp--plateau term it ranges from $\max(b,c_0-t)$ to $\min(c_0,1-t)$. The plateau--plateau overlap has length $(b-t)_+$. These descriptions establish \eqref{eq:B} independently of any numerical fitting procedure.
 144 | 
 145 | The atom contribution in \eqref{eq:g} equals $0$ on $[0,b]$, $P((t-b)/w)$ on $[b,c_0]$, and $1$ on $[c_0,1]$. Combining this observation with \eqref{eq:B} gives four explicitly specified rational polynomials $g_0,g_1,g_2,g_3$. Their formulas agree at the three internal breakpoints.
 146 | 
 147 | \begin{lemma}[Finite certificate]\label{lem:cert}
 148 | For the exact data in Section 2, $P'\ge0$ on $[0,1]$ and $g_i-\gamma\ge0$ throughout the respective intervals in \eqref{eq:B}.
 149 | \end{lemma}
 150 | \begin{proof}[Computer-assisted proof]
 151 | For a polynomial $p$ on $[\ell,r]$, expand
 152 | \[
 153 |  p(\ell+(r-\ell)s)
 154 |  =\sum_{k=0}^d\beta_k\binom dk s^k(1-s)^{d-k}.
 155 | \]
 156 | Every term in the Bernstein basis is nonnegative on $[0,1]$. Thus nonnegative rational coefficients $\beta_k$ certify nonnegativity of the polynomial on the whole interval, not just at sampled points.
 157 | 
 158 | If the ordinary power coefficients of the polynomial after this affine change are $p_j$, then the exact conversion formula is
 159 | \[
 160 |  \beta_k=\sum_{j=0}^k p_j\frac{\binom kj}{\binom dj}.
 161 | \]
 162 | When necessary, halve the interval by de Casteljau subdivision and apply the same test on the children. All operations are rational additions, products, and divisions.
 163 | 
 164 | The supplied program \texttt{verify.py} obtains the following complete successful check. Depth is measured relative to the interval in the first column.
 165 | \begin{center}
 166 | \begin{tabular}{lrrr}
 167 | \toprule
 168 | Polynomial and interval & Degree & Accepted leaves & Maximum depth\\
 169 | \midrule
 170 | $P'$ on $[0,1]$ &9&1&0\\
 171 | $g_0-\gamma$ on $[0,b]$ &21&1&0\\
 172 | $g_1-\gamma$ on $[b,w]$ &21&13&6\\
 173 | $g_2-\gamma$ on $[w,c_0]$ &11&4&3\\
 174 | $g_3-\gamma$ on $[c_0,1]$ &0&1&0\\
 175 | \bottomrule
 176 | \end{tabular}
 177 | \end{center}
 178 | Every accepted leaf has nonnegative Bernstein coefficients. No numerical tolerance appears in this acceptance test.
 179 | 
 180 | As an independent algebraic check, \texttt{independent\_audit.py} builds all pairwise overlap integrals using symbolic polynomial integration and compares the resulting coefficients over $\mathbb Q$ with \eqref{eq:B}. It then uses exact Sturm counts, rather than Bernstein subdivision: each $g_i-\gamma$ has positive endpoint values and zero real roots on its interval. For monotonicity it factors $P'(s)=(1-s)Q(s)$ and checks positive endpoint values and zero roots of $Q$ on $[0,1]$. Both checks succeed for the supplied data.
```

### Lines 185–250

```text
 185 | \section{An ordinary integrable witness}\label{sec:function}
 186 | The atom in \eqref{eq:mu} can be replaced without losing the uniform correlation lower bound. For $\delta>0$, extend $h$ by its final height:
 187 | \[
 188 |  h_\delta(x)=\begin{cases}
 189 |  h(x),&0\le x\le1,\\
 190 |  1/a,&1<x\le1+\delta,\\
 191 |  0,&\text{otherwise},
 192 |  \end{cases}
 193 | \]
 194 | and define
 195 | \begin{equation}\label{eq:F}
 196 |  F_\delta(x)=\frac a\delta\ind_{[0,\delta]}(x)+h_\delta(x).
 197 | \end{equation}
 198 | Each $F_\delta$ is a nonnegative, bounded, compactly supported ordinary function. In particular it belongs to $L^1(\R)\cap L^2(\R)$.
 199 | 
 200 | \begin{lemma}[One-sided atom removal]\label{lem:removal}
 201 | For every $\delta>0$, $a_{F_\delta}(t)\ge\gamma$ for every $t\in[0,1]$.
 202 | \end{lemma}
 203 | \begin{proof}
 204 | The function $h_\delta$ is nondecreasing on $[0,1+\delta]$. For $0<t<1$, one of the cross terms in the autocorrelation of \eqref{eq:F} satisfies
 205 | \[
 206 |  \frac a\delta\int_0^\delta h_\delta(x+t)\,dx\ge a h(t).
 207 | \]
 208 | Moreover $h_\delta\ge h$ pointwise and both are nonnegative, so
 209 | \[
 210 |  \int_\R h_\delta(x)h_\delta(x+t)\,dx
 211 |  \ge\int_\R h(x)h(x+t)\,dx.
 212 | \]
 213 | The other cross term and the narrow rectangle's own autocorrelation are nonnegative. Adding the displayed inequalities and invoking Lemma~\ref{lem:cert} gives the result on $(0,1)$. Since $F_\delta\in L^2$, its autocorrelation is continuous, so the inequality also holds at $0$ and $1$.
 214 | \end{proof}
 215 | 
 216 | The mass of the intermediate measure is the exact rational number
 217 | \begin{equation}\label{eq:mass}
 218 |  m=a+\frac{wI(1)+b}{a}=1.561018228470523\ldots,
 219 | \end{equation}
 220 | and $\int F_\delta=m+\delta/a$. Therefore
 221 | \begin{equation}\label{eq:ratio}
 222 |  \frac{\inf_{0\le t\le1}a_{F_\delta}(t)}{(\int F_\delta)^2}
 223 |  \ge \frac\gamma{(m+\delta/a)^2}.
 224 | \end{equation}
 225 | 
 226 | \begin{theorem}\label{thm:main}
 227 | Let
 228 | \begin{align*}
 229 |  N&=4713977940944586245580976375978623597750000000000000000,\\
 230 |  D&=11486917427785951575611071745219515905862879073559791929.
 231 | \end{align*}
 232 | Then
 233 | \[
 234 |  \mathcal A\ge \frac ND
 235 |  =0.4103779774321214877852987\ldots>0.4103779.
 236 | \]
 237 | A single explicit witness is $F_{10^{-10}}$. Set
 238 | \[
 239 |  D_F=11486917430134691792906455293684961315501879073559791929.
 240 | \]
 241 | Its ratio is at least
 242 | \[
 243 |  \frac{N}{D_F}=0.4103779773482111379678143\ldots.
 244 | \]
 245 | \end{theorem}
 246 | \begin{proof}
 247 | The second statement is the exact rational evaluation of \eqref{eq:ratio} at $\delta=10^{-10}$. The first follows from \eqref{eq:ratio} by allowing $\delta\downarrow0$ and using the definition of a supremum. The relation $\gamma/m^2=N/D$ and the strict comparison with $4103779/10^7$ are checked as rational identities and integer inequalities by the verifier.
 248 | \end{proof}
 249 | 
 250 | The first displayed value is a limiting lower bound for a supremum; it is not claimed to be attained by the measure $\mu$ in the original function problem. The second bound removes even that limiting step by giving a particular admissible $L^1$ function.
```

### Lines 252–349

```text
 252 | \section{The connection with complete sparse rulers}
 253 | Define the continuous relaxation
 254 | \begin{equation}\label{eq:relax}
 255 |  B_* =\inf\left\{\nu([0,1])^2:
 256 |  \nu\ge0,\ \operatorname{supp}\nu\subseteq[0,1],\
 257 |  \nu*\widetilde\nu\ge\ind_{[-1,1]}(t)\,dt\right\},
 258 | \end{equation}
 259 | where $\widetilde\nu(E)=\nu(-E)$. The inequality is an inequality of positive measures, not a pointwise statement at a single endpoint.
 260 | 
 261 | \begin{proposition}\label{prop:ruler}
 262 | The complete sparse ruler constant satisfies $c^2\ge B_*$. The explicit measure constructed above gives
 263 | \[
 264 |  B_*\le\frac{m^2}{\gamma}
 265 |  =2.4367779339850293520112621\ldots<2.436778.
 266 | \]
 267 | \end{proposition}
 268 | \begin{proof}
 269 | Let $A_L\subseteq\{0,\ldots,L\}$ be complete rulers and suppose $|A_L|/\sqrt L$ converges along a subsequence to a finite value $s$. Form
 270 | \[
 271 |  \nu_L=\frac1{\sqrt L}\sum_{a\in A_L}\delta_{a/L}.
 272 | \]
 273 | These measures have uniformly bounded mass and compact support. Along a further subsequence they converge weakly to a positive measure $\nu$ supported on $[0,1]$, with mass $s$. Completeness implies
 274 | \[
 275 |  \nu_L*\widetilde\nu_L
 276 |  \ge\frac1L\sum_{\substack{-L\le d\le L\\d\ne0}}\delta_{d/L}.
 277 | \]
 278 | The right side converges weakly to Lebesgue measure restricted to $[-1,1]$. Products of weakly convergent finite measures on compact spaces also converge weakly, so the left side tends to $\nu*\widetilde\nu$. Testing against nonnegative continuous functions gives the required domination. Hence $s^2\ge B_*$, and in particular $c^2\ge B_*$.
 279 | 
 280 | Conversely, Lemma~\ref{lem:cert} and symmetry of autocorrelation show that $\mu*\widetilde\mu\ge\gamma\ind_{[-1,1]}dt$. Thus $\nu=\mu/\sqrt\gamma$ is feasible in \eqref{eq:relax}, with squared mass $m^2/\gamma$. The asserted exact value follows from Theorem~\ref{thm:main}.
 281 | \end{proof}
 282 | 
 283 | The direction of the last inequality is crucial. A feasible relaxed object gives an \emph{upper} bound on $B_*$, not an upper bound on $c^2$ and not a lower bound on $c^2$ equal to $2.436778$.
 284 | 
 285 | For reference, the classical Fourier argument also applies directly to \eqref{eq:relax}. Write
 286 | \[
 287 |  \rho=\nu*\widetilde\nu-\ind_{[-1,1]}dt\ge0.
 288 | \]
 289 | If $\widehat\nu(\xi)=\int e^{-i\xi x}\,d\nu(x)$, then
 290 | \[
 291 |  0\le|\widehat\nu(\xi)|^2
 292 |  =2\frac{\sin\xi}{\xi}+\widehat\rho(\xi),
 293 |  \qquad \widehat\rho(\xi)\le\rho(\R)=\nu(\R)^2-2.
 294 | \]
 295 | Consequently
 296 | \[
 297 |  B_*\ge K:=2-2\inf_{\xi\ne0}\frac{\sin\xi}{\xi}
 298 |  =2.434467256422443\ldots.
 299 | \]
 300 | This identifies a narrow interval containing the optimum of this particular relaxation. It does not imply that the discrete optimum is in that interval.
 301 | 
 302 | \begin{corollary}[A quantitative limitation of the relaxation]
 303 | The assumptions in \eqref{eq:relax} alone cannot imply that every feasible measure has squared mass greater than $m^2/\gamma$. In particular, they cannot by themselves prove a bound such as $c^2\ge2.5$ or $c^2\ge3$ by showing $B_*\ge2.5$ or $B_*\ge3$.
 304 | \end{corollary}
 305 | Any such discrete lower bound must use additional information beyond positivity, support, and the weak-limit autocorrelation domination. The certificate does not rule out those stronger discrete bounds.
 306 | 
 307 | \section{A corollary for generalized difference bases}
 308 | For $g,N\ge1$, let $\eta_g(N)$ be the minimum cardinality of an unrestricted finite set $A\subset\Z$ for which every $1\le d\le N$ has at least $g$ ordered representations $d=a-b$. Let
 309 | \[
 310 |  \tau=\inf\left\{\int f:f\ge0,\ f\in L^1(\R),\ a_f(t)\ge1\ \text{for all }0\le t\le1\right\}.
 311 | \]
 312 | Kravitz proved the discrete--continuous identity
 313 | \[
 314 |  \lim_{g\to\infty}\liminf_{N\to\infty}\frac{\eta_g(N)}{\sqrt{gN}}
 315 |  =\tau=
 316 |  \lim_{g\to\infty}\limsup_{N\to\infty}\frac{\eta_g(N)}{\sqrt{gN}}.
 317 | \]
 318 | The order of limits and the unrestricted support of $A$ are part of the statement.\footnote{N. Kravitz, \emph{Generalized difference sets and autocorrelation integrals}, Acta Arithmetica 199 (2021), 199--219, Theorem 1.2; \url{https://arxiv.org/abs/2004.06611}.}
 319 | 
 320 | Scaling $F_\delta$ by $1/\sqrt\gamma$ and then taking $\delta\downarrow0$ immediately yields the new certified comparison
 321 | \begin{equation}\label{eq:tau}
 322 |  \tau\le\frac m{\sqrt\gamma}
 323 |  =1.5610182362756142228486109\ldots<1.5610183.
 324 | \end{equation}
 325 | Thus the same certificate has a discrete consequence for the large-multiplicity limit of generalized difference bases. It does not specialize this upper bound to $g=1$. Nor does it establish a construction with all marks in $[0,N]$; for $g>1$, that exact endpoint restriction would itself prevent $N$ from having $g$ distinct representations.
 326 | 
 327 | \section{Reproducibility and interpretation}
 328 | The minimal certificate consists of the ten exact parameters $a,b,q_0,\ldots,q_7$, the rational margin $\gamma$, and the rectangle width. The file \texttt{certificate.json} records these data and the exact ratios. Its SHA-256 is
 329 | \begin{center}\small\ttfamily
 330 |  e9b58a1068baa81723e55ad016402601\\
 331 |  18ce156ac23c07332cefefc46f552d79
 332 | \end{center}
 333 | The line break is typographical; the digest is a single 64-character hexadecimal string.
 334 | 
 335 | Run the standard-library verifier with
 336 | \begin{lstlisting}[basicstyle=\ttfamily\small]
 337 | python verify.py certificate.json
 338 | \end{lstlisting}
 339 | It reconstructs all polynomials, proves their interval inequalities, recomputes the mass and exact ratios, and rejects any mismatch. A second audit, requiring SymPy, is
 340 | \begin{lstlisting}[basicstyle=\ttfamily\small]
 341 | python independent_audit.py certificate.json
 342 | \end{lstlisting}
 343 | It independently constructs the overlap polynomials and replaces Bernstein positivity by exact Sturm root counts. The supplied output files preserve successful runs of both programs.
 344 | 
 345 | An earlier, separately verified witness used one atom and $16{,}384$ monotone constant-density bins. Its weaker ratio $0.410365636358034\ldots$ was verified by direct integer autocorrelation sums. The degree-ten certificate is smaller and stronger. Higher-degree numerical fits are not used in any theorem in this note.
 346 | 
 347 | There are three logically distinct conclusions. First, the explicit function gives the exact lower bound in Theorem~\ref{thm:main}. Second, Proposition~\ref{prop:ruler} provides a quantified feasible point for the natural continuous ruler relaxation. Third, Kravitz's theorem transfers the function bound to the stated large-$g$ discrete limit. None of these conclusions determines $c$, improves the Wichmann asymptotic upper bound, or asserts global optimality of the polynomial family.
 348 | 
 349 | The certificate has been checked by the programs described above, but it is not a proof-assistant formalization and has not undergone external peer review. Its comparison with located literature is narrower than a claim of worldwide priority.
```

## `Autocorrelation/Targets.lean`

SHA-256: `af350b8ec52f25d1c6b7d2c8b8de4815f0a451de5456b9374883cde4ee1ac7ec`

### Lines 1–84

```text
   1 | import Autocorrelation.Model
   2 | import Autocorrelation.Ratios
   3 | import Mathlib.MeasureTheory.Integral.Bochner.Basic
   4 | import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
   5 | 
   6 | /-!
   7 | These are the unchanged specification propositions, not proofs by themselves.
   8 | Their proofs are in Overlap, Witness, Mass, Uniform and Main, imported by the
   9 | project entry point and checked by Audit.lean. Compiling this file alone does
  10 | not prove the claims.
  11 | -/
  12 | set_option autoImplicit false
  13 | noncomputable section
  14 | namespace Autocorrelation
  15 | open MeasureTheory
  16 | 
  17 | /-- Exact pointwise profile from the manuscript. -/
  18 | def phi (x : ℝ) : ℝ :=
  19 |   if x < b then 0 else
  20 |   if x ≤ c then P ((x-b)/w) else
  21 |   if x ≤ 1 then 1 else 0
  22 | 
  23 | def density (x : ℝ) : ℝ := phi x/a
  24 | 
  25 | def extendedDensity (delta x : ℝ) : ℝ :=
  26 |   if 0 ≤ x ∧ x ≤ 1 then density x else
  27 |   if 1 < x ∧ x ≤ 1+delta then 1/a else 0
  28 | 
  29 | def witness (delta x : ℝ) : ℝ :=
  30 |   (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) + extendedDensity delta x
  31 | 
  32 | def autocorrelation (f : ℝ → ℝ) (t : ℝ) : ℝ :=
  33 |   ∫ x : ℝ, f x * f (x+t)
  34 | 
  35 | def algebraicCorrelation (t : ℝ) : ℝ :=
  36 |   if t ≤ b then g0 t else
  37 |   if t ≤ w then g1 t else
  38 |   if t ≤ c then g2 t else g3 t
  39 | 
  40 | /-- Identification of actual Lebesgue overlap integrals with g0,...,g3. -/
  41 | def OverlapIntegralClaim : Prop :=
  42 |   ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
  43 |     phi t + autocorrelation phi t/a^2 = algebraicCorrelation t
  44 | 
  45 | /-- Measurability/integrability must be proved, not inferred from a totalized integral. -/
  46 | def WitnessAdmissibilityClaim : Prop :=
  47 |   ∀ delta : ℝ, 0 < delta →
  48 |     Integrable (witness delta) ∧
  49 |     Integrable (fun x => (witness delta x)^2) ∧
  50 |     (∀ x : ℝ, 0 ≤ witness delta x) ∧
  51 |     (∀ t : ℝ, Integrable (fun x => witness delta x*witness delta (x+t)))
  52 | 
  53 | def MassIntegralClaim : Prop :=
  54 |   ∀ delta : ℝ, 0 < delta → (∫ x : ℝ, witness delta x) = mass+delta/a
  55 | 
  56 | def UniformCorrelationClaim : Prop :=
  57 |   ∀ delta : ℝ, 0 < delta →
  58 |     ∀ t : ℝ, 0 ≤ t → t ≤ 1 → gamma ≤ autocorrelation (witness delta) t
  59 | 
  60 | /-- The concrete, nonlimiting function version of the manuscript's main result. -/
  61 | def ExplicitMainClaim : Prop :=
  62 |   let f := witness delta0
  63 |   Integrable f ∧
  64 |   Integrable (fun x => (f x)^2) ∧
  65 |   (∀ x : ℝ, 0 ≤ f x) ∧
  66 |   0 < (∫ x : ℝ, f x) ∧
  67 |   (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
  68 |     Integrable (fun x => f x*f (x+t)) ∧
  69 |     explicitRatio ≤ autocorrelation f t / (∫ x : ℝ, f x)^2)
  70 | 
  71 | /-- A lower-bound formulation avoiding an unproved identification of differently
  72 | normalized supremum constants. It supplies arbitrarily close ordinary
  73 | L¹∩L² witnesses, without asserting a separate supremum identification. -/
  74 | def LimitingMainClaim : Prop :=
  75 |   ∀ q : ℝ, q < limitingRatio → ∃ f : ℝ → ℝ,
  76 |     Integrable f ∧
  77 |     Integrable (fun x => (f x)^2) ∧
  78 |     (∀ x : ℝ, 0 ≤ f x) ∧
  79 |     0 < (∫ x : ℝ, f x) ∧
  80 |     (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
  81 |       Integrable (fun x => f x*f (x+t)) ∧
  82 |       q ≤ autocorrelation f t / (∫ x : ℝ, f x)^2)
  83 | 
  84 | end Autocorrelation
```

## `Autocorrelation/Main.lean`

SHA-256: `014da6d164d4c32f8c11c27e5a5310a629dd42f0ed61e2f92fafa15dd2234ba7`

### Lines 1–73

```text
   1 | import Autocorrelation.Uniform
   2 | import Autocorrelation.Mass
   3 | 
   4 | /-! The explicit function theorem and the approximation theorem use the
   5 | same ordinary, integrable witness as the mass and correlation proofs. -/
   6 | set_option autoImplicit false
   7 | set_option maxHeartbeats 0
   8 | noncomputable section
   9 | namespace Autocorrelation
  10 | open MeasureTheory
  11 | 
  12 | theorem witness_ratio_theorem (delta q : ℝ) (hdelta : 0 < delta)
  13 |     (hq : q ≤ gamma / (mass+delta/a)^2) :
  14 |     Integrable (witness delta) ∧
  15 |     Integrable (fun x => (witness delta x)^2) ∧
  16 |     (∀ x : ℝ, 0 ≤ witness delta x) ∧
  17 |     0 < (∫ x : ℝ, witness delta x) ∧
  18 |     (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
  19 |       Integrable (fun x => witness delta x*witness delta (x+t)) ∧
  20 |       q ≤ autocorrelation (witness delta) t / (∫ x : ℝ, witness delta x)^2) := by
  21 |   rcases witness_admissibility delta hdelta with ⟨hi, hs, hn, hc⟩
  22 |   refine ⟨hi, hs, hn, ?_, ?_⟩
  23 |   · rw [mass_integral delta hdelta]
  24 |     exact add_pos mass_pos (div_pos hdelta a_pos)
  25 |   · intro t ht0 ht1
  26 |     refine ⟨hc t, hq.trans ?_⟩
  27 |     rw [mass_integral delta hdelta]
  28 |     exact div_le_div_of_nonneg_right
  29 |       (uniform_correlation delta hdelta t ht0 ht1) (sq_nonneg _)
  30 | 
  31 | theorem explicit_main : ExplicitMainClaim := by
  32 |   have hdelta : 0 < delta0 := by norm_num [delta0]
  33 |   exact witness_ratio_theorem delta0 explicitRatio hdelta explicit_ratio_identity.symm.le
  34 | 
  35 | theorem limiting_main : LimitingMainClaim := by
  36 |   intro q hq
  37 |   by_cases hq0 : q ≤ 0
  38 |   · have hdelta : 0 < delta0 := by norm_num [delta0]
  39 |     refine ⟨witness delta0, witness_ratio_theorem delta0 q hdelta ?_⟩
  40 |     exact hq0.trans (div_nonneg gamma_pos.le (sq_nonneg _))
  41 |   · have hqpos : 0 < q := lt_of_not_ge hq0
  42 |     have hqgamma : q * mass^2 < gamma := by
  43 |       apply (lt_div_iff₀ (sq_pos_of_pos mass_pos)).mp
  44 |       rw [limiting_ratio_identity]
  45 |       exact hq
  46 |     let e : ℝ := gamma-q*mass^2
  47 |     have he : 0 < e := sub_pos.mpr hqgamma
  48 |     have hden : 0 < 2*q*(2*mass+1) :=
  49 |       mul_pos (mul_pos (by norm_num) hqpos) (by linarith [mass_pos])
  50 |     let r : ℝ := min 1 (e/(2*q*(2*mass+1)))
  51 |     have hrpos : 0 < r := lt_min zero_lt_one (div_pos he hden)
  52 |     have hrone : r ≤ 1 := min_le_left _ _
  53 |     have hrsmall : r ≤ e/(2*q*(2*mass+1)) := min_le_right _ _
  54 |     have hrproduct : r*(2*q*(2*mass+1)) ≤ e := (le_div_iff₀ hden).mp hrsmall
  55 |     have hrsq : r^2 ≤ r := by
  56 |       simpa only [pow_two, mul_one] using
  57 |         (mul_le_mul_of_nonneg_left hrone hrpos.le)
  58 |     have herror : q*r^2 ≤ q*r := mul_le_mul_of_nonneg_left hrsq hqpos.le
  59 |     have hstep : q*(mass+r)^2 ≤ q*mass^2 + q*(2*mass+1)*r := by
  60 |       nlinarith only [herror]
  61 |     have hsmall : q*(2*mass+1)*r ≤ e/2 := by
  62 |       apply (le_div_iff₀ (by norm_num : (0 : ℝ) < 2)).mpr
  63 |       calc
  64 |         q*(2*mass+1)*r*2 = r*(2*q*(2*mass+1)) := by ring
  65 |         _ ≤ e := hrproduct
  66 |     have hstrict : q*(mass+r)^2 < gamma := by
  67 |       dsimp only [e] at he hsmall
  68 |       nlinarith only [hstep, hsmall, he]
  69 |     refine ⟨witness (a*r), witness_ratio_theorem (a*r) q (mul_pos a_pos hrpos) ?_⟩
  70 |     rw [mul_div_cancel_left₀ r (ne_of_gt a_pos)]
  71 |     exact ((lt_div_iff₀ (sq_pos_of_pos (add_pos mass_pos hrpos))).mpr hstrict).le
  72 | 
  73 | end Autocorrelation
```

## `Autocorrelation/Overlap.lean`

SHA-256: `ac58b28d0f2d69aeeca50e7b13038cc65af0783ec102d35c786435dad8954b44`

### Lines 250–261

```text
 250 | /-- Identification of the actual Lebesgue autocorrelation with the four exact
 251 | polynomials. The proof includes `t=0`, `t=1`, and all internal breakpoints. -/
 252 | theorem overlap_integral : OverlapIntegralClaim := by
 253 |   intro t ht0 ht1
 254 |   unfold algebraicCorrelation
 255 |   split_ifs with hb hw hc
 256 |   · exact overlap_first t ht0 hb
 257 |   · exact overlap_second t (le_of_lt (lt_of_not_ge hb)) hw
 258 |   · exact overlap_third t (le_of_lt (lt_of_not_ge hw)) hc
 259 |   · exact overlap_fourth t (le_of_lt (lt_of_not_ge hc)) ht1
 260 | 
 261 | end Autocorrelation
```

## `Autocorrelation/Witness.lean`

SHA-256: `29867be6b352283cb84a25281c4cd924317c702c83b8874209eac2abb6313da9`

### Lines 81–171

```text
  81 | theorem witness_nonneg (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
  82 |     0 ≤ witness delta x := by
  83 |   unfold witness
  84 |   apply add_nonneg _ (extendedDensity_nonneg delta x)
  85 |   split_ifs
  86 |   · exact div_nonneg a_pos.le hdelta.le
  87 |   · exact le_rfl
  88 | 
  89 | theorem witness_le (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
  90 |     witness delta x ≤ a / delta + 1 / a := by
  91 |   unfold witness
  92 |   apply add_le_add _ (extendedDensity_le delta x)
  93 |   split_ifs
  94 |   · exact le_rfl
  95 |   · exact div_nonneg a_pos.le hdelta.le
  96 | 
  97 | theorem measurable_witness (delta : ℝ) : Measurable (witness delta) := by
  98 |   unfold witness
  99 |   exact (Measurable.ite measurableSet_Icc measurable_const measurable_const).add
 100 |     (measurable_extendedDensity delta)
 101 | 
 102 | theorem witness_eq_zero_of_not_mem (delta : ℝ) (hdelta : 0 < delta)
 103 |     (x : ℝ) (hx : x ∉ Set.Icc (0 : ℝ) (1 + delta)) : witness delta x = 0 := by
 104 |   have hatom : ¬(0 ≤ x ∧ x ≤ delta) := by
 105 |     intro h
 106 |     exact hx ⟨h.1, by linarith [h.2]⟩
 107 |   simp only [witness, if_neg hatom, zero_add]
 108 |   exact extendedDensity_eq_zero_of_not_mem delta hdelta x hx
 109 | 
 110 | theorem integrable_of_bounded_supported_Icc (f : ℝ → ℝ) (l r M : ℝ)
 111 |     (hm : Measurable f) (hb : ∀ x : ℝ, ‖f x‖ ≤ M)
 112 |     (hz : ∀ x : ℝ, x ∉ Set.Icc l r → f x = 0) : Integrable f := by
 113 |   have hi : IntegrableOn f (Set.Icc l r) :=
 114 |     Measure.integrableOn_of_bounded measure_Icc_lt_top.ne hm.aestronglyMeasurable
 115 |       (Filter.Eventually.of_forall hb)
 116 |   exact hi.integrable_of_forall_not_mem_eq_zero hz
 117 | 
 118 | theorem norm_phi_le (x : ℝ) : ‖phi x‖ ≤ 1 := by
 119 |   rw [Real.norm_eq_abs, abs_of_nonneg (phi_nonneg x)]
 120 |   exact phi_le_one x
 121 | 
 122 | theorem integrable_phi : Integrable phi := by
 123 |   exact integrable_of_bounded_supported_Icc phi 0 1 1 measurable_phi norm_phi_le
 124 |     phi_eq_zero_of_not_mem
 125 | 
 126 | theorem integrable_phi_product (t : ℝ) : Integrable (fun x => phi x * phi (x + t)) := by
 127 |   have hm : Measurable (fun x : ℝ => phi (x + t)) :=
 128 |     measurable_phi.comp (measurable_id.add_const t)
 129 |   have hi := integrable_phi.bdd_mul' hm.aestronglyMeasurable
 130 |     (Filter.Eventually.of_forall (fun x : ℝ => norm_phi_le (x + t)))
 131 |   simpa only [mul_comm] using hi
 132 | 
 133 | theorem norm_extendedDensity_le (delta x : ℝ) : ‖extendedDensity delta x‖ ≤ 1 / a := by
 134 |   rw [Real.norm_eq_abs, abs_of_nonneg (extendedDensity_nonneg delta x)]
 135 |   exact extendedDensity_le delta x
 136 | 
 137 | theorem integrable_extendedDensity (delta : ℝ) (hdelta : 0 < delta) :
 138 |     Integrable (extendedDensity delta) := by
 139 |   exact integrable_of_bounded_supported_Icc (extendedDensity delta) 0 (1 + delta) (1 / a)
 140 |     (measurable_extendedDensity delta) (norm_extendedDensity_le delta)
 141 |     (extendedDensity_eq_zero_of_not_mem delta hdelta)
 142 | 
 143 | theorem norm_witness_le (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
 144 |     ‖witness delta x‖ ≤ a / delta + 1 / a := by
 145 |   rw [Real.norm_eq_abs, abs_of_nonneg (witness_nonneg delta hdelta x)]
 146 |   exact witness_le delta hdelta x
 147 | 
 148 | theorem integrable_witness (delta : ℝ) (hdelta : 0 < delta) : Integrable (witness delta) := by
 149 |   exact integrable_of_bounded_supported_Icc (witness delta) 0 (1 + delta)
 150 |     (a / delta + 1 / a) (measurable_witness delta) (norm_witness_le delta hdelta)
 151 |     (witness_eq_zero_of_not_mem delta hdelta)
 152 | 
 153 | theorem integrable_witness_square (delta : ℝ) (hdelta : 0 < delta) :
 154 |     Integrable (fun x => (witness delta x) ^ 2) := by
 155 |   have hi := (integrable_witness delta hdelta).bdd_mul'
 156 |     (measurable_witness delta).aestronglyMeasurable
 157 |     (Filter.Eventually.of_forall (norm_witness_le delta hdelta))
 158 |   simpa only [pow_two] using hi
 159 | 
 160 | theorem integrable_witness_product (delta : ℝ) (hdelta : 0 < delta) (t : ℝ) :
 161 |     Integrable (fun x => witness delta x * witness delta (x + t)) := by
 162 |   have hm : Measurable (fun x : ℝ => witness delta (x + t)) :=
 163 |     (measurable_witness delta).comp (measurable_id.add_const t)
 164 |   have hi := (integrable_witness delta hdelta).bdd_mul' hm.aestronglyMeasurable
 165 |     (Filter.Eventually.of_forall (fun x : ℝ => norm_witness_le delta hdelta (x + t)))
 166 |   simpa only [mul_comm] using hi
 167 | 
 168 | theorem witness_admissibility : WitnessAdmissibilityClaim := by
 169 |   intro delta hdelta
 170 |   exact ⟨integrable_witness delta hdelta, integrable_witness_square delta hdelta,
 171 |     witness_nonneg delta hdelta, integrable_witness_product delta hdelta⟩
```

## `Autocorrelation/Mass.lean`

SHA-256: `9d9eb542d12ce61d1e98fd2d12ebe56922f09cd620cf0db7b222977e13aef77f`

### Lines 88–113

```text
  88 | theorem integral_extendedDensity (delta : ℝ) (hdelta : 0 < delta) :
  89 |     (∫ x : ℝ, extendedDensity delta x) = (w*I 1+b)/a + delta/a := by
  90 |   have hdensity : Integrable density := integrable_phi.div_const a
  91 |   have htail : Integrable
  92 |       ((Set.Ioc (1 : ℝ) (1+delta)).indicator (fun _ : ℝ => 1/a)) :=
  93 |     ((continuous_const : Continuous (fun _ : ℝ => 1/a)).integrableOn_Ioc).integrable_indicator
  94 |       measurableSet_Ioc
  95 |   have hmass : (∫ x : ℝ, density x) = (w*I 1+b)/a := by
  96 |     unfold density
  97 |     rw [integral_div, integral_phi]
  98 |   rw [extendedDensity_eq_density_add_tail, integral_add hdensity htail, hmass,
  99 |     integral_indicator_const (1/a) measurableSet_Ioc,
 100 |     Real.volume_real_Ioc_of_le (by linarith : (1 : ℝ) ≤ 1+delta)]
 101 |   simp only [smul_eq_mul]
 102 |   ring
 103 | 
 104 | theorem mass_integral : MassIntegralClaim := by
 105 |   intro delta hdelta
 106 |   change (∫ x : ℝ,
 107 |     (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) + extendedDensity delta x) = _
 108 |   rw [integral_add (integrable_rectangle delta) (integrable_extendedDensity delta hdelta),
 109 |     rectangle_integral delta hdelta, integral_extendedDensity delta hdelta]
 110 |   unfold mass
 111 |   ring
 112 | 
 113 | end Autocorrelation
```

## `Autocorrelation/Uniform.lean`

SHA-256: `bd51ce0025455a28d9ad9b05b1213e78e6863a9a7d85b07ad43fd454adf22d30`

### Lines 1–64

```text
   1 | import Autocorrelation.Extension
   2 | import Autocorrelation.Mass
   3 | import Autocorrelation.Overlap
   4 | 
   5 | /-! The ordinary rectangle witness dominates the exact overlap certificate,
   6 | including both endpoints of the shift interval. -/
   7 | set_option autoImplicit false
   8 | noncomputable section
   9 | namespace Autocorrelation
  10 | open MeasureTheory
  11 | 
  12 | theorem integrable_density_product (t : ℝ) :
  13 |     Integrable (fun x => density x * density (x+t)) := by
  14 |   have h := (integrable_phi_product t).div_const (a^2)
  15 |   convert h using 1 <;> funext x <;> simp only [density] <;> ring
  16 | 
  17 | theorem integral_density_product (t : ℝ) :
  18 |     (∫ x : ℝ, density x * density (x+t)) = autocorrelation phi t / a^2 := by
  19 |   have heq : (fun x => density x * density (x+t)) =
  20 |       (fun x => (phi x * phi (x+t)) / a^2) := by
  21 |     funext x
  22 |     simp only [density]
  23 |     ring
  24 |   rw [heq, integral_div]
  25 |   rfl
  26 | 
  27 | theorem witness_product_dominates (delta t x : ℝ) (hd : 0 < delta)
  28 |     (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
  29 |     (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) * density t +
  30 |       density x * density (x+t) ≤ witness delta x * witness delta (x+t) := by
  31 |   have hr (y : ℝ) : 0 ≤ (if 0 ≤ y ∧ y ≤ delta then a/delta else 0) := by
  32 |     split_ifs
  33 |     · exact div_nonneg a_pos.le hd.le
  34 |     · exact le_rfl
  35 |   apply autocorrelation_product_lower _ _ _ _ _ _ _ (hr x) (hr (x+t))
  36 |     (density_nonneg x) (density_nonneg (x+t))
  37 |     (density_le_extendedDensity delta x) (density_le_extendedDensity delta (x+t))
  38 |   by_cases hx : 0 ≤ x ∧ x ≤ delta
  39 |   · simp only [if_pos hx]
  40 |     apply mul_le_mul_of_nonneg_left _ (div_nonneg a_pos.le hd.le)
  41 |     have h := monotone_extension_comparison delta t x (extendedDensity delta)
  42 |       hd ht0 ht1 hx.1 hx.2 (extendedDensity_monotoneOn delta)
  43 |     have heq : extendedDensity delta t = density t := by
  44 |       simp only [extendedDensity, if_pos (show 0 ≤ t ∧ t ≤ 1 from ⟨ht0, ht1⟩)]
  45 |     rwa [heq] at h
  46 |   · simp only [if_neg hx, zero_mul, le_refl]
  47 | 
  48 | theorem uniform_correlation : UniformCorrelationClaim := by
  49 |   intro delta hd t ht0 ht1
  50 |   have hi : Integrable (fun x : ℝ =>
  51 |       (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) * density t +
  52 |         density x * density (x+t)) :=
  53 |     ((integrable_rectangle delta).mul_const (density t)).add (integrable_density_product t)
  54 |   have hbound := integral_mono hi (integrable_witness_product delta hd t)
  55 |     (fun x => witness_product_dominates delta t x hd ht0 ht1)
  56 |   have ha : a * density t = phi t := by
  57 |     unfold density
  58 |     field_simp [ne_of_gt a_pos]
  59 |   rw [integral_add ((integrable_rectangle delta).mul_const (density t))
  60 |     (integrable_density_product t), integral_mul_const, rectangle_integral delta hd,
  61 |     ha, integral_density_product, overlap_integral t ht0 ht1] at hbound
  62 |   exact (algebraicCorrelation_lower t ht0 ht1).trans hbound
  63 | 
  64 | end Autocorrelation
```

## `Autocorrelation/Extension.lean`

SHA-256: `4a251599cacbebb3230160ea0b64dd8b09df5fe7bf7aaa6fd506ddc670ca508d`

### Lines 1–77

```text
   1 | import Autocorrelation.Witness
   2 | import Autocorrelation.AtomRemovalAlgebra
   3 | 
   4 | set_option autoImplicit false
   5 | noncomputable section
   6 | namespace Autocorrelation
   7 | 
   8 | theorem ramp_argument_mem (x : ℝ) (hx : b ≤ x) (hxc : x ≤ c) :
   9 |     (x - b) / w ∈ Set.Icc (0 : ℝ) 1 := by
  10 |   constructor
  11 |   · exact div_nonneg (sub_nonneg.mpr hx) w_pos.le
  12 |   · apply (div_le_one w_pos).2
  13 |     dsimp [c, w] at *
  14 |     linarith
  15 | 
  16 | theorem phi_monotoneOn : MonotoneOn phi (Set.Icc 0 1) := by
  17 |   intro x hx y hy hxy
  18 |   by_cases hxb : x < b
  19 |   · simpa [phi, hxb] using phi_nonneg y
  20 |   have hyb : ¬ y < b := by linarith
  21 |   by_cases hxc : x ≤ c
  22 |   · by_cases hyc : y ≤ c
  23 |     · simp only [phi, if_neg hxb, if_pos hxc, if_neg hyb, if_pos hyc]
  24 |       exact P_monotoneOn (ramp_argument_mem x (le_of_not_gt hxb) hxc)
  25 |         (ramp_argument_mem y (le_of_not_gt hyb) hyc)
  26 |         (div_le_div_of_nonneg_right (sub_le_sub_right hxy b) w_pos.le)
  27 |     · have hp := (P_bounds ((x-b)/w)
  28 |         (ramp_argument_mem x (le_of_not_gt hxb) hxc).1
  29 |         (ramp_argument_mem x (le_of_not_gt hxb) hxc).2).2
  30 |       simpa [phi, hxb, hxc, hyb, hyc, hy.2] using hp
  31 |   · have hyc : ¬ y ≤ c := by linarith
  32 |     simp [phi, hxb, hxc, hyb, hyc, hx.2, hy.2]
  33 | 
  34 | theorem density_eq_zero_outside (x : ℝ) (hx : ¬ (0 ≤ x ∧ x ≤ 1)) :
  35 |     density x = 0 := by
  36 |   by_cases hx0 : 0 ≤ x
  37 |   · have hx1 : ¬ x ≤ 1 := by tauto
  38 |     have hxb : ¬ x < b := by have := breakpoint_order; linarith
  39 |     have hxc : ¬ x ≤ c := by have := breakpoint_order; linarith
  40 |     simp [density, phi, hxb, hxc, hx1]
  41 |   · have hxb : x < b := by have := breakpoint_order.1; linarith
  42 |     simp [density, phi, hxb]
  43 | 
  44 | theorem density_le_extendedDensity (delta x : ℝ) :
  45 |     density x ≤ extendedDensity delta x := by
  46 |   by_cases hx : 0 ≤ x ∧ x ≤ 1
  47 |   · simp [extendedDensity, hx]
  48 |   · rw [density_eq_zero_outside x hx]
  49 |     exact extendedDensity_nonneg delta x
  50 | 
  51 | theorem extendedDensity_monotoneOn (delta : ℝ) :
  52 |     MonotoneOn (extendedDensity delta) (Set.Icc 0 (1 + delta)) := by
  53 |   intro x hx y hy hxy
  54 |   by_cases hx1 : x ≤ 1
  55 |   · by_cases hy1 : y ≤ 1
  56 |     · simp only [extendedDensity, if_pos (show 0 ≤ x ∧ x ≤ 1 from ⟨hx.1, hx1⟩),
  57 |         if_pos (show 0 ≤ y ∧ y ≤ 1 from ⟨hy.1, hy1⟩), density]
  58 |       exact div_le_div_of_nonneg_right (phi_monotoneOn ⟨hx.1, hx1⟩ ⟨hy.1, hy1⟩ hxy) a_pos.le
  59 |     · have hy01 : ¬ (0 ≤ y ∧ y ≤ 1) := by tauto
  60 |       simp only [extendedDensity, if_pos (show 0 ≤ x ∧ x ≤ 1 from ⟨hx.1, hx1⟩), if_neg hy01,
  61 |         if_pos (show 1 < y ∧ y ≤ 1+delta from ⟨lt_of_not_ge hy1, hy.2⟩), density]
  62 |       exact div_le_div_of_nonneg_right (phi_le_one x) a_pos.le
  63 |   · have hy1 : ¬ y ≤ 1 := by linarith
  64 |     have hx01 : ¬ (0 ≤ x ∧ x ≤ 1) := by tauto
  65 |     have hy01 : ¬ (0 ≤ y ∧ y ≤ 1) := by tauto
  66 |     simp [extendedDensity, hx01, hy01, lt_of_not_ge hx1, lt_of_not_ge hy1, hx.2, hy.2]
  67 | 
  68 | theorem algebraicCorrelation_lower (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
  69 |     gamma ≤ algebraicCorrelation t := by
  70 |   unfold algebraicCorrelation
  71 |   split_ifs with hb hw hc
  72 |   · exact g0_lower t ht0 hb
  73 |   · exact g1_lower t (le_of_lt (lt_of_not_ge hb)) hw
  74 |   · exact g2_lower t (le_of_lt (lt_of_not_ge hw)) hc
  75 |   · exact g3_lower t (le_of_lt (lt_of_not_ge hc)) ht1
  76 | 
  77 | end Autocorrelation
```

## `Autocorrelation/Profile.lean`

SHA-256: `dc656e6fa5f70a455c3ba58489de3f85b6f049ee73f51b0172976987300d915c`

### Lines 15–58

```text
  15 | 
  16 | def a : ℝ := ((626600210121 : ℝ) / 1000000000000)
  17 | def b : ℝ := ((40047498753 : ℝ) / 250000000000)
  18 | def gamma : ℝ := ((99999999 : ℝ) / 100000000)
  19 | def delta0 : ℝ := ((1 : ℝ) / 10000000000)
  20 | def w : ℝ := 1 - 2*b
  21 | def c : ℝ := 1-b
  22 | 
  23 | def cheb (z : ℝ) : ℕ → ℝ
  24 |   | 0 => 1
  25 |   | 1 => z
  26 |   | n+2 => 2*z*cheb z (n+1) - cheb z n
  27 | 
  28 | def paperP (x : ℝ) : ℝ := 2*x-x^2+x*(1-x)^2*(((-423577846263 : ℝ) / 1000000000000) * cheb (2*x-1) 0 +
  29 |     ((290387575223 : ℝ) / 1000000000000) * cheb (2*x-1) 1 +
  30 |     ((36766437 : ℝ) / 3125000000) * cheb (2*x-1) 2 +
  31 |     ((-5796017613 : ℝ) / 1000000000000) * cheb (2*x-1) 3 +
  32 |     ((50885811 : ℝ) / 250000000000) * cheb (2*x-1) 4 +
  33 |     ((83340881 : ℝ) / 125000000000) * cheb (2*x-1) 5 +
  34 |     ((120301079 : ℝ) / 500000000000) * cheb (2*x-1) 6 +
  35 |     ((28140971 : ℝ) / 250000000000) * cheb (2*x-1) 7)
  36 | 
  37 | def P (x : ℝ) : ℝ :=
  38 |   (((1303260710437 : ℝ) / 1000000000000) * x ^ 1 + ((398167103833 : ℝ) / 500000000000) * x ^ 2 + ((-1338637880051 : ℝ) / 1000000000000) * x ^ 3 + ((195266960359 : ℝ) / 250000000000) * x ^ 4 + ((-4297368247 : ℝ) / 1250000000) * x ^ 5 + ((262085157587 : ℝ) / 31250000000) * x ^ 6 + ((-11256207949 : ℝ) / 976562500) * x ^ 7 + ((4732570027 : ℝ) / 488281250) * x ^ 8 + ((-223580329 : ℝ) / 48828125) * x ^ 9 + ((225127768 : ℝ) / 244140625) * x ^ 10)
  39 | 
  40 | def DP (x : ℝ) : ℝ :=
  41 |   (((1303260710437 : ℝ) / 1000000000000) + ((398167103833 : ℝ) / 250000000000) * x ^ 1 + ((-4015913640153 : ℝ) / 1000000000000) * x ^ 2 + ((195266960359 : ℝ) / 62500000000) * x ^ 3 + ((-4297368247 : ℝ) / 250000000) * x ^ 4 + ((786255472761 : ℝ) / 15625000000) * x ^ 5 + ((-78793455643 : ℝ) / 976562500) * x ^ 6 + ((18930280108 : ℝ) / 244140625) * x ^ 7 + ((-2012222961 : ℝ) / 48828125) * x ^ 8 + ((450255536 : ℝ) / 48828125) * x ^ 9)
  42 | 
  43 | def I (x : ℝ) : ℝ :=
  44 |   (((1303260710437 : ℝ) / 2000000000000) * x ^ 2 + ((398167103833 : ℝ) / 1500000000000) * x ^ 3 + ((-1338637880051 : ℝ) / 4000000000000) * x ^ 4 + ((195266960359 : ℝ) / 1250000000000) * x ^ 5 + ((-4297368247 : ℝ) / 7500000000) * x ^ 6 + ((262085157587 : ℝ) / 218750000000) * x ^ 7 + ((-11256207949 : ℝ) / 7812500000) * x ^ 8 + ((4732570027 : ℝ) / 4394531250) * x ^ 9 + ((-223580329 : ℝ) / 488281250) * x ^ 10 + ((225127768 : ℝ) / 2685546875) * x ^ 11)
  45 | 
  46 | theorem P_matches_paper (x : ℝ) : P x = paperP x := by
  47 |   norm_num [P, paperP, cheb] <;> ring
  48 | 
  49 | theorem P_zero : P 0 = 0 := by norm_num [P]
  50 | theorem P_one : P 1 = 1 := by norm_num [P]
  51 | theorem DP_one : DP 1 = 0 := by norm_num [DP]
  52 | theorem I_zero : I 0 = 0 := by norm_num [I]
  53 | theorem a_pos : 0 < a := by norm_num [a]
  54 | theorem gamma_pos : 0 < gamma := by norm_num [gamma]
  55 | theorem w_pos : 0 < w := by norm_num [w, b]
  56 | theorem breakpoint_order : 0 < b ∧ b < w ∧ w < c ∧ c < 1 := by
  57 |   norm_num [b, w, c]
  58 | 
```

## `Autocorrelation/Ratios.lean`

SHA-256: `06c2ca07a3abf9dca4598cae3f44ce1bc7af8247aa5c262afb62e0ea487ce923`

### Lines 1–36

```text
   1 | import Autocorrelation.CorrelationModel
   2 | 
   3 | set_option autoImplicit false
   4 | set_option maxHeartbeats 0
   5 | noncomputable section
   6 | namespace Autocorrelation
   7 | 
   8 | def mass : ℝ := a + (w*I 1+b)/a
   9 | def limitingRatio : ℝ := (4713977940944586245580976375978623597750000000000000000 : ℝ)/11486917427785951575611071745219515905862879073559791929
  10 | def explicitRatio : ℝ := (4713977940944586245580976375978623597750000000000000000 : ℝ)/11486917430134691792906455293684961315501879073559791929
  11 | 
  12 | theorem mass_exact : mass = ((3389235522619511253196890923 : ℝ) / 2171169728069265000000000000) := by
  13 |   norm_num [mass, a, b, w, I]
  14 | 
  15 | theorem mass_pos : 0 < mass := by rw [mass_exact]; norm_num
  16 | 
  17 | theorem limiting_ratio_identity : gamma / mass^2 = limitingRatio := by
  18 |   rw [mass_exact]
  19 |   norm_num [gamma, limitingRatio]
  20 | 
  21 | theorem explicit_ratio_identity :
  22 |     gamma / (mass+delta0/a)^2 = explicitRatio := by
  23 |   rw [mass_exact]
  24 |   norm_num [gamma, delta0, a, explicitRatio]
  25 | 
  26 | theorem limiting_ratio_gt : (4103779 : ℝ)/10000000 < limitingRatio := by
  27 |   norm_num [limitingRatio]
  28 | 
  29 | theorem explicit_ratio_gt : (4103779 : ℝ)/10000000 < explicitRatio := by
  30 |   norm_num [explicitRatio]
  31 | 
  32 | theorem relaxation_mass_arithmetic : mass^2/gamma < (2436778 : ℝ)/1000000 := by
  33 |   rw [mass_exact]
  34 |   norm_num [gamma]
  35 | 
  36 | end Autocorrelation
```

## `Audit.lean`

SHA-256: `3eeb24111e8790aa986a104e3409fed2e4b06096353fd6ee71d70fc2c8ec1333`

### Lines 1–38

```text
   1 | import Autocorrelation
   2 | 
   3 | -- Run scripts/check.ps1 on Windows or scripts/check.sh on Unix.
   4 | #print axioms Autocorrelation.finite_certificate
   5 | #print axioms Autocorrelation.P_matches_paper
   6 | #print axioms Autocorrelation.hasDerivAt_P
   7 | #print axioms Autocorrelation.hasDerivAt_I
   8 | #print axioms Autocorrelation.hasDerivAt_RR
   9 | #print axioms Autocorrelation.P_monotoneOn
  10 | #print axioms Autocorrelation.P_bounds
  11 | #print axioms Autocorrelation.integral_P
  12 | #print axioms Autocorrelation.integral_PP
  13 | #print axioms Autocorrelation.g0_g1_match
  14 | #print axioms Autocorrelation.g1_g2_match
  15 | #print axioms Autocorrelation.g2_g3_match
  16 | #print axioms Autocorrelation.limiting_ratio_identity
  17 | #print axioms Autocorrelation.explicit_ratio_identity
  18 | #print axioms Autocorrelation.limiting_ratio_gt
  19 | #print axioms Autocorrelation.explicit_ratio_gt
  20 | #print axioms Autocorrelation.relaxation_mass_arithmetic
  21 | #print axioms Autocorrelation.monotone_extension_comparison
  22 | #print axioms Autocorrelation.autocorrelation_product_lower
  23 | 
  24 | #print axioms Autocorrelation.overlap_integral
  25 | #print axioms Autocorrelation.witness_admissibility
  26 | #print axioms Autocorrelation.mass_integral
  27 | #print axioms Autocorrelation.uniform_correlation
  28 | #print axioms Autocorrelation.explicit_main
  29 | #print axioms Autocorrelation.limiting_main
  30 | 
  31 | -- These type ascriptions ensure the audited declarations prove the original
  32 | -- specification propositions, with no additional unproved hypotheses.
  33 | example : Autocorrelation.OverlapIntegralClaim := Autocorrelation.overlap_integral
  34 | example : Autocorrelation.WitnessAdmissibilityClaim := Autocorrelation.witness_admissibility
  35 | example : Autocorrelation.MassIntegralClaim := Autocorrelation.mass_integral
  36 | example : Autocorrelation.UniformCorrelationClaim := Autocorrelation.uniform_correlation
  37 | example : Autocorrelation.ExplicitMainClaim := Autocorrelation.explicit_main
  38 | example : Autocorrelation.LimitingMainClaim := Autocorrelation.limiting_main
```

## `lean-toolchain`

SHA-256: `55e97be96000b5e9e290c9e74482e5e317861499a5540353ce845471bded8cea`

### Lines 1–1

```text
   1 | leanprover/lean4:v4.19.0
```

## `lakefile.toml`

SHA-256: `b66b0e604d0e56b06172f39b2d3153f8d843725c57d647053c755c41d4787873`

### Lines 1–12

```text
   1 | name = "autocorrelation_lean"
   2 | version = "0.1.0"
   3 | defaultTargets = ["Autocorrelation"]
   4 | 
   5 | [[lean_lib]]
   6 | name = "Autocorrelation"
   7 | 
   8 | [[require]]
   9 | name = "mathlib"
  10 | git = "https://github.com/leanprover-community/mathlib4.git"
  11 | # Exact commit of the official v4.19.0 tag.
  12 | rev = "c44e0c8ee63ca166450922a373c7409c5d26b00b"
```

## `lake-manifest.json`

SHA-256: `cb11b5e740979bedd9cad8aa804fb7cff2a5cd2874ae281b9f00fcfffa2a0ef8`

### Lines 1–95

```text
   1 | {"version": "1.1.0",
   2 |  "packagesDir": ".lake/packages",
   3 |  "packages":
   4 |  [{"url": "https://github.com/leanprover-community/mathlib4.git",
   5 |    "type": "git",
   6 |    "subDir": null,
   7 |    "scope": "",
   8 |    "rev": "c44e0c8ee63ca166450922a373c7409c5d26b00b",
   9 |    "name": "mathlib",
  10 |    "manifestFile": "lake-manifest.json",
  11 |    "inputRev": "c44e0c8ee63ca166450922a373c7409c5d26b00b",
  12 |    "inherited": false,
  13 |    "configFile": "lakefile.lean"},
  14 |   {"url": "https://github.com/leanprover-community/plausible",
  15 |    "type": "git",
  16 |    "subDir": null,
  17 |    "scope": "leanprover-community",
  18 |    "rev": "77e08eddc486491d7b9e470926b3dbe50319451a",
  19 |    "name": "plausible",
  20 |    "manifestFile": "lake-manifest.json",
  21 |    "inputRev": "main",
  22 |    "inherited": true,
  23 |    "configFile": "lakefile.toml"},
  24 |   {"url": "https://github.com/leanprover-community/LeanSearchClient",
  25 |    "type": "git",
  26 |    "subDir": null,
  27 |    "scope": "leanprover-community",
  28 |    "rev": "25078369972d295301f5a1e53c3e5850cf6d9d4c",
  29 |    "name": "LeanSearchClient",
  30 |    "manifestFile": "lake-manifest.json",
  31 |    "inputRev": "main",
  32 |    "inherited": true,
  33 |    "configFile": "lakefile.toml"},
  34 |   {"url": "https://github.com/leanprover-community/import-graph",
  35 |    "type": "git",
  36 |    "subDir": null,
  37 |    "scope": "leanprover-community",
  38 |    "rev": "e6a9f0f5ee3ccf7443a0070f92b62f8db12ae82b",
  39 |    "name": "importGraph",
  40 |    "manifestFile": "lake-manifest.json",
  41 |    "inputRev": "main",
  42 |    "inherited": true,
  43 |    "configFile": "lakefile.toml"},
  44 |   {"url": "https://github.com/leanprover-community/ProofWidgets4",
  45 |    "type": "git",
  46 |    "subDir": null,
  47 |    "scope": "leanprover-community",
  48 |    "rev": "c4919189477c3221e6a204008998b0d724f49904",
  49 |    "name": "proofwidgets",
  50 |    "manifestFile": "lake-manifest.json",
  51 |    "inputRev": "v0.0.57",
  52 |    "inherited": true,
  53 |    "configFile": "lakefile.lean"},
  54 |   {"url": "https://github.com/leanprover-community/aesop",
  55 |    "type": "git",
  56 |    "subDir": null,
  57 |    "scope": "leanprover-community",
  58 |    "rev": "5d50b08dedd7d69b3d9b3176e0d58a23af228884",
  59 |    "name": "aesop",
  60 |    "manifestFile": "lake-manifest.json",
  61 |    "inputRev": "master",
  62 |    "inherited": true,
  63 |    "configFile": "lakefile.toml"},
  64 |   {"url": "https://github.com/leanprover-community/quote4",
  65 |    "type": "git",
  66 |    "subDir": null,
  67 |    "scope": "leanprover-community",
  68 |    "rev": "fa4f7f15d97591a9cf3aa7724ba371c7fc6dda02",
  69 |    "name": "Qq",
  70 |    "manifestFile": "lake-manifest.json",
  71 |    "inputRev": "master",
  72 |    "inherited": true,
  73 |    "configFile": "lakefile.toml"},
  74 |   {"url": "https://github.com/leanprover-community/batteries",
  75 |    "type": "git",
  76 |    "subDir": null,
  77 |    "scope": "leanprover-community",
  78 |    "rev": "f5d04a9c4973d401c8c92500711518f7c656f034",
  79 |    "name": "batteries",
  80 |    "manifestFile": "lake-manifest.json",
  81 |    "inputRev": "main",
  82 |    "inherited": true,
  83 |    "configFile": "lakefile.toml"},
  84 |   {"url": "https://github.com/leanprover/lean4-cli",
  85 |    "type": "git",
  86 |    "subDir": null,
  87 |    "scope": "leanprover",
  88 |    "rev": "02dbd02bc00ec4916e99b04b2245b30200e200d0",
  89 |    "name": "Cli",
  90 |    "manifestFile": "lake-manifest.json",
  91 |    "inputRev": "main",
  92 |    "inherited": true,
  93 |    "configFile": "lakefile.toml"}],
  94 |  "name": "autocorrelation_lean",
  95 |  "lakeDir": ".lake"}
```

## `logs/lean-axioms.log`

SHA-256: `5add99d0b77f1bdf9a3e9b50fbdb34611355f2ea680e4c88c32242f9c37fa322`

### Lines 1–26

```text
   1 | warning: mathlib: repository '.\.\.lake/packages\mathlib' has local changes
   2 | 'Autocorrelation.finite_certificate' depends on axioms: [propext, Classical.choice, Quot.sound]
   3 | 'Autocorrelation.P_matches_paper' depends on axioms: [propext, Classical.choice, Quot.sound]
   4 | 'Autocorrelation.hasDerivAt_P' depends on axioms: [propext, Classical.choice, Quot.sound]
   5 | 'Autocorrelation.hasDerivAt_I' depends on axioms: [propext, Classical.choice, Quot.sound]
   6 | 'Autocorrelation.hasDerivAt_RR' depends on axioms: [propext, Classical.choice, Quot.sound]
   7 | 'Autocorrelation.P_monotoneOn' depends on axioms: [propext, Classical.choice, Quot.sound]
   8 | 'Autocorrelation.P_bounds' depends on axioms: [propext, Classical.choice, Quot.sound]
   9 | 'Autocorrelation.integral_P' depends on axioms: [propext, Classical.choice, Quot.sound]
  10 | 'Autocorrelation.integral_PP' depends on axioms: [propext, Classical.choice, Quot.sound]
  11 | 'Autocorrelation.g0_g1_match' depends on axioms: [propext, Classical.choice, Quot.sound]
  12 | 'Autocorrelation.g1_g2_match' depends on axioms: [propext, Classical.choice, Quot.sound]
  13 | 'Autocorrelation.g2_g3_match' depends on axioms: [propext, Classical.choice, Quot.sound]
  14 | 'Autocorrelation.limiting_ratio_identity' depends on axioms: [propext, Classical.choice, Quot.sound]
  15 | 'Autocorrelation.explicit_ratio_identity' depends on axioms: [propext, Classical.choice, Quot.sound]
  16 | 'Autocorrelation.limiting_ratio_gt' depends on axioms: [propext, Classical.choice, Quot.sound]
  17 | 'Autocorrelation.explicit_ratio_gt' depends on axioms: [propext, Classical.choice, Quot.sound]
  18 | 'Autocorrelation.relaxation_mass_arithmetic' depends on axioms: [propext, Classical.choice, Quot.sound]
  19 | 'Autocorrelation.monotone_extension_comparison' depends on axioms: [propext, Classical.choice, Quot.sound]
  20 | 'Autocorrelation.autocorrelation_product_lower' depends on axioms: [propext, Classical.choice, Quot.sound]
  21 | 'Autocorrelation.overlap_integral' depends on axioms: [propext, Classical.choice, Quot.sound]
  22 | 'Autocorrelation.witness_admissibility' depends on axioms: [propext, Classical.choice, Quot.sound]
  23 | 'Autocorrelation.mass_integral' depends on axioms: [propext, Classical.choice, Quot.sound]
  24 | 'Autocorrelation.uniform_correlation' depends on axioms: [propext, Classical.choice, Quot.sound]
  25 | 'Autocorrelation.explicit_main' depends on axioms: [propext, Classical.choice, Quot.sound]
  26 | 'Autocorrelation.limiting_main' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## `STATUS.json`

SHA-256: `b0bb0c74e2250d867938022cb96e801306bcd34e7f94cac94b87266bc3e79e5a`

### Lines 1–38

```text
   1 | {
   2 |   "request_date": "2026-09-17",
   3 |   "artifact_kind": "ALL_SIX_TARGETS_LEAN_VERIFIED_CLEAN_BUILD_PASSED",
   4 |   "source_manuscript": "An atomic-polynomial certificate for minimum autocorrelation",
   5 |   "source_certificate_sha256": "e9b58a1068baa81723e55ad01640260118ce156ac23c07332cefefc46f552d79",
   6 |   "lean_source_files": 41,
   7 |   "lean_compiler_executed": true,
   8 |   "lean_build_status": "PASS_CLEAN_BUILD_AND_COMPLETE_AXIOM_AUDIT",
   9 |   "lean_check_script_exit_code": 0,
  10 |   "lean_install_download_status": "OFFICIAL_WINDOWS_PACKAGE_INSTALLED",
  11 |   "lean_install_download_curl_exit_code": 35,
  12 |   "target_lean_version": "leanprover/lean4:v4.19.0",
  13 |   "target_mathlib_tag": "v4.19.0",
  14 |   "target_dependency_compatibility_tested": "REAL_FULL_LEAN_4_19_BUILD_AND_AUDIT_PASSED",
  15 |   "full_main_theorem_formalized": true,
  16 |   "main_targets_are_proposition_definitions_only": false,
  17 |   "bernstein_leaves": 20,
  18 |   "nonnegative_integer_coefficients": 367,
  19 |   "python_checks": {
  20 |     "original_exact_bernstein": "PASS_THIS_RUN",
  21 |     "independent_symbolic_overlap_and_sturm": "PASS_THIS_RUN",
  22 |     "generated_leaf_identity_and_cover_audit": "PASS_THIS_RUN",
  23 |     "generated_leaf_binding_to_original_chebyshev_certificate": "PASS_THIS_RUN",
  24 |     "single_coefficient_mutation_negative_control": "PASS_REJECTED_THIS_RUN",
  25 |     "regeneration_source_and_leaf_hashes": "PASS_UNCHANGED_THIS_RUN"
  26 |   },
  27 |   "unproved_obligations": [],
  28 |   "excluded_claims": [
  29 |     "No formal definition of paper constant A as sSup, or proof of its equivalence to the ordinary-function witness statement",
  30 |     "No assertion that every later theorem/corollary in the paper is formalized",
  31 |     "No improved bound for the complete sparse ruler constant or resolution of Erdos #170",
  32 |     "No formalization of weak-limit, Fourier or generalized difference-base corollaries"
  33 |   ],
  34 |   "evidence_files": [
  35 |     "VERIFICATION_REPORT.md",
  36 |     "lake-manifest.json",
  37 |     "logs/current-run/dependency-revisions.json",
  38 |     "logs/current-run",
```

### Lines 150–180

```text
 150 |     "Autocorrelation.g2_expansion",
 151 |     "Autocorrelation.g3_expansion"
 152 |   ],
 153 |   "allowed_axioms": [
 154 |     "propext",
 155 |     "Classical.choice",
 156 |     "Quot.sound"
 157 |   ],
 158 |   "full_main_axiom_audit_status": "PASS_25_THEOREMS_STANDARD_AXIOMS_ONLY",
 159 |   "clean_rebuild_status": "PASS",
 160 |   "lean_full_build_exit_code": 0,
 161 |   "lean_full_audit_exit_code": 0,
 162 |   "formalized_main_scope": "EXPLICIT_ORDINARY_FUNCTION_AND_ARBITRARY_Q_BELOW_LIMITING_RATIO_WITNESSES",
 163 |   "paper_entirely_formalized": false,
 164 |   "paper_A_sSup_defined": false,
 165 |   "paper_A_sSup_equivalence_formalized": false,
 166 |   "clean_rebuild_evidence": "logs/current-run/20260917T043659.9394903Z_clean-check.json",
 167 |   "original_claim_type_ascriptions_passed": true,
 168 |   "all_core_theorems_imported": true,
 169 |   "dependency_final_check_passed": true,
 170 |   "dependency_packages_verified": 9,
 171 |   "generator_synchronized": true,
 172 |   "regeneration_check_passed": true,
 173 |   "regeneration_changed_artifacts": [],
 174 |   "regeneration_comparison_scope": "All existing Autocorrelation/**/*.lean and bernstein_leaves.json",
 175 |   "remaining_blockers": [],
 176 |   "verification_finished_utc": "2026-09-17T04:46:29.6279984Z",
 177 |   "specification_source_check_passed": true,
 178 |   "original_specification_definitions_unchanged": 12,
 179 |   "certificate_bytes_unchanged": true
 180 | }
```

## `README_zh.md`

SHA-256: `efd89760c98214720ad2ea125466b009c2dbb930960c0876b27daafd44137f78`

### Lines 53–84

```text
  53 | ## Windows 复现
  54 | 
  55 | 工具已安装在项目 `.tools/`。从项目根目录执行：
  56 | 
  57 | ```powershell
  58 | . .\scripts\env.ps1
  59 | .\scripts\prepare_cache.ps1
  60 | .\scripts\clean_check.ps1
  61 | ```
  62 | 
  63 | `clean_check.ps1` 将本项目 `.lake/build` 安全移到项目内备份，保留依赖缓存，再执行 `check.ps1`。后者逐模块串行构建，然后实际执行完整 `lake build`、`lake env lean Audit.lean` 和严格 25 项公理检查。无需干净重建时可直接运行 `scripts/check.ps1`。
  64 | 
  65 | 环境与代理只设置在当前会话/子进程。编译低优先级、两核、Lean 单线程，缓存解包单任务，网络 I/O 最多 8 个并发且有超时。每次命令均保存原始输出、真实退出码与资源记录。编排脚本应直接运行，不要套在 `run_logged.py` 外层造成锁嵌套。
  66 | 
  67 | ```powershell
  68 | python scripts/build_serial.py Autocorrelation.Main
  69 | python scripts/build_serial.py --list
  70 | ```
  71 | 
  72 | Linux/macOS 历史入口是 `scripts/check.sh`，本轮没有在那些平台复测；资源监控运行器针对 Windows。
  73 | 
  74 | ## Python、生成器与依赖复核
  75 | 
  76 | ```powershell
  77 | python scripts/run_logged.py --label python-bernstein --timeout 120 --memory-estimate-mb 128 -- python original/verify.py certificate.json
  78 | python scripts/run_logged.py --label python-independent-sturm --timeout 300 --memory-estimate-mb 256 -- python original/independent_audit.py certificate.json
  79 | python scripts/run_logged.py --label python-generated-audit --timeout 300 --memory-estimate-mb 256 -- python scripts/audit_generated.py
  80 | python scripts/run_logged.py --label regeneration --timeout 300 --memory-estimate-mb 256 -- python scripts/verify_regeneration.py
  81 | python scripts/run_logged.py --label dependencies --timeout 120 --memory-estimate-mb 64 -- python scripts/verify_dependencies.py
  82 | ```
  83 | 
  84 | 生成器已与本轮修复同步。`verify_regeneration.py` 实际再次运行生成器，确认 `Autocorrelation/` 目录全部现存 Lean 源码与 `bernstein_leaves.json` 的散列不变；不要在编译过程中并行重跑生成器。`verify_dependencies.py` 检查实际 Git 提交、官方 mathlib 标签以及已记录的唯一补丁。这些检查辅助复现，不能替代 Lean 内核与公理审计。
```

## `scripts/generate.py`

SHA-256: `90efe25c77d2f56e46b195b37e9baa030e598b34cd46690be18b319f817d17a1`

### Lines 35–45

```text
  35 |         if coef == 0: continue
  36 |         terms.append(rat(coef) if k==0 else f'{rat(coef)} * {var} ^ {k}')
  37 |     return '(' + ' + '.join(terms) + ')' if terms else '(0 : ℝ)'
  38 | 
  39 | 
  40 | def write(name: str, text: str) -> None:
  41 |     p=ROOT/name
  42 |     p.parent.mkdir(parents=True,exist_ok=True)
  43 |     p.write_text(text.rstrip()+'\n',encoding='utf-8')
  44 | 
  45 | MODEL_IMPORTS='''import Mathlib.Analysis.Calculus.Deriv.Add
```

## `scripts/verify_regeneration.py`

SHA-256: `abed461b3c149ce92b1a579232707e1db159927b10c72975610bf225a5acbaac`

### Lines 1–26

```text
   1 | """Regenerate exact certificate artifacts and reject source drift.
   2 | 
   3 | Run before the clean Lean rebuild, never concurrently with a Lean build.
   4 | This is a reproducibility check, not a replacement for Lean verification.
   5 | """
   6 | import hashlib
   7 | import json
   8 | from pathlib import Path
   9 | import subprocess
  10 | import sys
  11 | 
  12 | ROOT = Path(__file__).resolve().parents[1]
  13 | paths = sorted((ROOT / 'Autocorrelation').rglob('*.lean')) + [ROOT / 'bernstein_leaves.json']
  14 | before = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
  15 | result = subprocess.run([sys.executable, str(ROOT / 'scripts/generate.py')], cwd=ROOT)
  16 | if result.returncode:
  17 |     sys.exit(result.returncode)
  18 | after = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
  19 | changed = [name for name in before if before[name] != after[name]]
  20 | report = {'scope': 'exact_generator_reproducibility_not_Lean_proof',
  21 |           'changed_artifacts': changed, 'source_sha256': after, 'passed': not changed}
  22 | (ROOT / 'logs/current-run/regeneration-check.json').write_text(
  23 |     json.dumps(report, indent=2) + '\n', encoding='utf-8')
  24 | if changed:
  25 |     sys.exit('FAIL: regeneration changed artifacts: ' + ', '.join(changed))
  26 | print('PASS: regeneration preserves every existing project Lean source and certificate leaf artifact.')
```

## `scripts/env.ps1`

SHA-256: `11272157fd72724be1554487f7dc734f1f124b019b5bbe5a3547db1c009762b2`

### Lines 1–23

```text
   1 | # Dot-source this file: . .\scripts\env.ps1
   2 | # These changes apply only to the current PowerShell session and its children.
   3 | $ProjectRoot = Split-Path -Parent $PSScriptRoot
   4 | $LeanBin = Join-Path $ProjectRoot '.tools\lean-4.19.0-windows\bin'
   5 | $PythonBin = Join-Path $ProjectRoot '.tools\venv\Scripts'
   6 | $env:PATH = "$LeanBin;$PythonBin;$env:PATH"
   7 | $env:LEAN_NUM_THREADS = '1'
   8 | $env:OMP_NUM_THREADS = '1'
   9 | $env:MAX_JOBS = '1'
  10 | $env:CMAKE_BUILD_PARALLEL_LEVEL = '1'
  11 | $env:PYTHONUTF8 = '1'
  12 | $env:PYTHONIOENCODING = 'utf-8'
  13 | $env:RAYON_NUM_THREADS = '1'
  14 | $env:MATHLIB_CACHE_DIR = Join-Path $ProjectRoot '.tools\mathlib-cache'
  15 | $env:CURL_HOME = Join-Path $ProjectRoot '.tools\curl-config'
  16 | $env:GIT_TERMINAL_PROMPT = '0'
  17 | $env:GIT_HTTP_LOW_SPEED_LIMIT = '1024'
  18 | $env:GIT_HTTP_LOW_SPEED_TIME = '30'
  19 | # Git HTTPS has no supported http.connectTimeout setting. run_logged.py enforces
  20 | # a whole-command timeout; SSH has its own supported connection timeout.
  21 | if (-not $env:GIT_SSH_COMMAND) {
  22 |     $env:GIT_SSH_COMMAND = 'ssh -o ConnectTimeout=20 -o ServerAliveInterval=15 -o ServerAliveCountMax=2 -o BatchMode=yes'
  23 | }
```

## `scripts/prepare_cache.ps1`

SHA-256: `c3b2903fae859a3cb58118adbfdf65d294513aa5017b98cb76bd06de9e0e9e64`

### Lines 1–16

```text
   1 | # Reproduce the bounded, project-local mathlib cache setup using installed tools.
   2 | # Run this script directly, not inside run_logged.py (each command takes its lock).
   3 | $ErrorActionPreference = 'Stop'
   4 | $ProjectRoot = Split-Path -Parent $PSScriptRoot
   5 | Set-Location -LiteralPath $ProjectRoot
   6 | . (Join-Path $PSScriptRoot 'env.ps1')
   7 | $Python = (Get-Command python -ErrorAction Stop).Source
   8 | 
   9 | function Invoke-CacheLogged {
  10 |     param(
  11 |         [Parameter(Mandatory = $true)][string]$Label,
  12 |         [Parameter(Mandatory = $true)][string[]]$Command,
  13 |         [int]$Timeout = 900,
  14 |         [int]$MemoryEstimateMb = 500
  15 |     )
  16 |     $RunnerArgs = @('scripts/run_logged.py', '--label', $Label,
```

### Lines 54–58

```text
  54 | $MathlibPath = Join-Path $ProjectRoot '.lake/packages/mathlib'
  55 | $CacheIO = Join-Path $MathlibPath 'Cache/IO.lean'
  56 | $PatchPath = Join-Path $ProjectRoot 'scripts/patches/mathlib-cache-single-worker.patch'
  57 | if (-not (Test-Path -LiteralPath $CacheIO)) { throw 'mathlib source is missing; run lake update first.' }
  58 | $SingleWorkerPattern = '#\["--jobs",\s*"1",\s*"-x",\s*"--delete-corrupted",\s*"-j",\s*"-"\]'
```

## `scripts/patches/mathlib-cache-single-worker.patch`

SHA-256: `214a7f144e820761ff62ba998852fba8b7e9d6eb2e1c101d30804f91640a542d`

### Lines 1–13

```text
   1 | diff --git a/Cache/IO.lean b/Cache/IO.lean
   2 | index 324c79e..bd3b6b2 100644
   3 | --- a/Cache/IO.lean
   4 | +++ b/Cache/IO.lean
   5 | @@ -369,7 +369,7 @@ def unpackCache (hashMap : ModuleHashMap) (force : Bool) : CacheM Unit := do
   6 |    if size > 0 then
   7 |      let now ← IO.monoMsNow
   8 |      IO.println s!"Decompressing {size} file(s)"
   9 | -    let args := (if force then #["-f"] else #[]) ++ #["-x", "--delete-corrupted", "-j", "-"]
  10 | +    let args := (if force then #["-f"] else #[]) ++ #["--jobs", "1", "-x", "--delete-corrupted", "-j", "-"]
  11 |      let child ← IO.Process.spawn { cmd := ← getLeanTar, args, stdin := .piped }
  12 |      let (stdin, child) ← child.takeStdin
  13 |      /-
```
