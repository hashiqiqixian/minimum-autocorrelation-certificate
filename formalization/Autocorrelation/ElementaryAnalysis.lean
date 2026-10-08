import Autocorrelation.FiniteCertificate
import Autocorrelation.Derivatives
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus

/-! Uncompiled proof candidates for the elementary analytical consequences.
These statements do not establish the full piecewise autocorrelation integral. -/
set_option autoImplicit false
set_option maxHeartbeats 0
noncomputable section
namespace Autocorrelation

open MeasureTheory

theorem continuous_P : Continuous P := by
  exact continuous_iff_continuousAt.mpr (fun x => (hasDerivAt_P x).continuousAt)

theorem P_monotoneOn : MonotoneOn P (Set.Icc 0 1) := by
  apply monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc 0 1)
    continuous_P.continuousOn
    (fun x _ => (hasDerivAt_P x).hasDerivWithinAt)
  intro x hx
  have hx' : x ∈ Set.Icc (0 : ℝ) 1 := interior_subset hx
  exact DP_nonnegative_on_interval x hx'.1 hx'.2

theorem P_bounds (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ P x ∧ P x ≤ 1 := by
  have h0 := P_monotoneOn (show (0 : ℝ) ∈ Set.Icc 0 1 by norm_num)
    ⟨hx0, hx1⟩ hx0
  have h1 := P_monotoneOn ⟨hx0, hx1⟩
    (show (1 : ℝ) ∈ Set.Icc 0 1 by norm_num) hx1
  simpa only [P_zero, P_one] using And.intro h0 h1

theorem integral_P (l r : ℝ) : (∫ x in l..r, P x) = I r-I l := by
  exact intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun x _ => hasDerivAt_I x) (continuous_P.intervalIntegrable l r)

theorem integral_PP (l r v : ℝ) :
    (∫ x in l..r, P x * P (x+v)) = RR r v-RR l v := by
  have hcont : Continuous (fun x : ℝ => P x * P (x+v)) :=
    continuous_P.mul (continuous_P.comp (continuous_id.add continuous_const))
  exact intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun x _ => hasDerivAt_RR x v) (hcont.intervalIntegrable l r)

theorem g0_g1_match : g0 b = g1 b := by
  rw [g0_expansion, g1_expansion]
  norm_num [G0, G1, b]

theorem g1_g2_match : g1 w = g2 w := by
  rw [g1_expansion, g2_expansion]
  norm_num [G1, G2, w, b]

theorem g2_g3_match : g2 c = g3 c := by
  rw [g2_expansion, g3_expansion]
  norm_num [G2, G3, c, b]

end Autocorrelation
