#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
UF="${UAIR_FORGE:-$HOME/.local/bin/uair-forge}"
GATE="${1:?gate id e.g. RH26-V4-PAPER}"
PARENT="${2:?parent graph node uuid}"
RECEIPT="$ROOT/receipts/${GATE}.json"
test -f "$RECEIPT"
GATE_SHA="$(sha256sum "$RECEIPT" | awk '{print $1}')"
MEAS_SHA="$("$ROOT/missions/rh26-validate/scripts/write-counted-receipt.sh")"
"$UF" self-improve hyperagents2 harness-run \
  --task-id "$GATE" \
  --label "$GATE PASS gate_receipt_sha=$GATE_SHA" \
  --measurement-sha "$MEAS_SHA" \
  --parent "$PARENT" \
  --long-running-root "$ROOT/missions/rh26-validate"
echo "recorded $GATE gate_sha=$GATE_SHA measurement_sha=$MEAS_SHA parent=$PARENT"
