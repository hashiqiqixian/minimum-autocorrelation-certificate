import Autocorrelation.Model
import Autocorrelation.Ratios
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic

/-!
These are the unchanged specification propositions, not proofs by themselves.
Their proofs are in Overlap, Witness, Mass, Uniform and Main, imported by the
project entry point and checked by Audit.lean. Compiling this file alone does
not prove the claims.
-/
set_option autoImplicit false
noncomputable section
namespace Autocorrelation
open MeasureTheory

/-- Exact pointwise profile from the manuscript. -/
def phi (x : ℝ) : ℝ :=
  if x < b then 0 else
  if x ≤ c then P ((x-b)/w) else
  if x ≤ 1 then 1 else 0

def density (x : ℝ) : ℝ := phi x/a

def extendedDensity (delta x : ℝ) : ℝ :=
  if 0 ≤ x ∧ x ≤ 1 then density x else
  if 1 < x ∧ x ≤ 1+delta then 1/a else 0

def witness (delta x : ℝ) : ℝ :=
  (if 0 ≤ x ∧ x ≤ delta then a/delta else 0) + extendedDensity delta x

def autocorrelation (f : ℝ → ℝ) (t : ℝ) : ℝ :=
  ∫ x : ℝ, f x * f (x+t)

def algebraicCorrelation (t : ℝ) : ℝ :=
  if t ≤ b then g0 t else
  if t ≤ w then g1 t else
  if t ≤ c then g2 t else g3 t

/-- Identification of actual Lebesgue overlap integrals with g0,...,g3. -/
def OverlapIntegralClaim : Prop :=
  ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
    phi t + autocorrelation phi t/a^2 = algebraicCorrelation t

/-- Measurability/integrability must be proved, not inferred from a totalized integral. -/
def WitnessAdmissibilityClaim : Prop :=
  ∀ delta : ℝ, 0 < delta →
    Integrable (witness delta) ∧
    Integrable (fun x => (witness delta x)^2) ∧
    (∀ x : ℝ, 0 ≤ witness delta x) ∧
    (∀ t : ℝ, Integrable (fun x => witness delta x*witness delta (x+t)))

def MassIntegralClaim : Prop :=
  ∀ delta : ℝ, 0 < delta → (∫ x : ℝ, witness delta x) = mass+delta/a

def UniformCorrelationClaim : Prop :=
  ∀ delta : ℝ, 0 < delta →
    ∀ t : ℝ, 0 ≤ t → t ≤ 1 → gamma ≤ autocorrelation (witness delta) t

/-- The concrete, nonlimiting function version of the manuscript's main result. -/
def ExplicitMainClaim : Prop :=
  let f := witness delta0
  Integrable f ∧
  Integrable (fun x => (f x)^2) ∧
  (∀ x : ℝ, 0 ≤ f x) ∧
  0 < (∫ x : ℝ, f x) ∧
  (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
    Integrable (fun x => f x*f (x+t)) ∧
    explicitRatio ≤ autocorrelation f t / (∫ x : ℝ, f x)^2)

/-- A lower-bound formulation avoiding an unproved identification of differently
normalized supremum constants. It supplies arbitrarily close ordinary
L¹∩L² witnesses, without asserting a separate supremum identification. -/
def LimitingMainClaim : Prop :=
  ∀ q : ℝ, q < limitingRatio → ∃ f : ℝ → ℝ,
    Integrable f ∧
    Integrable (fun x => (f x)^2) ∧
    (∀ x : ℝ, 0 ≤ f x) ∧
    0 < (∫ x : ℝ, f x) ∧
    (∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      Integrable (fun x => f x*f (x+t)) ∧
      q ≤ autocorrelation f t / (∫ x : ℝ, f x)^2)

end Autocorrelation
