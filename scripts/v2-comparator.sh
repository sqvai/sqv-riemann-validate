#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
require_bin landrun
require_bin lean4export
require_bin nanoda_bin
ensure_challenge_overlay
export LEAN_ABORT_ON_PANIC=1
export LAKE_ARTIFACT_CACHE=false
"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V2-COMPARATOR "$UPSTREAM_DIR" lake exe comparator "$RH_COMPARATOR"
