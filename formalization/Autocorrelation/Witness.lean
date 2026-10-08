import Autocorrelation.Targets
import Autocorrelation.ElementaryAnalysis
import Mathlib.MeasureTheory.Integral.IntegrableOn

/-! Ordinary function witnesses: pointwise bounds and actual Lebesgue integrability. -/
set_option autoImplicit false
noncomputable section
namespace Autocorrelation
open MeasureTheory

theorem phi_bounds (x : ℝ) : 0 ≤ phi x ∧ phi x ≤ 1 := by
  unfold phi
  split_ifs with hxb hxc hx1
  · exact ⟨le_rfl, zero_le_one⟩
  · apply P_bounds
    · exact div_nonneg (sub_nonneg.mpr (le_of_not_gt hxb)) w_pos.le
    · apply (div_le_one w_pos).2
      dsimp [c, w] at hxc ⊢
      linarith
  · exact ⟨zero_le_one, le_rfl⟩
  · exact ⟨le_rfl, zero_le_one⟩

theorem phi_nonneg (x : ℝ) : 0 ≤ phi x := (phi_bounds x).1

theorem phi_le_one (x : ℝ) : phi x ≤ 1 := (phi_bounds x).2

theorem measurable_phi : Measurable phi := by
  unfold phi
  exact Measurable.ite measurableSet_Iio measurable_const
    (Measurable.ite measurableSet_Iic
      (continuous_P.measurable.comp ((measurable_id.sub_const b).div_const w))
      (Measurable.ite measurableSet_Iic measurable_const measurable_const))

theorem phi_eq_zero_of_not_mem (x : ℝ) (hx : x ∉ Set.Icc (0 : ℝ) 1) :
    phi x = 0 := by
  have hb := breakpoint_order.1
  have hc := breakpoint_order.2.2.2
  unfold phi
  split_ifs with hxb hxc hx1
  · rfl
  · exact False.elim (hx ⟨by linarith, by linarith⟩)
  · exact False.elim (hx ⟨by linarith, hx1⟩)
  · rfl

theorem density_nonneg (x : ℝ) : 0 ≤ density x :=
  div_nonneg (phi_nonneg x) a_pos.le

theorem density_le (x : ℝ) : density x ≤ 1 / a :=
  div_le_div_of_nonneg_right (phi_le_one x) a_pos.le

theorem measurable_density : Measurable density := measurable_phi.div_const a

theorem extendedDensity_nonneg (delta x : ℝ) : 0 ≤ extendedDensity delta x := by
  unfold extendedDensity
  split_ifs
  · exact density_nonneg x
  · exact div_nonneg zero_le_one a_pos.le
  · exact le_rfl

theorem extendedDensity_le (delta x : ℝ) : extendedDensity delta x ≤ 1 / a := by
  unfold extendedDensity
  split_ifs
  · exact density_le x
  · exact le_rfl
  · exact div_nonneg zero_le_one a_pos.le

theorem measurable_extendedDensity (delta : ℝ) : Measurable (extendedDensity delta) := by
  unfold extendedDensity
  exact Measurable.ite measurableSet_Icc measurable_density
    (Measurable.ite measurableSet_Ioc measurable_const measurable_const)

theorem extendedDensity_eq_zero_of_not_mem (delta : ℝ) (hdelta : 0 < delta)
    (x : ℝ) (hx : x ∉ Set.Icc (0 : ℝ) (1 + delta)) :
    extendedDensity delta x = 0 := by
  unfold extendedDensity
  split_ifs with hmain hext
  · exact False.elim (hx ⟨hmain.1, by linarith [hmain.2]⟩)
  · exact False.elim (hx ⟨by linarith [hext.1], hext.2⟩)
  · rfl

theorem witness_nonneg (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
    0 ≤ witness delta x := by
  unfold witness
  apply add_nonneg _ (extendedDensity_nonneg delta x)
  split_ifs
  · exact div_nonneg a_pos.le hdelta.le
  · exact le_rfl

theorem witness_le (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
    witness delta x ≤ a / delta + 1 / a := by
  unfold witness
  apply add_le_add _ (extendedDensity_le delta x)
  split_ifs
  · exact le_rfl
  · exact div_nonneg a_pos.le hdelta.le

theorem measurable_witness (delta : ℝ) : Measurable (witness delta) := by
  unfold witness
  exact (Measurable.ite measurableSet_Icc measurable_const measurable_const).add
    (measurable_extendedDensity delta)

theorem witness_eq_zero_of_not_mem (delta : ℝ) (hdelta : 0 < delta)
    (x : ℝ) (hx : x ∉ Set.Icc (0 : ℝ) (1 + delta)) : witness delta x = 0 := by
  have hatom : ¬(0 ≤ x ∧ x ≤ delta) := by
    intro h
    exact hx ⟨h.1, by linarith [h.2]⟩
  simp only [witness, if_neg hatom, zero_add]
  exact extendedDensity_eq_zero_of_not_mem delta hdelta x hx

theorem integrable_of_bounded_supported_Icc (f : ℝ → ℝ) (l r M : ℝ)
    (hm : Measurable f) (hb : ∀ x : ℝ, ‖f x‖ ≤ M)
    (hz : ∀ x : ℝ, x ∉ Set.Icc l r → f x = 0) : Integrable f := by
  have hi : IntegrableOn f (Set.Icc l r) :=
    Measure.integrableOn_of_bounded measure_Icc_lt_top.ne hm.aestronglyMeasurable
      (Filter.Eventually.of_forall hb)
  exact hi.integrable_of_forall_not_mem_eq_zero hz

theorem norm_phi_le (x : ℝ) : ‖phi x‖ ≤ 1 := by
  rw [Real.norm_eq_abs, abs_of_nonneg (phi_nonneg x)]
  exact phi_le_one x

theorem integrable_phi : Integrable phi := by
  exact integrable_of_bounded_supported_Icc phi 0 1 1 measurable_phi norm_phi_le
    phi_eq_zero_of_not_mem

theorem integrable_phi_product (t : ℝ) : Integrable (fun x => phi x * phi (x + t)) := by
  have hm : Measurable (fun x : ℝ => phi (x + t)) :=
    measurable_phi.comp (measurable_id.add_const t)
  have hi := integrable_phi.bdd_mul' hm.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun x : ℝ => norm_phi_le (x + t)))
  simpa only [mul_comm] using hi

theorem norm_extendedDensity_le (delta x : ℝ) : ‖extendedDensity delta x‖ ≤ 1 / a := by
  rw [Real.norm_eq_abs, abs_of_nonneg (extendedDensity_nonneg delta x)]
  exact extendedDensity_le delta x

theorem integrable_extendedDensity (delta : ℝ) (hdelta : 0 < delta) :
    Integrable (extendedDensity delta) := by
  exact integrable_of_bounded_supported_Icc (extendedDensity delta) 0 (1 + delta) (1 / a)
    (measurable_extendedDensity delta) (norm_extendedDensity_le delta)
    (extendedDensity_eq_zero_of_not_mem delta hdelta)

theorem norm_witness_le (delta : ℝ) (hdelta : 0 < delta) (x : ℝ) :
    ‖witness delta x‖ ≤ a / delta + 1 / a := by
  rw [Real.norm_eq_abs, abs_of_nonneg (witness_nonneg delta hdelta x)]
  exact witness_le delta hdelta x

theorem integrable_witness (delta : ℝ) (hdelta : 0 < delta) : Integrable (witness delta) := by
  exact integrable_of_bounded_supported_Icc (witness delta) 0 (1 + delta)
    (a / delta + 1 / a) (measurable_witness delta) (norm_witness_le delta hdelta)
    (witness_eq_zero_of_not_mem delta hdelta)

theorem integrable_witness_square (delta : ℝ) (hdelta : 0 < delta) :
    Integrable (fun x => (witness delta x) ^ 2) := by
  have hi := (integrable_witness delta hdelta).bdd_mul'
    (measurable_witness delta).aestronglyMeasurable
    (Filter.Eventually.of_forall (norm_witness_le delta hdelta))
  simpa only [pow_two] using hi

theorem integrable_witness_product (delta : ℝ) (hdelta : 0 < delta) (t : ℝ) :
    Integrable (fun x => witness delta x * witness delta (x + t)) := by
  have hm : Measurable (fun x : ℝ => witness delta (x + t)) :=
    (measurable_witness delta).comp (measurable_id.add_const t)
  have hi := (integrable_witness delta hdelta).bdd_mul' hm.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun x : ℝ => norm_witness_le delta hdelta (x + t)))
  simpa only [mul_comm] using hi

theorem witness_admissibility : WitnessAdmissibilityClaim := by
  intro delta hdelta
  exact ⟨integrable_witness delta hdelta, integrable_witness_square delta hdelta,
    witness_nonneg delta hdelta, integrable_witness_product delta hdelta⟩

end Autocorrelation
