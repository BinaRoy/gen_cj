#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${1:-manual-task}"
ITERATION="${2:-1}"
OUT_DIR="${3:-artifacts/agent-runs/manual}"
mkdir -p "${OUT_DIR}"

if run_optional_role_cmd "planner" "${AGENT_PLANNER_CMD:-}"; then
  log "planner" "external command finished"
else
  ensure_file "docs/plan.md"
  ensure_file "docs/tasks.md"
  {
    echo "# Planner Output"
    echo "- task_id: ${TASK_ID}"
    echo "- iteration: ${ITERATION}"
    echo "- status: using repository plan/task docs as source of truth"
    echo "- files:"
    echo "  - docs/plan.md"
    echo "  - docs/tasks.md"
  } > "${OUT_DIR}/planner_output.md"
  log "planner" "wrote ${OUT_DIR}/planner_output.md"
fi
