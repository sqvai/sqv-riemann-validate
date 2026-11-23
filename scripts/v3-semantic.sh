#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
mkdir -p "$EVIDENCE_DIR/RH26-V3-CLAY-BRIDGE"

CLAY_BRIDGE_DIR="$REPO_ROOT/specs/clay_bridge"

UPSTREAM_LEAN_PATH="$(cd "$UPSTREAM_DIR" && lake env env | grep LEAN_PATH | cut -d= -f2-)"
export LEAN_PATH="$UPSTREAM_LEAN_PATH:$CLAY_BRIDGE_DIR"

(cd "$CLAY_BRIDGE_DIR" && lean -o SQVClayRHSpec.olean SQVClayRHSpec.lean)

"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V3-CLAY-BRIDGE "$REPO_ROOT" \
  lean specs/clay_bridge/UpstreamToClayBridge.lean

"$AUDIT_BIN" verify-axioms "$EVIDENCE_DIR/RH26-V3-CLAY-BRIDGE/stdout.log" \
  "SQV.ClayBridge.clay_riemann_hypothesis_proven"
