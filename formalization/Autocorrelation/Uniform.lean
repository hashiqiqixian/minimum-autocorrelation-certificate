import Autocorrelation.Extension
import Autocorrelation.Mass
import Autocorrelation.Overlap

/-! The ordinary rectangle witness dominates the exact overlap certificate,
including both endpoints of the shift interval. -/
set_option autoImplicit false
noncomputable section
namespace Autocorrelation
open MeasureTheory

theorem integrable_density_product (t : ℝ) :
    Integrable (fun x => density x * density (x+t)) := by
  have h := (integrable_phi_product t).div_const (a^2)
  convert h using 1 <;> funext x <;> simp only [density] <;> ring

theorem integral_density_product (t : ℝ) :
    (∫ x : ℝ, density x * density (x+t)) = autocorrelation phi t / a^2 := by
  have heq : (fun x => density x * density (x+t)) =
      (fun x => (phi x * phi (x+t)) / a^2) := by
    funext x
    simp only [density]
    ring
  rw [heq, integral_div]
  rfl

theorem witness_product_dominates (delta t x : ℝ) (hd : 0 < delta)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) * density t +
      density x * density (x+t) ≤ witness delta x * witness delta (x+t) := by
  have hr (y : ℝ) : 0 ≤ (if 0 ≤ y ∧ y ≤ delta then a/delta else 0) := by
    split_ifs
    · exact div_nonneg a_pos.le hd.le
    · exact le_rfl
  apply autocorrelation_product_lower _ _ _ _ _ _ _ (hr x) (hr (x+t))
    (density_nonneg x) (density_nonneg (x+t))
    (density_le_extendedDensity delta x) (density_le_extendedDensity delta (x+t))
  by_cases hx : 0 ≤ x ∧ x ≤ delta
  · simp only [if_pos hx]
    apply mul_le_mul_of_nonneg_left _ (div_nonneg a_pos.le hd.le)
    have h := monotone_extension_comparison delta t x (extendedDensity delta)
      hd ht0 ht1 hx.1 hx.2 (extendedDensity_monotoneOn delta)
    have heq : extendedDensity delta t = density t := by
      simp only [extendedDensity, if_pos (show 0 ≤ t ∧ t ≤ 1 from ⟨ht0, ht1⟩)]
    rwa [heq] at h
  · simp only [if_neg hx, zero_mul, le_refl]

theorem uniform_correlation : UniformCorrelationClaim := by
  intro delta hd t ht0 ht1
  have hi : Integrable (fun x : ℝ =>
      (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) * density t +
        density x * density (x+t)) :=
    ((integrable_rectangle delta).mul_const (density t)).add (integrable_density_product t)
  have hbound := integral_mono hi (integrable_witness_product delta hd t)
    (fun x => witness_product_dominates delta t x hd ht0 ht1)
  have ha : a * density t = phi t := by
    unfold density
    field_simp [ne_of_gt a_pos]
  rw [integral_add ((integrable_rectangle delta).mul_const (density t))
    (integrable_density_product t), integral_mul_const, rectangle_integral delta hd,
    ha, integral_density_product, overlap_integral t ht0 ht1] at hbound
  exact (algebraicCorrelation_lower t ht0 ht1).trans hbound

end Autocorrelation
