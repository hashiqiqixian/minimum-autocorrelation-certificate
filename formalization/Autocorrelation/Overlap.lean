import Autocorrelation.ElementaryAnalysis
import Autocorrelation.Targets

/-! Actual Lebesgue overlap integrals, including every breakpoint. -/
set_option autoImplicit false
noncomputable section
namespace Autocorrelation
open MeasureTheory Set

private def overlapRamp (x : ℝ) : ℝ := P ((x-b)/w)

private theorem overlap_c_sub_b : c-b=w := by dsimp [c, w]; ring

private theorem overlap_ramp_continuous : Continuous overlapRamp :=
  continuous_P.comp ((continuous_id.sub continuous_const).div_const w)

private theorem overlap_phi_zero (x : ℝ) (hx : x ≤ b) : phi x=0 := by
  rcases lt_or_eq_of_le hx with hx | rfl
  · simp [phi, hx]
  · simp [phi, le_of_lt breakpoint_order.2.1,
      le_trans (le_of_lt breakpoint_order.2.1) (le_of_lt breakpoint_order.2.2.1),
      P_zero]

private theorem overlap_phi_ramp (x : ℝ) (hb : b ≤ x) (hc : x ≤ c) :
    phi x=overlapRamp x := by
  simp [phi, not_lt.mpr hb, hc, overlapRamp]

private theorem overlap_phi_one (x : ℝ) (hc : c ≤ x) (h1 : x ≤ 1) :
    phi x=1 := by
  have hbc : b<c := lt_trans breakpoint_order.2.1 breakpoint_order.2.2.1
  rcases eq_or_lt_of_le hc with rfl | hx
  · rw [overlap_phi_ramp c hbc.le le_rfl]
    simp [overlapRamp, overlap_c_sub_b, ne_of_gt w_pos, P_one]
  · simp [phi, not_lt.mpr (le_trans hbc.le hc), not_le.mpr hx, h1]

private theorem overlap_phi_indicator (x : ℝ) :
    phi x = (Ioc b c).indicator overlapRamp x +
      (Ioc c 1).indicator (fun _ : ℝ => 1) x := by
  have hbc : b<c := lt_trans breakpoint_order.2.1 breakpoint_order.2.2.1
  by_cases hb : x ≤ b
  · rw [overlap_phi_zero x hb]
    have hc : x ≤ c := le_trans hb hbc.le
    simp [Set.indicator, Set.mem_Ioc, not_lt.mpr hb, not_lt.mpr hc]
  · have hbx : b<x := lt_of_not_ge hb
    by_cases hc : x ≤ c
    · rw [overlap_phi_ramp x hbx.le hc]
      simp [Set.indicator, Set.mem_Ioc, hbx, hc, not_lt.mpr hc]
    · have hcx : c<x := lt_of_not_ge hc
      by_cases h1 : x ≤ 1
      · rw [overlap_phi_one x hcx.le h1]
        simp [Set.indicator, Set.mem_Ioc, hc, hcx, h1]
      · simp [phi, not_lt.mpr hbx.le, hc, h1, Set.indicator, Set.mem_Ioc]

private theorem overlap_indicator_shift (l r t x : ℝ) (f : ℝ → ℝ) :
    (Ioc l r).indicator f (x+t) =
      (Ioc (l-t) (r-t)).indicator (fun y => f (y+t)) x := by
  have h : (l<x+t ∧ x+t≤r) ↔ (l-t<x ∧ x≤r-t) := by
    constructor <;> intro h <;> constructor <;> linarith [h.1, h.2]
  simp only [Set.indicator, Set.mem_Ioc]
  simp only [h]

private theorem overlap_product (t : ℝ) (ht : 0≤t) (x : ℝ) :
    phi x * phi (x+t) =
      (Ioc b (c-t)).indicator (fun y => overlapRamp y*overlapRamp (y+t)) x +
      (Ioc (max b (c-t)) (min c (1-t))).indicator overlapRamp x +
      (Ioc c (1-t)).indicator (fun _ : ℝ => 1) x := by
  have hrr : Ioc b c ∩ Ioc (b-t) (c-t) = Ioc b (c-t) := by
    ext y
    simp only [mem_inter_iff, mem_Ioc]
    constructor
    · intro h; exact ⟨h.1.1, h.2.2⟩
    · intro h; constructor <;> constructor <;> linarith [h.1, h.2]
  have hrp : Ioc b c ∩ Ioc (c-t) (1-t) =
      Ioc (max b (c-t)) (min c (1-t)) := by
    ext y
    simp only [mem_inter_iff, mem_Ioc, max_lt_iff, le_min_iff]
    tauto
  have hpr : Ioc c 1 ∩ Ioc (b-t) (c-t) = ∅ := by
    ext y
    simp only [mem_inter_iff, mem_Ioc, mem_empty_iff_false, iff_false]
    intro h
    linarith [h.1.1, h.2.2]
  have hpp : Ioc c 1 ∩ Ioc (c-t) (1-t) = Ioc c (1-t) := by
    ext y
    simp only [mem_inter_iff, mem_Ioc]
    constructor
    · intro h; exact ⟨h.1.1, h.2.2⟩
    · intro h; constructor <;> constructor <;> linarith [h.1, h.2]
  rw [overlap_phi_indicator x, overlap_phi_indicator (x+t),
    overlap_indicator_shift b c t x overlapRamp,
    overlap_indicator_shift c 1 t x (fun _ : ℝ => 1)]
  rw [add_mul, mul_add, mul_add]
  simp only [← Set.inter_indicator_mul, hrr, hrp, hpr, hpp,
    mul_one, one_mul, Set.indicator_empty, zero_add, add_zero]

private theorem overlap_integrable_indicator (f : ℝ → ℝ) (hf : Continuous f)
    (l r : ℝ) : Integrable ((Ioc l r).indicator f) :=
  hf.integrableOn_Ioc.integrable_indicator measurableSet_Ioc

private theorem overlap_integral_split (t : ℝ) (ht : 0≤t) :
    autocorrelation phi t =
      (∫ x : ℝ, (Ioc b (c-t)).indicator
        (fun y => overlapRamp y*overlapRamp (y+t)) x) +
      (∫ x : ℝ, (Ioc (max b (c-t)) (min c (1-t))).indicator overlapRamp x) +
      (∫ x : ℝ, (Ioc c (1-t)).indicator (fun _ : ℝ => 1) x) := by
  have hrr := overlap_integrable_indicator
    (fun y => overlapRamp y*overlapRamp (y+t))
    (overlap_ramp_continuous.mul
      (overlap_ramp_continuous.comp (continuous_id.add continuous_const))) b (c-t)
  have hrp := overlap_integrable_indicator overlapRamp overlap_ramp_continuous
    (max b (c-t)) (min c (1-t))
  have hpp := overlap_integrable_indicator (fun _ : ℝ => 1) continuous_const c (1-t)
  unfold autocorrelation
  simp_rw [overlap_product t ht]
  have hadd1 := integral_add hrr hrp
  have hadd2 := integral_add (hrr.add hrp) hpp
  simp only [Pi.add_apply] at hadd1 hadd2
  rw [hadd2, hadd1]

private theorem overlap_integral_ramp (l r : ℝ) (hlr : l≤r) :
    (∫ x : ℝ, (Ioc l r).indicator overlapRamp x) =
      w*(I ((r-b)/w)-I ((l-b)/w)) := by
  have hd (x : ℝ) : HasDerivAt (fun y : ℝ => w*I ((y-b)/w))
      (overlapRamp x) x := by
    have hh := ((hasDerivAt_I ((x-b)/w)).comp x
      (((hasDerivAt_id x).sub_const b).div_const w)).const_mul w
    convert hh using 1 <;> dsimp [overlapRamp] <;>
      field_simp [ne_of_gt w_pos] <;> ring
  rw [integral_indicator measurableSet_Ioc, ← intervalIntegral.integral_of_le hlr]
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun x _ => hd x) (overlap_ramp_continuous.intervalIntegrable l r)]
  ring

private theorem overlap_integral_ramp_product (l r t : ℝ) (hlr : l≤r) :
    (∫ x : ℝ, (Ioc l r).indicator
      (fun y => overlapRamp y*overlapRamp (y+t)) x) =
      w*(RR ((r-b)/w) (t/w)-RR ((l-b)/w) (t/w)) := by
  have hd (x : ℝ) : HasDerivAt (fun y : ℝ => w*RR ((y-b)/w) (t/w))
      (overlapRamp x*overlapRamp (x+t)) x := by
    have hh := ((hasDerivAt_RR ((x-b)/w) (t/w)).comp x
      (((hasDerivAt_id x).sub_const b).div_const w)).const_mul w
    have harg : (x-b)/w+t/w=(x+t-b)/w := by ring
    convert hh using 1 <;> dsimp [overlapRamp] <;>
      rw [harg] <;> field_simp [ne_of_gt w_pos] <;> ring
  have hcont : Continuous (fun y => overlapRamp y*overlapRamp (y+t)) :=
    overlap_ramp_continuous.mul
      (overlap_ramp_continuous.comp (continuous_id.add continuous_const))
  rw [integral_indicator measurableSet_Ioc, ← intervalIntegral.integral_of_le hlr]
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun x _ => hd x) (hcont.intervalIntegrable l r)]
  ring

private theorem overlap_integral_one (l r : ℝ) (hlr : l≤r) :
    (∫ x : ℝ, (Ioc l r).indicator (fun _ : ℝ => 1) x)=r-l := by
  rw [integral_indicator measurableSet_Ioc, ← intervalIntegral.integral_of_le hlr]
  simp

private theorem overlap_integral_empty (l r : ℝ) (f : ℝ → ℝ) (hrl : r≤l) :
    (∫ x : ℝ, (Ioc l r).indicator f x)=0 := by
  simp [Ioc_eq_empty hrl.not_lt]

private theorem overlap_normalize (t : ℝ) :
    (c-t-b)/w=1-t/w ∧ (c-b)/w=1 ∧ (1-t-b)/w=(c-t)/w := by
  have hcb := overlap_c_sub_b
  constructor
  · have he : c-t-b=w-t := by linarith
    rw [he, sub_div, div_self (ne_of_gt w_pos)]
  constructor
  · rw [hcb, div_self (ne_of_gt w_pos)]
  · congr 1
    dsimp [c]
    ring

private theorem overlap_first (t : ℝ) (ht0 : 0≤t) (htb : t≤b) :
    phi t+autocorrelation phi t/a^2=g0 t := by
  have hbc : b<c := lt_trans breakpoint_order.2.1 breakpoint_order.2.2.1
  have hbw := breakpoint_order.2.1
  have hcb := overlap_c_sub_b
  have hc : c=1-b := rfl
  have h1 : b≤c-t := by linarith
  have h2 : c-t≤c := by linarith
  have h3 : c≤1-t := by linarith
  rw [overlap_phi_zero t htb, overlap_integral_split t ht0,
    max_eq_right h1, min_eq_left h3,
    overlap_integral_ramp_product b (c-t) t h1,
    overlap_integral_ramp (c-t) c h2,
    overlap_integral_one c (1-t) h3]
  obtain ⟨hu, hv, hz⟩ := overlap_normalize t
  simp only [hu, hv, sub_self, zero_div, RR_zero, sub_zero, zero_add]
  dsimp [g0, H]
  rw [hc]
  ring

private theorem overlap_second (t : ℝ) (hbt : b≤t) (htw : t≤w) :
    phi t+autocorrelation phi t/a^2=g1 t := by
  have hb := breakpoint_order.1
  have hwc := breakpoint_order.2.2.1
  have hcb := overlap_c_sub_b
  have hc : c=1-b := rfl
  have ht0 : 0≤t := by linarith
  have h1 : b≤c-t := by linarith
  have h2 : 1-t≤c := by linarith
  have h3 : c-t≤1-t := by linarith
  have htc : t≤c := by linarith
  rw [overlap_phi_ramp t hbt htc, overlap_integral_split t ht0,
    max_eq_right h1, min_eq_right h2,
    overlap_integral_ramp_product b (c-t) t h1,
    overlap_integral_ramp (c-t) (1-t) h3,
    overlap_integral_empty c (1-t) (fun _ : ℝ => 1) h2]
  obtain ⟨hu, hv, hz⟩ := overlap_normalize t
  simp only [hu, hz, sub_self, zero_div, RR_zero, sub_zero, add_zero]
  rfl

private theorem overlap_third (t : ℝ) (hwt : w≤t) (htc : t≤c) :
    phi t+autocorrelation phi t/a^2=g2 t := by
  have hb := breakpoint_order.1
  have hbw := breakpoint_order.2.1
  have hcb := overlap_c_sub_b
  have hc : c=1-b := rfl
  have ht0 : 0≤t := by linarith
  have hbt : b≤t := by linarith
  have h1 : c-t≤b := by linarith
  have h2 : 1-t≤c := by linarith
  have h3 : b≤1-t := by linarith
  rw [overlap_phi_ramp t hbt htc, overlap_integral_split t ht0,
    max_eq_left h1, min_eq_right h2,
    overlap_integral_empty b (c-t) (fun y => overlapRamp y*overlapRamp (y+t)) h1,
    overlap_integral_ramp b (1-t) h3,
    overlap_integral_empty c (1-t) (fun _ : ℝ => 1) h2]
  obtain ⟨hu, hv, hz⟩ := overlap_normalize t
  simp only [hz, sub_self, zero_div, I_zero, sub_zero, zero_add, add_zero]
  rfl

private theorem overlap_fourth (t : ℝ) (hct : c≤t) (ht1 : t≤1) :
    phi t+autocorrelation phi t/a^2=g3 t := by
  have hb := breakpoint_order.1
  have hbc : b<c := lt_trans breakpoint_order.2.1 breakpoint_order.2.2.1
  have hc : c=1-b := rfl
  have ht0 : 0≤t := by linarith
  have h1 : c-t≤b := by linarith
  have h2 : 1-t≤c := by linarith
  have h3 : 1-t≤b := by linarith
  rw [overlap_phi_one t hct ht1, overlap_integral_split t ht0,
    max_eq_left h1, min_eq_right h2,
    overlap_integral_empty b (c-t) (fun y => overlapRamp y*overlapRamp (y+t)) h1,
    overlap_integral_empty b (1-t) overlapRamp h3,
    overlap_integral_empty c (1-t) (fun _ : ℝ => 1) h2]
  simp [g3]

/-- Identification of the actual Lebesgue autocorrelation with the four exact
polynomials. The proof includes `t=0`, `t=1`, and all internal breakpoints. -/
theorem overlap_integral : OverlapIntegralClaim := by
  intro t ht0 ht1
  unfold algebraicCorrelation
  split_ifs with hb hw hc
  · exact overlap_first t ht0 hb
  · exact overlap_second t (le_of_lt (lt_of_not_ge hb)) hw
  · exact overlap_third t (le_of_lt (lt_of_not_ge hw)) hc
  · exact overlap_fourth t (le_of_lt (lt_of_not_ge hc)) ht1

end Autocorrelation
