#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "[lint] required collaboration files"
required_files=(
  "README.md"
  ".env.example"
  "docs/plan.md"
  "docs/tasks.md"
  "docs/decisions/ADR-0001-collaboration-interface.md"
  "docs/pipeline/multi-role-pipeline.md"
)

for f in "${required_files[@]}"; do
  [[ -f "${f}" ]] || { echo "[lint][FAIL] missing ${f}"; exit 1; }
done

echo "[lint] env files are not tracked"
if git ls-files | rg -q "^\\.env$"; then
  echo "[lint][FAIL] .env is tracked by git"
  exit 1
fi

echo "[lint] basic secret token scan"
# Scan tracked files only, excluding third-party reference mirrors.
if git ls-files | rg -v "^docs/references/" | xargs rg -n "sk-[A-Za-z0-9]{20,}" >/tmp/gen_cangjie_secret_scan.txt; then
  echo "[lint][FAIL] possible secret token pattern found"
  cat /tmp/gen_cangjie_secret_scan.txt
  exit 1
fi

echo "[lint] shell scripts are executable"
for s in scripts/dev.sh scripts/test.sh scripts/lint.sh; do
  [[ -x "${s}" ]] || { echo "[lint][FAIL] ${s} is not executable"; exit 1; }
done

echo "[lint] PASS"
