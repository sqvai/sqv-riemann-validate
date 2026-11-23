#!/usr/bin/env bash
# Emit a uair-forge-counted-v2 receipt from evidence counted-self-check (in-process count).
# Prints sha256 on stdout. Pattern from refactorx3 run-sqv-ri-uair-forge.sh.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export UAIR_FORGE_WORKSPACE="$ROOT"
UF="${UAIR_FORGE:-$HOME/.local/bin/uair-forge}"
RECEIPTS="$ROOT/.uair-forge/counted-receipts"
mkdir -p "$RECEIPTS"
python3 - "$UF" "$RECEIPTS" <<'PY'
import hashlib, json, struct, subprocess, sys
from pathlib import Path

uair, out_dir = sys.argv[1], Path(sys.argv[2])
out_dir.mkdir(parents=True, exist_ok=True)

def prompt_sha256(prompt: str) -> str:
    return hashlib.sha256(prompt.encode()).hexdigest()

def digest(model_id, prompt_sha, seed, hardware, tokens, elapsed_ns) -> str:
    h = hashlib.sha256()
    h.update(b"uair-forge-counted-v2\n")
    h.update(model_id.encode()); h.update(b"\n")
    h.update(prompt_sha.encode()); h.update(b"\n")
    h.update(struct.pack("<Q", seed))
    h.update(hardware.encode()); h.update(b"\n")
    h.update(struct.pack("<Q", tokens))
    h.update(struct.pack("<Q", elapsed_ns))
    return h.hexdigest()

raw = subprocess.check_output([uair, "evidence", "counted-self-check"], text=True)
j = json.loads(raw)
model_id = "uair-forge-internal-loop"
ps = prompt_sha256("uair-forge-counted-self-check")
seed = 0
hardware = "in-process"
tokens = int(j["tokens"])
elapsed_ns = int(j["elapsed_ns"])
sha = digest(model_id, ps, seed, hardware, tokens, elapsed_ns)
if sha.lower() != str(j["sha256"]).lower():
    raise SystemExit(f"digest mismatch cli={j['sha256']} py={sha}")
body = {
    "schema": "uair-forge-counted-v2",
    "model_id": model_id,
    "prompt_sha256": ps,
    "seed": seed,
    "hardware": hardware,
    "tokens": tokens,
    "elapsed_ns": elapsed_ns,
    "sha256": sha,
}
path = out_dir / f"{sha}.json"
path.write_text(json.dumps(body, indent=2) + "\n")
print(sha)
PY
