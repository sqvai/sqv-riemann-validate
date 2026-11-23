#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
mkdir -p "$EVIDENCE_DIR/RH26-V1-KERNEL"

rm -f "$UPSTREAM_DIR/SQV_AxiomAudit.lean"
"$AUDIT_BIN" scan-lean "$UPSTREAM_DIR" | tee "$EVIDENCE_DIR/RH26-V1-KERNEL/escape-hatch-scan.tsv"
"$AUDIT_BIN" generate-axiom-audit "$UPSTREAM_DIR" "$UPSTREAM_DIR/SQV_AxiomAudit.lean"
"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V1-AXIOMS "$UPSTREAM_DIR" lake env lean SQV_AxiomAudit.lean
rm -f "$UPSTREAM_DIR/SQV_AxiomAudit.lean"
"$AUDIT_BIN" verify-axioms "$EVIDENCE_DIR/RH26-V1-AXIOMS/stdout.log" \
  riemannHypothesis \
  riemannZeta_eq_zero_re \
  LFunction_ne_zero_of_half_lt_re \
  LFunction_eq_zero_re \
  LFunction_eq_zero_re_of_isPrimitive
