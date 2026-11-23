# Validation model

## Gates

| Gate | Meaning | Promotion condition |
|---|---|---|
| V0 | Reproduction | pinned upstream checkout builds cleanly (`Main`) |
| V1 | Kernel/dependency audit | acceptable axioms; no unapproved proof escape hatch in proof closure |
| V2 | Independent checker | Comparator/nanoda accepts exported proof vs `Challenge` |
| V3 | Semantic bridge | independently authored Clay RH spec is implied by upstream theorem |
| V4 | Paper ↔ Lean alignment | Waterloo claims map to formal declarations; PDF hash pinned; cited paths exist |
| V5 | Adversarial analytic review | critical lemmas (esp. (M), theta lifts, character estimates) survive red-team |
| V6 | Numerical corroboration | explicit constructions/scripts reproduce within certified error bounds |

`V6` can never promote a theorem to proven. Numerical/quantum experiments are evidence only.

The Waterloo paper is a **working guide**: Parts I–II reduce RH to (M)+B+C; (M) itself is taken from Lean. V4 therefore tracks alignment and explicit non-claims; it does not treat the PDF as a complete proof.

## Final statuses

- `UNVERIFIED`
- `REPRODUCED`
- `FORMALLY_CHECKED`
- `SEMANTICALLY_BRIDGED`
- `PAPER_ALIGNED`
- `ADVERSARIALLY_REVIEWED`
- `INDEPENDENTLY_VALIDATED`
- `REFUTED`
- `INCONCLUSIVE`

This repository never emits `CLAY_ACCEPTED`; that is an external institutional status.
