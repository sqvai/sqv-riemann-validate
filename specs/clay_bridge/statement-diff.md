# Semantic Bridge Diff: Clay RH vs Formal Statements

## 1. Executive Summary

Independent comparison between:

1. **Clay / classical RH** — non-trivial zeros of ζ have real part 1/2.
2. **SQVClayRHSpec.lean** — independent Mathlib-only formalization.
3. **Upstream Main.lean** — Alpöge/Claude formalization (`riemannHypothesis` and four companions).
4. **Waterloo exposition** — [zeta-paper.pdf](https://www.math.uwaterloo.ca/~mrubinst/alpoge_claude_grh/zeta-paper.pdf) (working draft explaining the argument for ζ).

The bridge in `UpstreamToClayBridge.lean` checks that upstream implies the independent Clay RH (and the Dirichlet GRH companion).

## 2. Statement mapping

| Component | Clay / classical | SQVClayRHSpec | Upstream Main | Waterloo paper |
|---|---|---|---|---|
| Object | Riemann ζ | `riemannZeta` (Mathlib) | Mathlib `RiemannHypothesis` | ζ specialised exposition |
| Non-trivial zeros | Re = 1/2 | `s.re = 1/2` | same | RH conclusion of logical skeleton (I.1) |
| Trivial zeros | −2, −4, … | `¬∃ n, s = -2(n+1)` | same | excluded as usual |
| Pole | s = 1 | `s ≠ 1` | same | pole handled analytically |
| GRH scope | not required for Clay RH prize statement | `ClayDirichletGRH` | `LFunction_eq_zero_re` / primitive form | paper notes GRH for Dirichlet L-functions; ζ is trivial character |

## 3. Material caveats

- Waterloo paper **does not prove (M)**; it quotes (M) from the Lean development. V4 tracks that gap explicitly.
- Formal GRH here means **Dirichlet L-functions only** (all moduli/characters). Dedekind / Hecke / general automorphic L-functions are out of scope.
- Mathlib’s `riemannZeta` at `s = 1` is a conventional value; the `s ≠ 1` guard matches Mathlib and the challenge file.
