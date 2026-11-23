#!/usr/bin/env bash
# Runs one validation gate. Used as hyperagents2 graph-run --work-cmd.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
export PATH="$HOME/.elan/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
cd "$ROOT"
GATE="${1:-$(./missions/rh26-validate/scripts/next-gate.sh)}"
PROGRESS="$ROOT/missions/rh26-validate/skynet-agent-progress.txt"
{
  echo "==== $(date -u +%Y-%m-%dT%H:%M:%SZ) gate=$GATE ===="
} | tee -a "$PROGRESS"

case "$GATE" in
  STOP)
    echo "all machine/paper gates have PASS receipts" | tee -a "$PROGRESS"
    exit 0
    ;;
  RH26-V4-PAPER|V4)
    make v4
    ;;
  RH26-V0|V0)
    make v0
    ;;
  RH26-V1|V1)
    make v1
    ;;
  RH26-V2|V2)
    make v2
    ;;
  RH26-V3|V3)
    make v3
    ;;
  *)
    echo "unknown gate: $GATE" >&2
    exit 2
    ;;
esac

./target/release/rh-audit status receipts | tee -a "$PROGRESS"
