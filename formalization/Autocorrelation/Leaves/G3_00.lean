import Autocorrelation.CorrelationModel
import Autocorrelation.Bernstein

set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

-- Proof candidate. All literals were produced with rational arithmetic.
def G3_00_coeffs : List ℕ :=
  [1]

theorem G3_00_identity (s : ℝ) :
    G3 (((209952501247 : ℝ) / 250000000000)+((1 : ℝ)-((209952501247 : ℝ) / 250000000000))*s) - gamma = hom G3_00_coeffs s (1-s) / 100000000 := by
  norm_num [G3, gamma, hom, G3_00_coeffs] <;> ring

theorem G3_00_unit_nonneg (s : ℝ) (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    0 ≤ G3 (((209952501247 : ℝ) / 250000000000)+((1 : ℝ)-((209952501247 : ℝ) / 250000000000))*s) - gamma := by
  rw [G3_00_identity]
  exact div_nonneg
    (hom_nonneg G3_00_coeffs s (1-s) hs0 (sub_nonneg.mpr hs1))
    (by norm_num)

theorem G3_00_nonneg (t : ℝ) (hlo : ((209952501247 : ℝ) / 250000000000) ≤ t) (hhi : t ≤ (1 : ℝ)) :
    0 ≤ G3 t - gamma := by
  exact affine_nonneg (fun z => G3 z - gamma) ((209952501247 : ℝ) / 250000000000) (1 : ℝ)
    (by norm_num) G3_00_unit_nonneg t hlo hhi

end Autocorrelation
