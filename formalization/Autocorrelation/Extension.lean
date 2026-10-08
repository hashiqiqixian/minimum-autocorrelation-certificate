import Autocorrelation.Witness
import Autocorrelation.AtomRemovalAlgebra

set_option autoImplicit false
noncomputable section
namespace Autocorrelation

theorem ramp_argument_mem (x : ℝ) (hx : b ≤ x) (hxc : x ≤ c) :
    (x - b) / w ∈ Set.Icc (0 : ℝ) 1 := by
  constructor
  · exact div_nonneg (sub_nonneg.mpr hx) w_pos.le
  · apply (div_le_one w_pos).2
    dsimp [c, w] at *
    linarith

theorem phi_monotoneOn : MonotoneOn phi (Set.Icc 0 1) := by
  intro x hx y hy hxy
  by_cases hxb : x < b
  · simpa [phi, hxb] using phi_nonneg y
  have hyb : ¬ y < b := by linarith
  by_cases hxc : x ≤ c
  · by_cases hyc : y ≤ c
    · simp only [phi, if_neg hxb, if_pos hxc, if_neg hyb, if_pos hyc]
      exact P_monotoneOn (ramp_argument_mem x (le_of_not_gt hxb) hxc)
        (ramp_argument_mem y (le_of_not_gt hyb) hyc)
        (div_le_div_of_nonneg_right (sub_le_sub_right hxy b) w_pos.le)
    · have hp := (P_bounds ((x-b)/w)
        (ramp_argument_mem x (le_of_not_gt hxb) hxc).1
        (ramp_argument_mem x (le_of_not_gt hxb) hxc).2).2
      simpa [phi, hxb, hxc, hyb, hyc, hy.2] using hp
  · have hyc : ¬ y ≤ c := by linarith
    simp [phi, hxb, hxc, hyb, hyc, hx.2, hy.2]

theorem density_eq_zero_outside (x : ℝ) (hx : ¬ (0 ≤ x ∧ x ≤ 1)) :
    density x = 0 := by
  by_cases hx0 : 0 ≤ x
  · have hx1 : ¬ x ≤ 1 := by tauto
    have hxb : ¬ x < b := by have := breakpoint_order; linarith
    have hxc : ¬ x ≤ c := by have := breakpoint_order; linarith
    simp [density, phi, hxb, hxc, hx1]
  · have hxb : x < b := by have := breakpoint_order.1; linarith
    simp [density, phi, hxb]

theorem density_le_extendedDensity (delta x : ℝ) :
    density x ≤ extendedDensity delta x := by
  by_cases hx : 0 ≤ x ∧ x ≤ 1
  · simp [extendedDensity, hx]
  · rw [density_eq_zero_outside x hx]
    exact extendedDensity_nonneg delta x

theorem extendedDensity_monotoneOn (delta : ℝ) :
    MonotoneOn (extendedDensity delta) (Set.Icc 0 (1 + delta)) := by
  intro x hx y hy hxy
  by_cases hx1 : x ≤ 1
  · by_cases hy1 : y ≤ 1
    · simp only [extendedDensity, if_pos (show 0 ≤ x ∧ x ≤ 1 from ⟨hx.1, hx1⟩),
        if_pos (show 0 ≤ y ∧ y ≤ 1 from ⟨hy.1, hy1⟩), density]
      exact div_le_div_of_nonneg_right (phi_monotoneOn ⟨hx.1, hx1⟩ ⟨hy.1, hy1⟩ hxy) a_pos.le
    · have hy01 : ¬ (0 ≤ y ∧ y ≤ 1) := by tauto
      simp only [extendedDensity, if_pos (show 0 ≤ x ∧ x ≤ 1 from ⟨hx.1, hx1⟩), if_neg hy01,
        if_pos (show 1 < y ∧ y ≤ 1+delta from ⟨lt_of_not_ge hy1, hy.2⟩), density]
      exact div_le_div_of_nonneg_right (phi_le_one x) a_pos.le
  · have hy1 : ¬ y ≤ 1 := by linarith
    have hx01 : ¬ (0 ≤ x ∧ x ≤ 1) := by tauto
    have hy01 : ¬ (0 ≤ y ∧ y ≤ 1) := by tauto
    simp [extendedDensity, hx01, hy01, lt_of_not_ge hx1, lt_of_not_ge hy1, hx.2, hy.2]

theorem algebraicCorrelation_lower (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    gamma ≤ algebraicCorrelation t := by
  unfold algebraicCorrelation
  split_ifs with hb hw hc
  · exact g0_lower t ht0 hb
  · exact g1_lower t (le_of_lt (lt_of_not_ge hb)) hw
  · exact g2_lower t (le_of_lt (lt_of_not_ge hw)) hc
  · exact g3_lower t (le_of_lt (lt_of_not_ge hc)) ht1

end Autocorrelation
