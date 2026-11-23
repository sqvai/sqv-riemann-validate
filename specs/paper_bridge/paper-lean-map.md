# V4 — Paper ↔ Lean alignment (Waterloo zeta-paper)

Pinned paper:

- URL: https://www.math.uwaterloo.ca/~mrubinst/alpoge_claude_grh/zeta-paper.pdf
- Local: `papers/zeta-paper.pdf`
- SHA-256: `667d88b3c375adf0466678094f452ca966aef0f4d368f6340d2bd5328b7fb706`
- Status in paper: **working draft**; (M) is taken from Lean, not proved in the PDF.

Pinned Lean provenance:

- Announcement: https://alpo.ge/remark.pdf
- Archive SHA-256: `9631b4f020199e580ba86178cb56c6e9b09f690c2369a80dc4334aa93f49c7fc`
- Upstream pin: `config/upstream.env` (`UPSTREAM_REF`)

## Logical skeleton (paper §I / Parts I–II)

| Paper claim | Meaning | Lean / validation status |
|---|---|---|
| (M) + B + C ⇒ Estimate A | one-sided prime-power bound on long intervals | analytic reduction; paper proves implication in Part II |
| Estimate A ⇒ RH | zeros to the right of the critical line excluded | Lean root: `src/Main.lean` `riemannHypothesis` |
| Estimates B, C | auxiliary Dirichlet-character estimates | paper Part III claims proofs from literature; Lean has own proofs |
| (M) main inequality | arithmetic heart (theta lifts / divisibility vs size) | **quoted from Lean**; not proved in the PDF |

## Headline theorems (`src/Main.lean`)

| Lean theorem | Paper reading |
|---|---|
| `src/Main.lean` `riemannHypothesis` | Clay / classical RH for ζ |
| `src/Main.lean` `riemannZeta_eq_zero_re` | expanded zeros-on-line form used throughout the exposition |
| `src/Main.lean` `LFunction_ne_zero_of_half_lt_re` | no zeros with Re > 1/2 for Dirichlet L-functions |
| `src/Main.lean` `LFunction_eq_zero_re` | critical-strip zeros on the line (all characters) |
| `src/Main.lean` `LFunction_eq_zero_re_of_isPrimitive` | usual GRH phrasing for primitive characters |

## Sources cited by the paper (Lean paths)

These are the paper’s own Source list pointers (Part II end). Paths are relative to the upstream Lean tree:

- `src/Development/AutomorphicArithmetic/DedekindLFunctions/LandauTheorems/landauWindow.lean`
- `src/Formalism/ProductFormula/StatementOCCM.lean`
- `src/Formalism/SizeWindowBrackets/FirstPrimeNeSecondPrime.lean`
- `src/Formalism/StatementCM.lean`
- `src/Development/AutomorphicArithmetic/DedekindLFunctions/LandauTheorems/ChTop.lean`
- `src/Formalism/SizeWindowBrackets/GrowthBoundGivesRiemannHypothesis.lean`
- `src/Formalism/RankGapBounds/MeanBoundSecondForm.lean`
- `src/Development/AutomorphicArithmetic/CharacterBoxes/ExistsPageN.lean`
- `src/Development/AutomorphicArithmetic/MeanSquareBounds/pairEx.lean`
- `src/Development/AutomorphicArithmetic/CharacterBoxes/WinPairs.lean`
- `src/Development/AutomorphicArithmetic/PrimitiveCosets/CoreGm.lean`
- `src/Supplements/Kernels/MainTheorems.lean`
- `src/Development/AutomorphicArithmetic/AdelicQuotients/ThetaLiftLinear.lean`
- `src/Formalism/ThetaLiftIndependence/Statement.lean`
- `src/Formalism/SharpRestriction/GrowthBounds/CoarseMultiplicity/KeyMinorDvd.lean`
- `src/Development/AutomorphicSpectrum/Proofs/GeometryProofs/ChowlaSelbergPeriodStatement.lean`
- `src/Formalism/BehrendSets/StatementE.lean`
- `src/Formalism/ThickAverageLoss/PartnersToFactorsAt.lean`
- `src/Formalism/SharpRestriction/GlobalTheoremInputs.lean`
- `src/Formalism/CorankShare/StatementFR.lean`
- `src/Statements.lean`
- `src/Main.lean`

## Explicit non-claims (do not promote)

1. The Waterloo PDF alone does **not** constitute a complete proof of RH: (M) is external.
2. Passing V0–V2 means the Lean artifact builds/checks; it does not certify the PDF exposition.
3. V4 structural pass means cited Lean paths exist and the paper pin hashes; analytic red-team is V5.
