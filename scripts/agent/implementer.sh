#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${1:-manual-task}"
ITERATION="${2:-1}"
FEEDBACK_FILE="${3:-}"
OUT_DIR="${4:-artifacts/agent-runs/manual}"
mkdir -p "${OUT_DIR}"

if [[ -n "${FEEDBACK_FILE}" && -f "${FEEDBACK_FILE}" ]]; then
  cp "${FEEDBACK_FILE}" "${OUT_DIR}/implementer_input_feedback.md"
fi

if run_optional_role_cmd "implementer" "${AGENT_IMPLEMENTER_CMD:-}"; then
  log "implementer" "external command finished"
else
  log "implementer" "no AGENT_IMPLEMENTER_CMD set, running fallback gate checks"
  bash scripts/lint.sh
  bash scripts/test.sh
  {
    echo "# Implementer Output"
    echo "- task_id: ${TASK_ID}"
    echo "- iteration: ${ITERATION}"
    echo "- mode: fallback"
    echo "- note: no external coding agent command configured"
    echo "- checks: lint+test passed"
  } > "${OUT_DIR}/implementer_output.md"
fi
