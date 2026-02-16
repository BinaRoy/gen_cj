#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ -d node_modules/tsx ]]; then
  echo "[dev] dependencies already present, skip npm ci"
else
  echo "[dev] ensuring node dependencies"
  npm ci
fi

echo "[dev] running backend contract smoke test"
npm test -- backend/test/routes.contract.test.ts

echo "[dev] done"
echo "Next:"
echo "  1) bash scripts/test.sh"
echo "  2) follow docs/tasks.md for active executor tasks"
