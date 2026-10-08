import Autocorrelation.CorrelationModel

set_option autoImplicit false
set_option maxHeartbeats 0
noncomputable section
namespace Autocorrelation

def mass : ℝ := a + (w*I 1+b)/a
def limitingRatio : ℝ := (4713977940944586245580976375978623597750000000000000000 : ℝ)/11486917427785951575611071745219515905862879073559791929
def explicitRatio : ℝ := (4713977940944586245580976375978623597750000000000000000 : ℝ)/11486917430134691792906455293684961315501879073559791929

theorem mass_exact : mass = ((3389235522619511253196890923 : ℝ) / 2171169728069265000000000000) := by
  norm_num [mass, a, b, w, I]

theorem mass_pos : 0 < mass := by rw [mass_exact]; norm_num

theorem limiting_ratio_identity : gamma / mass^2 = limitingRatio := by
  rw [mass_exact]
  norm_num [gamma, limitingRatio]

theorem explicit_ratio_identity :
    gamma / (mass+delta0/a)^2 = explicitRatio := by
  rw [mass_exact]
  norm_num [gamma, delta0, a, explicitRatio]

theorem limiting_ratio_gt : (4103779 : ℝ)/10000000 < limitingRatio := by
  norm_num [limitingRatio]

theorem explicit_ratio_gt : (4103779 : ℝ)/10000000 < explicitRatio := by
  norm_num [explicitRatio]

theorem relaxation_mass_arithmetic : mass^2/gamma < (2436778 : ℝ)/1000000 := by
  rw [mass_exact]
  norm_num [gamma]

end Autocorrelation
