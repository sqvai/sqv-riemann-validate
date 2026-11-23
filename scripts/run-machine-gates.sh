#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/v0-repro.sh"
"$DIR/v1-kernel.sh"
"$DIR/v2-comparator.sh"
