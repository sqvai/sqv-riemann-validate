#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
export PATH="$HOME/.elan/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
cd "$ROOT"

echo "[rh26-init] workspace=$ROOT"
./scripts/preflight.sh
test -d upstream/riemann-hypothesis/.git || ./scripts/bootstrap.sh
git -C upstream/riemann-hypothesis rev-parse HEAD
./target/release/rh-audit status receipts || cargo run --release --quiet -- status receipts
echo "[rh26-init] ready"
