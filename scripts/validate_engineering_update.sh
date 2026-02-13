#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <update_markdown_file>"
  exit 2
fi

f="$1"
if [[ ! -f "$f" ]]; then
  echo "NOT COMPLETE: file not found: $f"
  exit 2
fi

required_headers=(
  "## Task commit hash"
  "## Modified file list"
  "## Exact test/verify command(s)"
  "## Test summary (TOTAL/PASSED/FAILED)"
)

missing=0
for h in "${required_headers[@]}"; do
  if ! rg -F -q "$h" "$f"; then
    echo "NOT COMPLETE: missing section -> $h"
    missing=1
  fi
done

if ! rg -q "TOTAL.+PASSED.+FAILED" "$f"; then
  echo "NOT COMPLETE: missing TOTAL/PASSED/FAILED content"
  missing=1
fi

if [[ $missing -ne 0 ]]; then
  exit 1
fi

echo "PASS: update file matches hard-gate template requirements"
