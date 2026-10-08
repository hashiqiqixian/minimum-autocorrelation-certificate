#!/usr/bin/env python3
"""Compare the delivered specification with the original handoff ZIP.

This is a lightweight, read-only source comparison, not a Lean parser or a
kernel check. It reads ZIP members without extracting or executing them.
Comments and whitespace are ignored when comparing the twelve Lean definitions.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
CORE = {
    "OverlapIntegralClaim": "overlap_integral",
    "WitnessAdmissibilityClaim": "witness_admissibility",
    "MassIntegralClaim": "mass_integral",
    "UniformCorrelationClaim": "uniform_correlation",
    "ExplicitMainClaim": "explicit_main",
    "LimitingMainClaim": "limiting_main",
}
EXPECTED_DEFINITIONS = {
    "phi", "density", "extendedDensity", "witness", "autocorrelation",
    "algebraicCorrelation", *CORE,
}


def strip_comments(text: str) -> str:
    """Remove nested Lean block comments and line comments from these sources."""
    out: list[str] = []
    i = depth = 0
    while i < len(text):
        if text.startswith("/-", i):
            depth += 1
            i += 2
        elif depth and text.startswith("-/", i):
            depth -= 1
            i += 2
        elif depth:
            i += 1
        elif text.startswith("--", i):
            end = text.find("\n", i)
            i = len(text) if end < 0 else end
        else:
            out.append(text[i])
            i += 1
    if depth:
        raise ValueError("Unclosed Lean block comment")
    return "".join(out)


def definitions(text: str) -> dict[str, str]:
    text = strip_comments(text)
    matches = list(re.finditer(r"(?ms)^def\s+(\w+).*?(?=^def\s+|^end\s+|\Z)", text))
    result = {m.group(1): re.sub(r"\s+", "", m.group(0)) for m in matches}
    if len(result) != len(matches):
        raise ValueError("Duplicate definition names")
    return result


def unique_member(names: list[str], suffix: str) -> str:
    matches = [name for name in names if name.endswith(suffix)]
    if len(matches) != 1:
        raise ValueError(f"Expected one ZIP member ending in {suffix!r}, found {matches!r}")
    return matches[0]


def inspect(archive: Path) -> dict:
    with ZipFile(archive) as zipped:
        target_member = unique_member(
            zipped.namelist(), "autocorrelation_lean/Autocorrelation/Targets.lean")
        cert_member = unique_member(zipped.namelist(), "autocorrelation_lean/certificate.json")
        old = definitions(zipped.read(target_member).decode("utf-8-sig"))
        original_certificate = zipped.read(cert_member)

    current = definitions((ROOT / "Autocorrelation/Targets.lean").read_text(encoding="utf-8-sig"))
    certificate = (ROOT / "certificate.json").read_bytes()
    data = json.loads(certificate)
    ratios = strip_comments((ROOT / "Autocorrelation/Ratios.lean").read_text(encoding="utf-8-sig"))
    ratio_checks = {}
    for declaration, key in [("limitingRatio", "atomic_ratio"), ("explicitRatio", "function_ratio")]:
        match = re.search(
            r"^def " + declaration + r"\s*:\s*ℝ\s*:=\s*\((\d+)\s*:\s*ℝ\)\s*/\s*(\d+)",
            ratios, re.M)
        ratio_checks[declaration] = (
            match is not None and match.group(1) + "/" + match.group(2) == data[key])

    audit = strip_comments((ROOT / "Audit.lean").read_text(encoding="utf-8-sig"))
    bindings = {
        claim: bool(re.search(
            r"^example\s*:\s*Autocorrelation\." + claim
            + r"\s*:=\s*Autocorrelation\." + theorem + r"\b", audit, re.M))
        for claim, theorem in CORE.items()
    }
    names_correct = set(old) == EXPECTED_DEFINITIONS == set(current)
    unchanged = old == current
    certificate_unchanged = original_certificate == certificate
    passed = names_correct and unchanged and certificate_unchanged and all(ratio_checks.values()) and all(bindings.values())
    return {
        "status": "PASS" if passed else "FAIL",
        "exit_code": 0 if passed else 1,
        "original_targets_member": target_member,
        "original_definition_count": len(old),
        "current_definition_count": len(current),
        "definition_names": list(old),
        "expected_twelve_definition_names": names_correct,
        "added_definitions": sorted(current.keys() - old.keys()),
        "removed_definitions": sorted(old.keys() - current.keys()),
        "changed_definitions_ignoring_comments_whitespace": sorted(
            name for name in old.keys() & current.keys() if old[name] != current[name]),
        "all_definitions_unchanged": unchanged,
        "certificate_bytes_unchanged": certificate_unchanged,
        "original_certificate_sha256": hashlib.sha256(original_certificate).hexdigest(),
        "certificate_sha256": hashlib.sha256(certificate).hexdigest(),
        "ratio_literals_match_certificate": ratio_checks,
        "audit_original_claim_type_bindings": bindings,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", nargs="?", type=Path, default=ROOT.parent / "lean_codex_handoff.zip")
    parser.add_argument("--output", type=Path, default=ROOT / "logs/current-run/specification-check.json")
    args = parser.parse_args()
    archive = args.archive.resolve()
    result = {
        "checked_at_utc": datetime.now(timezone.utc).isoformat(),
        "input_archive": str(archive),
        "comparison_scope": "Source comparison only; no Lean compiler invoked by this check",
    }
    try:
        result.update(inspect(archive))
    except Exception as error:
        result.update(status="FAIL", exit_code=1, error=f"{type(error).__name__}: {error}")
    output = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output, encoding="utf-8")
    print(output, end="")
    return result["exit_code"]


if __name__ == "__main__":
    raise SystemExit(main())
