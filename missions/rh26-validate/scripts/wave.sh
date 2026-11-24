#!/usr/bin/env bash
# Hyperagents2 / Harness++ wave: run next gate, record PASS if receipt exists.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
export PATH="$HOME/.elan/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
cd "$ROOT"
UF="${UAIR_FORGE:-$HOME/.local/bin/uair-forge}"
PROGRESS="$ROOT/missions/rh26-validate/skynet-agent-progress.txt"
LOCK="$ROOT/missions/rh26-validate/.wave.lock"

# Prevent concurrent make wave + make graph-run (disk/Lean corruption risk).
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "[wave] another wave/graph-run holds $LOCK — abort" >&2
  exit 75
fi

avail_kb="$(df -Pk / | awk 'NR==2{print $4}')"
if [[ "${avail_kb:-0}" -lt 10485760 ]]; then
  echo "[wave] need >=10GiB free on / (have ${avail_kb} KiB) before Lean gates" >&2
  exit 76
fi

GATE="$(./missions/rh26-validate/scripts/next-gate.sh)"
echo "[wave] next=$GATE" | tee -a "$PROGRESS"
if [[ "$GATE" == "STOP" ]]; then
  echo "[wave] complete" | tee -a "$PROGRESS"
  exit 0
fi

set +e
./missions/rh26-validate/scripts/run-gate.sh "$GATE"
rc=$?
set -e

parent_for_gate() {
  case "$1" in
    RH26-V4-PAPER) echo "$ROOT/missions/rh26-validate/.nodes/RH26-V4-PAPER" ;;
    RH26-V0) echo "$ROOT/missions/rh26-validate/.nodes/RH26-V0" ;;
    RH26-V1) echo "$ROOT/missions/rh26-validate/.nodes/RH26-V1" ;;
    RH26-V2) echo "$ROOT/missions/rh26-validate/.nodes/RH26-V2" ;;
    RH26-V3) echo "$ROOT/missions/rh26-validate/.nodes/RH26-V3" ;;
    *) echo "" ;;
  esac
}
PARENT_FILE="$(parent_for_gate "$GATE")"

record_existing_passes() {
  local gate_parent="$1"
  local r
  for r in RH26-V4-PAPER RH26-V0-CACHE RH26-V0-BUILD RH26-V1-AXIOMS RH26-V2-COMPARATOR RH26-V3-CLAY-BRIDGE; do
    if [[ -f "receipts/$r.json" ]] && grep -q '"status": "PASS"' "receipts/$r.json"; then
      local p="$gate_parent"
      case "$r" in
        RH26-V4-PAPER) p="$(parent_for_gate RH26-V4-PAPER)" ;;
        RH26-V0-*) p="$(parent_for_gate RH26-V0)" ;;
        RH26-V1-*) p="$(parent_for_gate RH26-V1)" ;;
        RH26-V2-*) p="$(parent_for_gate RH26-V2)" ;;
        RH26-V3-*) p="$(parent_for_gate RH26-V3)" ;;
      esac
      if [[ -n "$p" && -f "$p" ]]; then
        ./missions/rh26-validate/scripts/record-pass.sh "$r" "$(cat "$p")" || true
      fi
    fi
  done
}

if [[ $rc -eq 0 ]]; then
  record_existing_passes "$PARENT_FILE"
  echo "[wave] gate=$GATE rc=0" | tee -a "$PROGRESS"
else
  echo "[wave] gate=$GATE rc=$rc (HOLD — see evidence/)" | tee -a "$PROGRESS"
  "$UF" self-improve graph add-node eval_outcome "$GATE FAIL/HOLD" \
    --detail "work_cmd exit $rc; inspect evidence/ and receipts/" >/dev/null || true
fi
exit "$rc"
