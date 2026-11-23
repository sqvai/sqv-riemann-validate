# Threat model

We explicitly defend against:

1. **Wrong theorem, correct proof** — formalization omits or weakens Clay/classical RH.
2. **Proof escape hatch** — `sorry`, new axioms, unsafe shortcuts, or equivalent mechanisms enter the proof closure.
3. **Correlated checker failure** — one implementation accepts a malformed artifact; mitigated with independent export/checking.
4. **Dependency drift** — unpinned Lean/mathlib/Comparator changes alter semantics or checking behavior.
5. **Paper/formal mismatch** — Waterloo exposition quotes Lean for (M) while readers treat the PDF as a full proof.
6. **LLM consensus illusion** — multiple agents agree on the same mistake; agent opinions are not evidence.
7. **Numerical-proof confusion** — simulation supports a conjecture but cannot promote it to proof.
8. **Receipt tampering** — evidence and logs are SHA-256 bound to gate receipts.
9. **Scope inflation** — claiming ERH / Dedekind / Hecke L-functions when only Dirichlet GRH is formalized.

The trusted base should remain as small as practical: independently authored statement, proof kernels/checkers, hash tooling, and explicit dependency pins.
