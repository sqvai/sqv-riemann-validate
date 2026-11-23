#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_bin git
require_bin cargo

if [[ ! -x "$AUDIT_BIN" ]]; then
  cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml"
fi

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
  mkdir -p "$(dirname "$UPSTREAM_DIR")"
  # Shallow clone of the pinned SHA (full history is unnecessary for qualification).
  git clone --filter=blob:none --no-checkout "$UPSTREAM_URL" "$UPSTREAM_DIR"
  git -C "$UPSTREAM_DIR" fetch --depth 1 origin "$UPSTREAM_REF"
  git -C "$UPSTREAM_DIR" checkout "$UPSTREAM_REF"
else
  git -C "$UPSTREAM_DIR" fetch --depth 1 origin "$UPSTREAM_REF"
  # UPSTREAM_REF should be an immutable SHA for qualification runs.
  git -C "$UPSTREAM_DIR" checkout "$UPSTREAM_REF"
fi

mkdir -p "$UPSTREAM_DIR/.git/info"
grep -qxF ".lake" "$UPSTREAM_DIR/.git/info/exclude" 2>/dev/null || echo ".lake" >> "$UPSTREAM_DIR/.git/info/exclude"
grep -qxF "SQV_*.lean" "$UPSTREAM_DIR/.git/info/exclude" 2>/dev/null || echo "SQV_*.lean" >> "$UPSTREAM_DIR/.git/info/exclude"
grep -qxF "src/Challenge.lean" "$UPSTREAM_DIR/.git/info/exclude" 2>/dev/null || echo "src/Challenge.lean" >> "$UPSTREAM_DIR/.git/info/exclude"
grep -qxF "comparator.json" "$UPSTREAM_DIR/.git/info/exclude" 2>/dev/null || echo "comparator.json" >> "$UPSTREAM_DIR/.git/info/exclude"
grep -qxF "export-targets.txt" "$UPSTREAM_DIR/.git/info/exclude" 2>/dev/null || echo "export-targets.txt" >> "$UPSTREAM_DIR/.git/info/exclude"

ensure_challenge_overlay

echo "upstream_sha=$(git -C "$UPSTREAM_DIR" rev-parse HEAD)"
echo "IMPORTANT: keep UPSTREAM_REF in config/upstream.env as an immutable SHA for qualification."
echo "paper_sha256 expected=$PAPER_SHA256 path=$REPO_ROOT/$PAPER_PATH"
