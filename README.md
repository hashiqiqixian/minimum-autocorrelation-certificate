# An improved lower bound for the minimum-autocorrelation constant

Working manuscript dated September 17, 2026. The author line in the supplied PDF is still marked "Author information pending."

[Read the manuscript (PDF)](autocorrelation_arxiv_draft.pdf)

The manuscript constructs nonnegative, bounded, compactly supported functions giving the lower bound

```text
A >= 0.4103779774321214877852987...
```

for the minimum-autocorrelation constant. Its construction combines an atomic component with a monotone polynomial density. Exact rational polynomial inequalities are certified by Bernstein subdivision, and a one-sided atom-removal argument produces ordinary-function witnesses.

## Contents

- [`autocorrelation_arxiv_draft.pdf`](autocorrelation_arxiv_draft.pdf): the supplied 12-page working draft.
- [`source_evidence.md`](source_evidence.md): supplied excerpts of manuscript source, Lean statements, verification logs, hashes, and reproducibility notes.

## Verification scope

The accompanying evidence reports a clean Lean 4.19.0/mathlib v4.19.0 build and exact-arithmetic checks for the principal construction statements. This repository contains evidence excerpts, **not** the full Lean project, LaTeX source, certificate files, or verification scripts cited there. The reported checks therefore cannot be rerun from this repository alone. No independent verification is claimed here.

The manuscript does not claim an improved bound for the complete sparse ruler constant or a solution to Erdős Problem #170. The PDF is a working draft, not an arXiv posting or a peer-reviewed publication.
