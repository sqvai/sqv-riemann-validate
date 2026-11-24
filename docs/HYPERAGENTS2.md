# Hyperagents2 / Harness++ operator loop (RH26)

Workspace: this repo (`UAIR_FORGE_WORKSPACE` = repo root).

## Surfaces

| Path | Role |
|---|---|
| `missions/rh26-validate/` | Long-running mission (feature list, init, smoke, waves) |
| `harness/rh26/` | Harness++ package (`harness.yaml`, prompts, guardrails) |
| `.uair-forge/self-improve/` | Self-model, improvement graph, verdicts, experience |
| `.uair-forge/counted-receipts/` | Counted-v2 receipts for `harness-run` |

## Commands

```bash
export UAIR_FORGE_WORKSPACE=/path/to/sqv-riemann-validate
export PATH="$HOME/.local/bin:$PATH"

# Status
uair-forge self-improve hyperagents2 status
uair-forge self-improve hyperagents2 long-running-mission-check --dir ./missions/rh26-validate --enforce

# Mission smoke / init
./missions/rh26-validate/init.sh
./missions/rh26-validate/scripts/mission-smoke.sh

# One wave (runs next unfinished gate, records PASS via counted receipt)
./missions/rh26-validate/scripts/wave.sh

# Graph-backed multi-wave (Harness++ hook)
# Do NOT run `make wave` and `make graph-run` at the same time.
uair-forge self-improve hyperagents2 graph-run \
  --seed RH26-V0 \
  --max-waves 5 \
  --promotion hold \
  --failure-typing \
  --work-cmd './missions/rh26-validate/scripts/wave.sh' \
  --advance-cmd './missions/rh26-validate/scripts/next-gate.sh'
```

## Disk / concurrency

- `wave.sh` takes `missions/rh26-validate/.wave.lock` (flock) and refuses to start if `/` has &lt;10 GiB free.
- Full `lake build Main` needs far more than 10 GiB (`.lake` alone can exceed that); free space before V0-BUILD.
- Prefer **either** `make wave` **or** `make graph-run`, never both.

## Gate order

`RH26-V4-PAPER` → `RH26-V0` → `RH26-V1` → `RH26-V2` → `RH26-V3` → `STOP`

Promotion remains `hold` until machine gates have PASS receipts. Clay institutional acceptance is out of scope.
