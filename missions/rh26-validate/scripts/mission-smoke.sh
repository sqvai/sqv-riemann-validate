#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
cd "$ROOT"
./scripts/preflight.sh
test -f papers/zeta-paper.pdf
test -f specs/paper_bridge/paper-lean-map.md
test -x target/release/rh-audit || cargo build --release
./target/release/rh-audit status receipts
echo "mission-smoke: OK"
