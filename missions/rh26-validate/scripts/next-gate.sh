#!/usr/bin/env bash
# Prints the next unfinished gate seed for hyperagents2 graph-run --advance-cmd.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"
status_out="$(./target/release/rh-audit status receipts 2>/dev/null || true)"
has() { grep -q "^$1[[:space:]]\+PASS" <<<"$status_out"; }

if ! has RH26-V4-PAPER; then echo RH26-V4-PAPER; exit 0; fi
if ! has RH26-V0-CACHE || ! has RH26-V0-BUILD; then echo RH26-V0; exit 0; fi
if ! has RH26-V1-AXIOMS; then echo RH26-V1; exit 0; fi
if ! has RH26-V2-COMPARATOR; then echo RH26-V2; exit 0; fi
if ! has RH26-V3-CLAY-BRIDGE; then echo RH26-V3; exit 0; fi
echo STOP
