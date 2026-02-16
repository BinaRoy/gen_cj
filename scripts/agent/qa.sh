#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${1:-manual-task}"
ITERATION="${2:-1}"
OUT_DIR="${3:-artifacts/agent-runs/manual}"
mkdir -p "${OUT_DIR}"

LOG_FILE="${OUT_DIR}/qa-test-iteration-${ITERATION}.log"
RESULT_FILE="${OUT_DIR}/qa_result.env"

if run_optional_role_cmd "qa" "${AGENT_QA_CMD:-}"; then
  log "qa" "external command finished"
  {
    echo "QA_STATUS=pass"
    echo "QA_SUMMARY='external qa command succeeded'"
  } > "${RESULT_FILE}"
  exit 0
fi

set +e
bash scripts/test.sh >"${LOG_FILE}" 2>&1
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
  {
    echo "QA_STATUS=pass"
    echo "QA_SUMMARY='scripts/test.sh passed'"
  } > "${RESULT_FILE}"
  log "qa" "pass"
  exit 0
fi

{
  echo "QA_STATUS=fail"
  echo "QA_SUMMARY='scripts/test.sh failed'"
} > "${RESULT_FILE}"
log "qa" "failed, see ${LOG_FILE}"
exit 1
