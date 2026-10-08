import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

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

def a : ℝ := ((626600210121 : ℝ) / 1000000000000)
def b : ℝ := ((40047498753 : ℝ) / 250000000000)
def gamma : ℝ := ((99999999 : ℝ) / 100000000)
def delta0 : ℝ := ((1 : ℝ) / 10000000000)
def w : ℝ := 1 - 2*b
def c : ℝ := 1-b

def cheb (z : ℝ) : ℕ → ℝ
  | 0 => 1
  | 1 => z
  | n+2 => 2*z*cheb z (n+1) - cheb z n

def paperP (x : ℝ) : ℝ := 2*x-x^2+x*(1-x)^2*(((-423577846263 : ℝ) / 1000000000000) * cheb (2*x-1) 0 +
    ((290387575223 : ℝ) / 1000000000000) * cheb (2*x-1) 1 +
    ((36766437 : ℝ) / 3125000000) * cheb (2*x-1) 2 +
    ((-5796017613 : ℝ) / 1000000000000) * cheb (2*x-1) 3 +
    ((50885811 : ℝ) / 250000000000) * cheb (2*x-1) 4 +
    ((83340881 : ℝ) / 125000000000) * cheb (2*x-1) 5 +
    ((120301079 : ℝ) / 500000000000) * cheb (2*x-1) 6 +
    ((28140971 : ℝ) / 250000000000) * cheb (2*x-1) 7)

def P (x : ℝ) : ℝ :=
  (((1303260710437 : ℝ) / 1000000000000) * x ^ 1 + ((398167103833 : ℝ) / 500000000000) * x ^ 2 + ((-1338637880051 : ℝ) / 1000000000000) * x ^ 3 + ((195266960359 : ℝ) / 250000000000) * x ^ 4 + ((-4297368247 : ℝ) / 1250000000) * x ^ 5 + ((262085157587 : ℝ) / 31250000000) * x ^ 6 + ((-11256207949 : ℝ) / 976562500) * x ^ 7 + ((4732570027 : ℝ) / 488281250) * x ^ 8 + ((-223580329 : ℝ) / 48828125) * x ^ 9 + ((225127768 : ℝ) / 244140625) * x ^ 10)

def DP (x : ℝ) : ℝ :=
  (((1303260710437 : ℝ) / 1000000000000) + ((398167103833 : ℝ) / 250000000000) * x ^ 1 + ((-4015913640153 : ℝ) / 1000000000000) * x ^ 2 + ((195266960359 : ℝ) / 62500000000) * x ^ 3 + ((-4297368247 : ℝ) / 250000000) * x ^ 4 + ((786255472761 : ℝ) / 15625000000) * x ^ 5 + ((-78793455643 : ℝ) / 976562500) * x ^ 6 + ((18930280108 : ℝ) / 244140625) * x ^ 7 + ((-2012222961 : ℝ) / 48828125) * x ^ 8 + ((450255536 : ℝ) / 48828125) * x ^ 9)

def I (x : ℝ) : ℝ :=
  (((1303260710437 : ℝ) / 2000000000000) * x ^ 2 + ((398167103833 : ℝ) / 1500000000000) * x ^ 3 + ((-1338637880051 : ℝ) / 4000000000000) * x ^ 4 + ((195266960359 : ℝ) / 1250000000000) * x ^ 5 + ((-4297368247 : ℝ) / 7500000000) * x ^ 6 + ((262085157587 : ℝ) / 218750000000) * x ^ 7 + ((-11256207949 : ℝ) / 7812500000) * x ^ 8 + ((4732570027 : ℝ) / 4394531250) * x ^ 9 + ((-223580329 : ℝ) / 488281250) * x ^ 10 + ((225127768 : ℝ) / 2685546875) * x ^ 11)

theorem P_matches_paper (x : ℝ) : P x = paperP x := by
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

end Autocorrelation
