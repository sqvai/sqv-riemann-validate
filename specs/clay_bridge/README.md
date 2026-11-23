# V3 — Independent Clay semantic bridge (Riemann Hypothesis)

This directory is intentionally empty of copied Alpöge theorem definitions beyond the implication bridge.

Goal: encode the Clay RH statement independently, then prove that the upstream `Main` theorems imply it.

Required artifacts:

- `SQVClayRHSpec.lean` — independently authored from the classical / Clay RH statement (Mathlib-only).
- `UpstreamToClayBridge.lean` — imports upstream `Main` and proves implication into `SQVClayRHSpec`.
- `statement-diff.md` — human-readable comparison vs Clay, Mathlib, Waterloo paper, and upstream.
- `RH26-V3-CLAY-BRIDGE.json` — receipt.

Rule: a successful Lean proof of the upstream theorem is not sufficient for V3. The independently authored statement must be reviewed against the official Clay/classical statement first.
