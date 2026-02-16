#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${1:-manual-task}"
ITERATION="${2:-1}"
OUT_DIR="${3:-artifacts/agent-runs/manual}"
mkdir -p "${OUT_DIR}"

RESULT_FILE="${OUT_DIR}/qa_result.env"
DECISION_FILE="${OUT_DIR}/reviewer_decision.md"
FEEDBACK_FILE="${OUT_DIR}/reviewer_feedback.md"

if run_optional_role_cmd "reviewer" "${AGENT_REVIEWER_CMD:-}"; then
  log "reviewer" "external command finished"
  exit 0
fi

ensure_file "${RESULT_FILE}"
source "${RESULT_FILE}"

if [[ "${QA_STATUS}" == "pass" ]]; then
  {
    echo "# Reviewer Decision"
    echo "- task_id: ${TASK_ID}"
    echo "- iteration: ${ITERATION}"
    echo "- gate: PASS"
    echo "- blocking: none"
    echo "- non-blocking: none"
    echo "- qa_summary: ${QA_SUMMARY}"
  } > "${DECISION_FILE}"
  log "reviewer" "gate pass"
  exit 0
fi

{
  echo "# Reviewer Decision"
  echo "- task_id: ${TASK_ID}"
  echo "- iteration: ${ITERATION}"
  echo "- gate: FAIL"
  echo "- blocking:"
  echo "  - qa check failed"
  echo "- non-blocking:"
  echo "  - include extra assertions for failure reproduction"
  echo "- qa_summary: ${QA_SUMMARY}"
} > "${DECISION_FILE}"

{
  echo "# Reviewer Feedback For Implementer"
  echo "- resolve qa failure first"
  echo "- run exact commands: bash scripts/lint.sh && bash scripts/test.sh"
  echo "- attach updated logs under docs/process/compile-logs/"
} > "${FEEDBACK_FILE}"

log "reviewer" "gate fail"
exit 1
