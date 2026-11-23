#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_bin lake
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"

actual_toolchain="$(tr -d '\r\n' < "$UPSTREAM_DIR/lean-toolchain")"
if [[ "$actual_toolchain" != "$EXPECTED_LEAN_TOOLCHAIN" ]]; then
  echo "Lean toolchain mismatch: got '$actual_toolchain', expected '$EXPECTED_LEAN_TOOLCHAIN'" >&2
  exit 1
fi

# Mathlib cache only (do not pull a prebuilt solution cache).
"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V0-CACHE "$UPSTREAM_DIR" \
  env MATHLIB_CACHE_GET_URL=https://cache.mathlib.org/mathlib4 lake exe mathlib/cache get
"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V0-BUILD "$UPSTREAM_DIR" lake build "$RH_BUILD_TARGET"
