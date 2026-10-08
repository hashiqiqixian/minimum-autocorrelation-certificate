import Mathlib.Data.Real.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic.Linarith

/-! Generic pointwise inequalities, instantiated for the ordinary witness
in Extension.lean and Uniform.lean. -/
set_option autoImplicit false
noncomputable section
namespace Autocorrelation

/-- Unlike the original open-interval argument, this elementary inequality
includes t=0 and t=1. No L² continuity theorem is needed for this step. -/
theorem shift_stays_in_extension (delta t x : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hx0 : 0 ≤ x) (hxd : x ≤ delta) :
    0 ≤ x+t ∧ x+t ≤ 1+delta ∧ t ≤ x+t := by
  constructor
  · linarith
  constructor <;> linarith

theorem monotone_extension_comparison (delta t x : ℝ) (H : ℝ → ℝ)
    (hd : 0 < delta) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hx0 : 0 ≤ x) (hxd : x ≤ delta)
    (hmono : MonotoneOn H (Set.Icc 0 (1+delta))) :
    H t ≤ H (x+t) := by
  have hb := shift_stays_in_extension delta t x ht0 ht1 hx0 hxd
  exact hmono ⟨ht0, by linarith⟩ ⟨hb.1, hb.2.1⟩ hb.2.2

/-- Pointwise algebra for the autocorrelation expansion. In an eventual
application r0,r1 are rectangle values; u0,u1 are original density values;
v0,v1 are extended density values. The cross-term bound is explicit. -/
theorem autocorrelation_product_lower
    (r0 r1 u0 u1 v0 v1 q : ℝ)
    (hr0 : 0 ≤ r0) (hr1 : 0 ≤ r1)
    (hu0 : 0 ≤ u0) (hu1 : 0 ≤ u1)
    (h0 : u0 ≤ v0) (h1 : u1 ≤ v1)
    (hcross : r0*q ≤ r0*v1) :
    r0*q + u0*u1 ≤ (r0+v0)*(r1+v1) := by
  have hv0 : 0 ≤ v0 := le_trans hu0 h0
  have hproduct : u0*u1 ≤ v0*v1 := mul_le_mul h0 h1 hu1 hv0
  have hn0 : 0 ≤ r0*r1 := mul_nonneg hr0 hr1
  have hn1 : 0 ≤ v0*r1 := mul_nonneg hv0 hr1
  nlinarith

end Autocorrelation
