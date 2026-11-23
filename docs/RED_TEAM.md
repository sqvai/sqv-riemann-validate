# Analytic red-team priorities (RH)

Focus human/Gamut review on the smallest cut-set of claims that can invalidate the main conclusion.

Priority lanes:

1. main inequality (M): theta-lift chain length ~√X, divisibility vs size comparison;
2. integrality / valuations of theta kernels (Lean-only inputs quoted by the paper);
3. Estimates B and C for auxiliary Dirichlet characters, and the averaging cleanup;
4. growth-bound ⇒ RH implication (window brackets / Landau-type steps);
5. Mathlib `riemannZeta` / `LFunction` definitional fidelity to classical objects;
6. paper↔Lean dictionary for (M) assembly (mean over a family of maps vs model case in §III.6).

Every objection must be an artifact with: claim ID, exact source location, exact Lean declaration if applicable, alleged failure, minimal proof obligation/counterexample, and status.
