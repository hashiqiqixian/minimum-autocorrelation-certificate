import Autocorrelation.Witness
import Autocorrelation.ElementaryAnalysis
import Autocorrelation.Targets

/-! Lebesgue mass of the ordinary function witness. All uses of integral
linearity below include proofs of integrability of both summands. -/
set_option autoImplicit false
set_option maxHeartbeats 0
noncomputable section
namespace Autocorrelation
open MeasureTheory

theorem phi_eq_two_indicators :
    phi = fun x =>
      (Set.Icc b c).indicator (fun y : ℝ => P ((y-b)/w)) x +
      (Set.Ioc c 1).indicator (fun _ : ℝ => (1 : ℝ)) x := by
  funext x
  have hbc : b < c := breakpoint_order.2.1.trans breakpoint_order.2.2.1
  by_cases hxb : x < b
  · have hnb : ¬ b ≤ x := not_le.mpr hxb
    have hnc : ¬ c < x := not_lt.mpr (hxb.le.trans hbc.le)
    simp [phi, hxb, Set.indicator, Set.mem_Icc, Set.mem_Ioc, hnb, hnc]
  · have hbx : b ≤ x := le_of_not_gt hxb
    by_cases hxc : x ≤ c
    · have hnc : ¬ c < x := not_lt.mpr hxc
      simp [phi, hxb, hxc, Set.indicator, Set.mem_Icc, Set.mem_Ioc, hbx, hnc]
    · have hcx : c < x := lt_of_not_ge hxc
      by_cases hx1 : x ≤ 1
      · simp [phi, hxb, hxc, hx1, Set.indicator, Set.mem_Icc, Set.mem_Ioc, hbx, hcx]
      · simp [phi, hxb, hxc, hx1, Set.indicator, Set.mem_Icc, Set.mem_Ioc, hbx, hcx]

theorem integral_phi_ramp :
    (∫ x in b..c, P ((x-b)/w)) = w * I 1 := by
  have hcb : (c-b)/w = 1 := by norm_num [c, b, w]
  rw [intervalIntegral.integral_comp_sub_right (fun x : ℝ => P (x/w)) b]
  rw [intervalIntegral.integral_comp_div P (ne_of_gt w_pos)]
  simp only [sub_self, zero_div, hcb, integral_P, I_zero, sub_zero, smul_eq_mul]

theorem integral_phi : (∫ x : ℝ, phi x) = w * I 1 + b := by
  have hp : Integrable ((Set.Icc b c).indicator (fun x : ℝ => P ((x-b)/w))) :=
    ((continuous_P.comp ((continuous_id.sub continuous_const).div_const w)).integrableOn_Icc).integrable_indicator
      measurableSet_Icc
  have hc : Integrable ((Set.Ioc c 1).indicator (fun _ : ℝ => (1 : ℝ))) :=
    ((continuous_const : Continuous (fun _ : ℝ => (1 : ℝ))).integrableOn_Ioc).integrable_indicator
      measurableSet_Ioc
  have hbc : b ≤ c := (breakpoint_order.2.1.trans breakpoint_order.2.2.1).le
  rw [phi_eq_two_indicators, integral_add hp hc,
    integral_indicator measurableSet_Icc, integral_Icc_eq_integral_Ioc,
    ← intervalIntegral.integral_of_le hbc, integral_phi_ramp,
    integral_indicator_const 1 measurableSet_Ioc,
    Real.volume_real_Ioc_of_le breakpoint_order.2.2.2.le]
  simp only [smul_eq_mul, mul_one]
  unfold c
  ring

theorem integrable_rectangle (delta : ℝ) :
    Integrable (fun x : ℝ => if 0 ≤ x ∧ x ≤ delta then a/delta else 0) := by
  have h : Integrable ((Set.Icc (0 : ℝ) delta).indicator (fun _ : ℝ => a/delta)) :=
    ((continuous_const : Continuous (fun _ : ℝ => a/delta)).integrableOn_Icc).integrable_indicator
      measurableSet_Icc
  have heq : (fun x : ℝ => if 0 ≤ x ∧ x ≤ delta then a/delta else 0) =
      (Set.Icc (0 : ℝ) delta).indicator (fun _ : ℝ => a/delta) := by
    funext x
    simp only [Set.indicator_apply, Set.mem_Icc]
  rw [heq]
  exact h

theorem rectangle_integral (delta : ℝ) (hdelta : 0 < delta) :
    (∫ x : ℝ, if 0 ≤ x ∧ x ≤ delta then a/delta else 0) = a := by
  have h := integral_indicator_const (μ := volume) (a/delta)
    (s := Set.Icc (0 : ℝ) delta) measurableSet_Icc
  rw [Real.volume_real_Icc_of_le hdelta.le] at h
  simp only [Set.indicator, Set.mem_Icc, sub_zero, smul_eq_mul] at h
  rw [h]
  field_simp [ne_of_gt hdelta] <;> ring

theorem extendedDensity_eq_density_add_tail (delta : ℝ) :
    extendedDensity delta = fun x => density x +
      (Set.Ioc (1 : ℝ) (1+delta)).indicator (fun _ : ℝ => 1/a) x := by
  funext x
  by_cases hx : 0 ≤ x ∧ x ≤ 1
  · have hnx : ¬ 1 < x := not_lt.mpr hx.2
    simp [extendedDensity, hx, Set.indicator, Set.mem_Ioc, hnx]
  · have hz : density x = 0 := by
      simp only [density, phi_eq_zero_of_not_mem x hx, zero_div]
    simp [extendedDensity, hx, hz, Set.indicator, Set.mem_Ioc]

theorem integral_extendedDensity (delta : ℝ) (hdelta : 0 < delta) :
    (∫ x : ℝ, extendedDensity delta x) = (w*I 1+b)/a + delta/a := by
  have hdensity : Integrable density := integrable_phi.div_const a
  have htail : Integrable
      ((Set.Ioc (1 : ℝ) (1+delta)).indicator (fun _ : ℝ => 1/a)) :=
    ((continuous_const : Continuous (fun _ : ℝ => 1/a)).integrableOn_Ioc).integrable_indicator
      measurableSet_Ioc
  have hmass : (∫ x : ℝ, density x) = (w*I 1+b)/a := by
    unfold density
    rw [integral_div, integral_phi]
  rw [extendedDensity_eq_density_add_tail, integral_add hdensity htail, hmass,
    integral_indicator_const (1/a) measurableSet_Ioc,
    Real.volume_real_Ioc_of_le (by linarith : (1 : ℝ) ≤ 1+delta)]
  simp only [smul_eq_mul]
  ring

theorem mass_integral : MassIntegralClaim := by
  intro delta hdelta
  change (∫ x : ℝ,
    (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) + extendedDensity delta x) = _
  rw [integral_add (integrable_rectangle delta) (integrable_extendedDensity delta hdelta),
    rectangle_integral delta hdelta, integral_extendedDensity delta hdelta]
  unfold mass
  ring

end Autocorrelation
