# Roadmap

## P0 — machine validation
- immutable upstream SHA pin (original alpo.ge archive)
- V0 clean reproduction (`lake build Main`)
- V1 escape-hatch + axiom audit (five headline theorems)
- V2 Comparator/nanoda audit

## P0 — semantic + paper validation
- independently author Clay RH specification
- prove upstream → independent Clay implication
- pin Waterloo zeta-paper and map Sources → Lean paths
- record that (M) is Lean-sourced, not PDF-proved

## P1 — MathIR/ProofIR ingestion
- extract theorem/lemma DAG from `Main` closure
- attach paper locations and Lean declarations
- compute critical proof cut-set around (M)
- store objections as ResearchGraph nodes

## P1 — analytic swarm
- separate generator, formalizer, counterexample, referee roles
- no majority-vote promotion

## P2 — certified numerical corroboration
- reproduce paper scripts (`e1_running_example.py`, etc.)
- interval/ball arithmetic where feasible
- mark all outputs `NUMERICAL_CORROBORATION`
