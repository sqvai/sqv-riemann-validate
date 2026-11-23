# SQV Riemann Hypothesis Validate

Independent, receipt-driven validation harness for Alpöge’s Claude-assisted Lean formalization of the Riemann Hypothesis (and Dirichlet GRH), with paper alignment against the Waterloo working draft.

## Trust rule

**Model output, numerical simulation, and narrative exposition are evidence—not proof.** Formal promotion requires explicit proof/checker gates and an independently authored semantic bridge to the Clay/classical statement.

## What this validates

| Artifact | Role |
|---|---|
| Lean development (alpo.ge archive / community `original` pin) | machine-checkable proof object |
| Waterloo zeta-paper | human exposition of the ζ case; **does not prove (M)** |
| Clay / classical RH | independent semantic target for V3 |

Paper: https://www.math.uwaterloo.ca/~mrubinst/alpoge_claude_grh/zeta-paper.pdf  
Announcement: https://alpo.ge/remark.pdf

## What exists now

- dependency-free Rust audit CLI (`rh-audit`);
- V0 reproducible build gate;
- V1 Lean proof-source escape-hatch and root-axiom gate (five headline theorems);
- V2 Comparator/nanoda independent-checker gate;
- V3 independent Clay RH semantic bridge workspace;
- V4 paper↔Lean structural alignment gate (pinned PDF hash + cited Lean paths);
- UAIR-style JSON receipts with SHA-256-bound logs;
- research-node JSON schema for MathIR/ProofIR/ResearchGraph ingestion.

## Hyperagents2 / Harness++

Long-running validation is driven by UAIR-Forge Hyperagents2:

```bash
export UAIR_FORGE_WORKSPACE=$PWD
make hyperagents-status
make wave          # next unfinished gate + counted-receipt harness-run
make graph-run     # multi-wave Harness++ loop (promotion=hold)
```

See `docs/HYPERAGENTS2.md`, mission `missions/rh26-validate/`, package `harness/rh26/`.

## Bootstrap

Requirements for V0/V1:

- `git`
- Rust/Cargo
- `elan` / Lean / Lake

V2 additionally requires Comparator challenge tooling:

- `landrun`
- `lean4export`
- `nanoda_bin`

```bash
make bootstrap
```

The bootstrap checks out the pinned immutable SHA in `config/upstream.env`. Challenge/comparator files are overlaid from `specs/comparator/` because they are not part of the original archive drop.

Run a local tool check first:

```bash
./scripts/preflight.sh
```

Then:

```bash
make v0
make v1
make v2
make v3
make v4
make status
```

or:

```bash
make machine-gates   # V0–V2 only
```

## Gate semantics

- **V0**: pinned repository reproduces/builds (`lake build Main`).
- **V1**: root theorem axioms and proof-source escape hatches audited.
- **V2**: independent Comparator/nanoda verification against `Challenge.lean`.
- **V3**: independently authored Clay RH spec is formally implied by upstream theorem.
- **V4**: Waterloo paper pin + Lean path alignment (structural; analytic red-team is V5).
- **V5**: adversarial analytic audit of critical cut-set (esp. (M) and theta-lift chain).
- **V6**: certified numerical corroboration only (never promotes to proof).

See `docs/VALIDATION_MODEL.md`.

## Upstream currently targeted

`https://github.com/leanprover-community/riemann-hypothesis.git` at the `original` archive commit pinned in `config/upstream.env` (Lean `v4.33.1`, Mathlib `0df444a3…`).

Authoritative archive SHA-256: `9631b4f020199e580ba86178cb56c6e9b09f690c2369a80dc4334aa93f49c7fc`.

## Why this repo is separate

The validator should remain independent from production Gamut/MathIR code. MathIR can ingest its receipts and theorem graph later, but production model code should not be in the trusted proof-checking base.
