import Autocorrelation.Uniform
import Autocorrelation.Mass

/-! The explicit function theorem and the approximation theorem use the
same ordinary, integrable witness as the mass and correlation proofs. -/
set_option autoImplicit false
set_option maxHeartbeats 0
noncomputable section
namespace Autocorrelation
open MeasureTheory

theorem witness_ratio_theorem (delta q : ℝ) (hdelta : 0 < delta)
    (hq : q ≤ gamma / (mass+delta/a)^2) :
    Integrable (witness delta) ∧
    Integrable (fun x => (witness delta x)^2) ∧
    (∀ x : ℝ, 0 ≤ witness delta x) ∧
    0 < (∫ x : ℝ, witness delta x) ∧
    (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      Integrable (fun x => witness delta x*witness delta (x+t)) ∧
      q ≤ autocorrelation (witness delta) t / (∫ x : ℝ, witness delta x)^2) := by
  rcases witness_admissibility delta hdelta with ⟨hi, hs, hn, hc⟩
  refine ⟨hi, hs, hn, ?_, ?_⟩
  · rw [mass_integral delta hdelta]
    exact add_pos mass_pos (div_pos hdelta a_pos)
  · intro t ht0 ht1
    refine ⟨hc t, hq.trans ?_⟩
    rw [mass_integral delta hdelta]
    exact div_le_div_of_nonneg_right
      (uniform_correlation delta hdelta t ht0 ht1) (sq_nonneg _)

theorem explicit_main : ExplicitMainClaim := by
  have hdelta : 0 < delta0 := by norm_num [delta0]
  exact witness_ratio_theorem delta0 explicitRatio hdelta explicit_ratio_identity.symm.le

theorem limiting_main : LimitingMainClaim := by
  intro q hq
  by_cases hq0 : q ≤ 0
  · have hdelta : 0 < delta0 := by norm_num [delta0]
    refine ⟨witness delta0, witness_ratio_theorem delta0 q hdelta ?_⟩
    exact hq0.trans (div_nonneg gamma_pos.le (sq_nonneg _))
  · have hqpos : 0 < q := lt_of_not_ge hq0
    have hqgamma : q * mass^2 < gamma := by
      apply (lt_div_iff₀ (sq_pos_of_pos mass_pos)).mp
      rw [limiting_ratio_identity]
      exact hq
    let e : ℝ := gamma-q*mass^2
    have he : 0 < e := sub_pos.mpr hqgamma
    have hden : 0 < 2*q*(2*mass+1) :=
      mul_pos (mul_pos (by norm_num) hqpos) (by linarith [mass_pos])
    let r : ℝ := min 1 (e/(2*q*(2*mass+1)))
    have hrpos : 0 < r := lt_min zero_lt_one (div_pos he hden)
    have hrone : r ≤ 1 := min_le_left _ _
    have hrsmall : r ≤ e/(2*q*(2*mass+1)) := min_le_right _ _
    have hrproduct : r*(2*q*(2*mass+1)) ≤ e := (le_div_iff₀ hden).mp hrsmall
    have hrsq : r^2 ≤ r := by
      simpa only [pow_two, mul_one] using
        (mul_le_mul_of_nonneg_left hrone hrpos.le)
    have herror : q*r^2 ≤ q*r := mul_le_mul_of_nonneg_left hrsq hqpos.le
    have hstep : q*(mass+r)^2 ≤ q*mass^2 + q*(2*mass+1)*r := by
      nlinarith only [herror]
    have hsmall : q*(2*mass+1)*r ≤ e/2 := by
      apply (le_div_iff₀ (by norm_num : (0 : ℝ) < 2)).mpr
      calc
        q*(2*mass+1)*r*2 = r*(2*q*(2*mass+1)) := by ring
        _ ≤ e := hrproduct
    have hstrict : q*(mass+r)^2 < gamma := by
      dsimp only [e] at he hsmall
      nlinarith only [hstep, hsmall, he]
    refine ⟨witness (a*r), witness_ratio_theorem (a*r) q (mul_pos a_pos hrpos) ?_⟩
    rw [mul_div_cancel_left₀ r (ne_of_gt a_pos)]
    exact ((lt_div_iff₀ (sq_pos_of_pos (add_pos mass_pos hrpos))).mpr hstrict).le

end Autocorrelation
