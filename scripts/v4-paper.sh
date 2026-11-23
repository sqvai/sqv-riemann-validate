#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ -x "$AUDIT_BIN" ]] || cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
mkdir -p "$EVIDENCE_DIR/RH26-V4-PAPER"
: > "$EVIDENCE_DIR/RH26-V4-PAPER/stdout.log"
: > "$EVIDENCE_DIR/RH26-V4-PAPER/stderr.log"

paper="$REPO_ROOT/$PAPER_PATH"
[[ -f "$paper" ]] || { echo "missing paper at $paper" >&2; exit 1; }
actual="$(sha256sum "$paper" | awk '{print $1}')"
if [[ "$actual" != "$PAPER_SHA256" ]]; then
  echo "paper SHA-256 mismatch: got $actual expected $PAPER_SHA256" >&2
  exit 1
fi

mapfile="$REPO_ROOT/specs/paper_bridge/paper-lean-map.md"
[[ -f "$mapfile" ]] || { echo "missing paper map $mapfile" >&2; exit 1; }

missing=0
while IFS= read -r lean_path; do
  [[ -z "$lean_path" ]] && continue
  if [[ ! -f "$UPSTREAM_DIR/$lean_path" ]]; then
    echo "MISSING upstream Lean path: $lean_path" | tee -a "$EVIDENCE_DIR/RH26-V4-PAPER/stderr.log"
    missing=1
  else
    echo "OK $lean_path" >> "$EVIDENCE_DIR/RH26-V4-PAPER/stdout.log"
  fi
done < <(grep -oE '`src/[^`]+`' "$mapfile" | tr -d '`' | sort -u)

{
  echo "paper_url=$PAPER_URL"
  echo "paper_sha256=$actual"
  echo "map=$mapfile"
  echo "upstream_sha=$(git -C "$UPSTREAM_DIR" rev-parse HEAD 2>/dev/null || true)"
} >> "$EVIDENCE_DIR/RH26-V4-PAPER/stdout.log"

if [[ "$missing" -ne 0 ]]; then
  "$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V4-PAPER "$REPO_ROOT" false
  exit 1
fi

"$AUDIT_BIN" run-command "$RECEIPT_DIR" RH26-V4-PAPER "$REPO_ROOT" \
  bash -lc "echo PAPER_ALIGNMENT_STRUCTURAL_PASS"
