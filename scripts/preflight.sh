#!/usr/bin/env bash
set -u
source "$(dirname "$0")/common.sh"
failed=0
check() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'OK      %-14s %s\n' "$1" "$(command -v "$1")"
  else
    printf 'MISSING %-14s\n' "$1"
    failed=1
  fi
}
check git
check cargo
check rustc
check elan
check lean
check lake
check sha256sum
printf '\nV2 only:\n'
check landrun
check lean4export
check nanoda_bin
printf '\nPaper pin:\n'
if [[ -f "$REPO_ROOT/$PAPER_PATH" ]]; then
  actual="$(sha256sum "$REPO_ROOT/$PAPER_PATH" | awk '{print $1}')"
  if [[ "$actual" == "$PAPER_SHA256" ]]; then
    printf 'OK      paper         %s\n' "$actual"
  else
    printf 'MISMATCH paper       got %s expected %s\n' "$actual" "$PAPER_SHA256"
    failed=1
  fi
else
  printf 'MISSING paper         %s\n' "$REPO_ROOT/$PAPER_PATH"
  failed=1
fi
exit "$failed"
