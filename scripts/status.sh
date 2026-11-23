#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
"$AUDIT_BIN" status "$RECEIPT_DIR"
