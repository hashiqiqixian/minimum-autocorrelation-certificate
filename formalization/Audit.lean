import Autocorrelation

-- Run scripts/check.ps1 on Windows or scripts/check.sh on Unix.
#print axioms Autocorrelation.finite_certificate
#print axioms Autocorrelation.P_matches_paper
#print axioms Autocorrelation.hasDerivAt_P
#print axioms Autocorrelation.hasDerivAt_I
#print axioms Autocorrelation.hasDerivAt_RR
#print axioms Autocorrelation.P_monotoneOn
#print axioms Autocorrelation.P_bounds
#print axioms Autocorrelation.integral_P
#print axioms Autocorrelation.integral_PP
#print axioms Autocorrelation.g0_g1_match
#print axioms Autocorrelation.g1_g2_match
#print axioms Autocorrelation.g2_g3_match
#print axioms Autocorrelation.limiting_ratio_identity
#print axioms Autocorrelation.explicit_ratio_identity
#print axioms Autocorrelation.limiting_ratio_gt
#print axioms Autocorrelation.explicit_ratio_gt
#print axioms Autocorrelation.relaxation_mass_arithmetic
#print axioms Autocorrelation.monotone_extension_comparison
#print axioms Autocorrelation.autocorrelation_product_lower

#print axioms Autocorrelation.overlap_integral
#print axioms Autocorrelation.witness_admissibility
#print axioms Autocorrelation.mass_integral
#print axioms Autocorrelation.uniform_correlation
#print axioms Autocorrelation.explicit_main
#print axioms Autocorrelation.limiting_main

-- These type ascriptions ensure the audited declarations prove the original
-- specification propositions, with no additional unproved hypotheses.
example : Autocorrelation.OverlapIntegralClaim := Autocorrelation.overlap_integral
example : Autocorrelation.WitnessAdmissibilityClaim := Autocorrelation.witness_admissibility
example : Autocorrelation.MassIntegralClaim := Autocorrelation.mass_integral
example : Autocorrelation.UniformCorrelationClaim := Autocorrelation.uniform_correlation
example : Autocorrelation.ExplicitMainClaim := Autocorrelation.explicit_main
example : Autocorrelation.LimitingMainClaim := Autocorrelation.limiting_main
