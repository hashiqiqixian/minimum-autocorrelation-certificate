import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
PROOF CANDIDATE — NOT COMPILED in the generation environment.
All real coefficients below are exact rational expressions.
See README_zh.md and STATUS.json for the scope and verification boundary.
-/
set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 100000
noncomputable section
namespace Autocorrelation

/-- The binomial weights have already been absorbed into these natural
    coefficients. This is a homogeneous polynomial evaluated by Horner's rule. -/
def hom : List ℕ → ℝ → ℝ → ℝ
  | [], _, _ => 0
  | k::ks, x, y => (k : ℝ) * y^ks.length + x * hom ks x y

theorem hom_nonneg (ks : List ℕ) (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    0 ≤ hom ks x y := by
  induction ks with
  | nil => simp [hom]
  | cons k ks ih =>
    exact add_nonneg
      (mul_nonneg (Nat.cast_nonneg k) (pow_nonneg hy _))
      (mul_nonneg hx ih)

/-- This lemma carries a whole-interval proof, not a sampled-point test. -/
theorem affine_nonneg (p : ℝ → ℝ) (lo hi : ℝ) (hspan : lo < hi)
    (hcert : ∀ s : ℝ, 0 ≤ s → s ≤ 1 → 0 ≤ p (lo+(hi-lo)*s))
    (t : ℝ) (hlo : lo ≤ t) (hhi : t ≤ hi) : 0 ≤ p t := by
  have hd : 0 < hi-lo := sub_pos.mpr hspan
  have hs0 : 0 ≤ (t-lo)/(hi-lo) := div_nonneg (sub_nonneg.mpr hlo) hd.le
  have hs1 : (t-lo)/(hi-lo) ≤ 1 := (div_le_one hd).2 (by linarith)
  have he : lo+(hi-lo)*((t-lo)/(hi-lo)) = t := by
    field_simp [ne_of_gt hd] <;> ring
  have h := hcert ((t-lo)/(hi-lo)) hs0 hs1
  rw [he] at h
  exact h

end Autocorrelation
