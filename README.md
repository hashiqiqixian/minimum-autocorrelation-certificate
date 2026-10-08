# An improved lower bound for the minimum-autocorrelation constant

Working manuscript dated September 17, 2026. The author line in the supplied PDF is still marked "Author information pending."

[Read the manuscript (PDF)](autocorrelation_arxiv_draft.pdf) | [Browse the formalization](formalization/) | [Read the verification report](formalization/VERIFICATION_REPORT.md)

The manuscript constructs nonnegative, bounded, compactly supported functions giving the lower bound

```text
A >= 0.4103779774321214877852987...
```

for the minimum-autocorrelation constant. Its construction combines an atomic component with a monotone polynomial density. Exact rational polynomial inequalities are certified by Bernstein subdivision, and a one-sided atom-removal argument produces ordinary-function witnesses.

## Repository contents

- [`autocorrelation_arxiv_draft.pdf`](autocorrelation_arxiv_draft.pdf): the supplied 12-page working draft.
- [`formalization/`](formalization/): the complete 41-file Lean source tree, original LaTeX source, exact certificate data, Python checks, generation and audit scripts, Lean toolchain pin, mathlib lockfile, and verification reports.
- [`source_evidence.md`](source_evidence.md): excerpts and hashes from the supplied verification package.

The formalization was published from the local `autocorrelation_lean_verified.zip` package (SHA-256 `3486d2c2851ae6f909886caff55b07b47c2bb0140ee4d927b1d897a671e3eec0`). Historical raw build logs, local toolchain and dependency caches, an internal handoff prompt, and the older generated PDF are not included. The source and certificate files are retained; the two publication notes in the formalization reports remove local-machine assumptions and a local path.

## Reproducibility and scope

The project pins Lean 4.19.0 and mathlib v4.19.0. See the [formalization README](formalization/README_zh.md) for the historical build procedure and the [verification report](formalization/VERIFICATION_REPORT.md) for the reported checks. This publication did not rerun Lean; the report records the original verification run. Raw logs named in that historical report remain in the local source archive, not in this GitHub repository.

The formalized scope covers the principal construction statements and ordinary-function witnesses. It does not formalize every theorem or application in the manuscript, nor claim an improved bound for the complete sparse ruler constant or a solution to Erdős Problem #170.

The supplied PDF and `formalization/original/research_note.tex` are related but differently titled drafts. The LaTeX source is the exact original manuscript preserved with the verification package; it is not asserted to reproduce the published PDF byte for byte.
