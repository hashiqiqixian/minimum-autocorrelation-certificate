import Autocorrelation.CorrelationModel
import Autocorrelation.Bernstein

set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

-- Proof candidate. All literals were produced with rational arithmetic.
def DP_00_coeffs : List ℕ :=
  [1303260710437,
    13322014809265,
    55642819258235,
    129081491190677,
    170622249536905,
    146377716985811,
    69293953413209,
    19554288495271,
    2251995184958,
    0]

theorem DP_00_identity (s : ℝ) :
    DP ((0 : ℝ)+((1 : ℝ)-(0 : ℝ))*s) = hom DP_00_coeffs s (1-s) / 1000000000000 := by
  norm_num [DP, gamma, hom, DP_00_coeffs] <;> ring

theorem DP_00_unit_nonneg (s : ℝ) (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    0 ≤ DP ((0 : ℝ)+((1 : ℝ)-(0 : ℝ))*s) := by
  rw [DP_00_identity]
  exact div_nonneg
    (hom_nonneg DP_00_coeffs s (1-s) hs0 (sub_nonneg.mpr hs1))
    (by norm_num)

theorem DP_00_nonneg (t : ℝ) (hlo : (0 : ℝ) ≤ t) (hhi : t ≤ (1 : ℝ)) :
    0 ≤ DP t := by
  exact affine_nonneg (fun z => DP z) (0 : ℝ) (1 : ℝ)
    (by norm_num) DP_00_unit_nonneg t hlo hhi

end Autocorrelation
