#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.elan/bin:$PATH"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/config/upstream.env"
AUDIT_BIN="${AUDIT_BIN:-$REPO_ROOT/target/release/rh-audit}"
UPSTREAM_DIR="${UPSTREAM_DIR:-$REPO_ROOT/upstream/riemann-hypothesis}"
RECEIPT_DIR="${RECEIPT_DIR:-$REPO_ROOT/receipts}"
EVIDENCE_DIR="${EVIDENCE_DIR:-$REPO_ROOT/evidence}"
COMPARATOR_SPEC_DIR="${COMPARATOR_SPEC_DIR:-$REPO_ROOT/specs/comparator}"

require_bin() { command -v "$1" >/dev/null 2>&1 || { echo "missing required command: $1" >&2; exit 2; }; }

ensure_challenge_overlay() {
  # The original archive has no Challenge/comparator; overlay the independent challenge.
  mkdir -p "$UPSTREAM_DIR/src"
  if [[ ! -f "$UPSTREAM_DIR/src/Challenge.lean" ]]; then
    cp "$COMPARATOR_SPEC_DIR/Challenge.lean" "$UPSTREAM_DIR/src/Challenge.lean"
  fi
  if [[ ! -f "$UPSTREAM_DIR/comparator.json" ]]; then
    cp "$COMPARATOR_SPEC_DIR/comparator.json" "$UPSTREAM_DIR/comparator.json"
  fi
  if [[ ! -f "$UPSTREAM_DIR/export-targets.txt" ]]; then
    cp "$COMPARATOR_SPEC_DIR/export-targets.txt" "$UPSTREAM_DIR/export-targets.txt"
  fi
}
