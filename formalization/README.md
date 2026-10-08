# Formalization and exact certificate

This directory contains the source code from the verified `autocorrelation_lean` package. The historical verification record is in [README_zh.md](README_zh.md), [STATUS.json](STATUS.json), and [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md).

- `Autocorrelation/`, `Autocorrelation.lean`, `Audit.lean`, `FiniteAudit.lean`: Lean 4 formalization and axiom audit.
- `certificate.json`, `bernstein_leaves.json`: exact input parameters and generated Bernstein certificate data.
- `original/`: original LaTeX manuscript source and independent Python checks.
- `scripts/`: generation, audit, build, and dependency-check scripts.
- `lean-toolchain`, `lakefile.toml`, `lake-manifest.json`: pinned Lean and mathlib dependencies.

With Lean 4.19.0 installed and network access to the pinned dependencies, the basic checks can be run from this directory:

```text
lake update
lake build
lake env lean Audit.lean
python original/verify.py certificate.json
python original/independent_audit.py certificate.json
```

The original Windows orchestration scripts and their resource limits are documented in [README_zh.md](README_zh.md). They were written for a local `.tools/` installation, which is not bundled here. Historical raw logs and rebuildable dependency caches were omitted from this GitHub copy; the reports describe the original run. Lean was not rerun for this publication.

The original LaTeX source is titled *An atomic--polynomial certificate for minimum autocorrelation*. It belongs to the same research project as the PDF at the repository root, but the two are differently titled drafts and are not presented as a byte-for-byte source/PDF pair.
