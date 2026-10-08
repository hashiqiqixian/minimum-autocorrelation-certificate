import Autocorrelation.Leaves.DP_00
import Autocorrelation.Leaves.G0_00
import Autocorrelation.Leaves.G1_00
import Autocorrelation.Leaves.G1_01
import Autocorrelation.Leaves.G1_02
import Autocorrelation.Leaves.G1_03
import Autocorrelation.Leaves.G1_04
import Autocorrelation.Leaves.G1_05
import Autocorrelation.Leaves.G1_06
import Autocorrelation.Leaves.G1_07
import Autocorrelation.Leaves.G1_08
import Autocorrelation.Leaves.G1_09
import Autocorrelation.Leaves.G1_10
import Autocorrelation.Leaves.G1_11
import Autocorrelation.Leaves.G1_12
import Autocorrelation.Leaves.G2_00
import Autocorrelation.Leaves.G2_01
import Autocorrelation.Leaves.G2_02
import Autocorrelation.Leaves.G2_03
import Autocorrelation.Leaves.G3_00

set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

theorem DP_nonnegative_on_interval (t : ℝ)
    (hlo : (0 : ℝ) ≤ t) (hhi : t ≤ (1 : ℝ)) : 0 ≤ DP t := by
  exact DP_00_nonneg t hlo hhi

theorem G0_nonnegative_on_interval (t : ℝ)
    (hlo : (0 : ℝ) ≤ t) (hhi : t ≤ ((40047498753 : ℝ) / 250000000000)) : gamma ≤ G0 t := by
  apply sub_nonneg.mp
  exact G0_00_nonneg t hlo hhi

theorem G1_nonnegative_on_interval (t : ℝ)
    (hlo : ((40047498753 : ℝ) / 250000000000) ≤ t) (hhi : t ≤ ((84952501247 : ℝ) / 125000000000)) : gamma ≤ G1 t := by
  apply sub_nonneg.mp
  by_cases h0 : t ≤ ((770617483789 : ℝ) / 4000000000000)
  · exact G1_00_nonneg t hlo h0
  by_cases h1 : t ≤ ((3212327438897 : ℝ) / 16000000000000)
  · exact G1_01_nonneg t (le_of_lt (lt_of_not_ge h0)) h1
  by_cases h2 : t ≤ ((1671092471319 : ℝ) / 8000000000000)
  · exact G1_02_nonneg t (le_of_lt (lt_of_not_ge h1)) h2
  by_cases h3 : t ≤ ((90047498753 : ℝ) / 400000000000)
  · exact G1_03_nonneg t (le_of_lt (lt_of_not_ge h2)) h3
  by_cases h4 : t ≤ ((290047498753 : ℝ) / 1000000000000)
  · exact G1_04_nonneg t (le_of_lt (lt_of_not_ge h3)) h4
  by_cases h5 : t ≤ ((1290047498753 : ℝ) / 4000000000000)
  · exact G1_05_nonneg t (le_of_lt (lt_of_not_ge h4)) h5
  by_cases h6 : t ≤ ((709952501247 : ℝ) / 2000000000000)
  · exact G1_06_nonneg t (le_of_lt (lt_of_not_ge h5)) h6
  by_cases h7 : t ≤ ((209952501247 : ℝ) / 500000000000)
  · exact G1_07_nonneg t (le_of_lt (lt_of_not_ge h6)) h7
  by_cases h8 : t ≤ ((969667508729 : ℝ) / 2000000000000)
  · exact G1_08_nonneg t (le_of_lt (lt_of_not_ge h7)) h8
  by_cases h9 : t ≤ ((109952501247 : ℝ) / 200000000000)
  · exact G1_09_nonneg t (le_of_lt (lt_of_not_ge h8)) h9
  by_cases h10 : t ≤ ((1229382516211 : ℝ) / 2000000000000)
  · exact G1_10_nonneg t (le_of_lt (lt_of_not_ge h9)) h10
  by_cases h11 : t ≤ ((2588622536163 : ℝ) / 4000000000000)
  · exact G1_11_nonneg t (le_of_lt (lt_of_not_ge h10)) h11
  exact G1_12_nonneg t (le_of_lt (lt_of_not_ge h11)) hhi

theorem G2_nonnegative_on_interval (t : ℝ)
    (hlo : ((84952501247 : ℝ) / 125000000000) ≤ t) (hhi : t ≤ ((209952501247 : ℝ) / 250000000000)) : gamma ≤ G2 t := by
  apply sub_nonneg.mp
  by_cases h0 : t ≤ ((379857503741 : ℝ) / 500000000000)
  · exact G2_00_nonneg t hlo h0
  by_cases h1 : t ≤ ((1559477513717 : ℝ) / 2000000000000)
  · exact G2_01_nonneg t (le_of_lt (lt_of_not_ge h0)) h1
  by_cases h2 : t ≤ ((159952501247 : ℝ) / 200000000000)
  · exact G2_02_nonneg t (le_of_lt (lt_of_not_ge h1)) h2
  exact G2_03_nonneg t (le_of_lt (lt_of_not_ge h2)) hhi

theorem G3_nonnegative_on_interval (t : ℝ)
    (hlo : ((209952501247 : ℝ) / 250000000000) ≤ t) (hhi : t ≤ (1 : ℝ)) : gamma ≤ G3 t := by
  apply sub_nonneg.mp
  exact G3_00_nonneg t hlo hhi

theorem g0_lower (t : ℝ) (hlo : 0 ≤ t)
    (hhi : t ≤ b) : gamma ≤ g0 t := by
  rw [g0_expansion]
  apply G0_nonnegative_on_interval t
  · norm_num [b, w, c] at hlo ⊢ <;> exact hlo
  · norm_num [b, w, c] at hhi ⊢ <;> exact hhi

theorem g1_lower (t : ℝ) (hlo : b ≤ t)
    (hhi : t ≤ w) : gamma ≤ g1 t := by
  rw [g1_expansion]
  apply G1_nonnegative_on_interval t
  · norm_num [b, w, c] at hlo ⊢ <;> exact hlo
  · norm_num [b, w, c] at hhi ⊢ <;> exact hhi

theorem g2_lower (t : ℝ) (hlo : w ≤ t)
    (hhi : t ≤ c) : gamma ≤ g2 t := by
  rw [g2_expansion]
  apply G2_nonnegative_on_interval t
  · norm_num [b, w, c] at hlo ⊢ <;> exact hlo
  · norm_num [b, w, c] at hhi ⊢ <;> exact hhi

theorem g3_lower (t : ℝ) (hlo : c ≤ t)
    (hhi : t ≤ 1) : gamma ≤ g3 t := by
  rw [g3_expansion]
  apply G3_nonnegative_on_interval t
  · norm_num [b, w, c] at hlo ⊢ <;> exact hlo
  · norm_num [b, w, c] at hhi ⊢ <;> exact hhi

/-- The finite part of Lemma 1, with the algebraic definitions tied to the paper.
    This declaration is not Theorem 3: it contains no autocorrelation integral. -/
theorem finite_certificate :
    (∀ x : ℝ, 0 ≤ x → x ≤ 1 → 0 ≤ DP x) ∧
    (∀ t : ℝ, 0 ≤ t → t ≤ b → gamma ≤ g0 t) ∧
    (∀ t : ℝ, b ≤ t → t ≤ w → gamma ≤ g1 t) ∧
    (∀ t : ℝ, w ≤ t → t ≤ c → gamma ≤ g2 t) ∧
    (∀ t : ℝ, c ≤ t → t ≤ 1 → gamma ≤ g3 t) := by
  exact ⟨DP_nonnegative_on_interval, g0_lower, g1_lower, g2_lower, g3_lower⟩

end Autocorrelation
