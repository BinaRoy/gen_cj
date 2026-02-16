#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${TASK_ID:-manual-task}"
MAX_ITERS="${MAX_ITERS:-3}"
AUTO_RELEASE="${AUTO_RELEASE:-false}"
ARTIFACT_ROOT="${ARTIFACT_ROOT:-artifacts/agent-runs}"
RUN_ID="${RUN_ID:-$(date +%Y%m%d-%H%M%S)-${TASK_ID}}"
RUN_DIR="${ARTIFACT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

log "orchestrator" "task=${TASK_ID}, max_iters=${MAX_ITERS}, run_dir=${RUN_DIR}"

bash scripts/agent/planner.sh "${TASK_ID}" "1" "${RUN_DIR}"

success=false
for i in $(seq 1 "${MAX_ITERS}"); do
  log "orchestrator" "iteration ${i}/${MAX_ITERS}"

  bash scripts/agent/implementer.sh "${TASK_ID}" "${i}" "${RUN_DIR}/reviewer_feedback.md" "${RUN_DIR}"

  if bash scripts/agent/qa.sh "${TASK_ID}" "${i}" "${RUN_DIR}"; then
    if bash scripts/agent/reviewer.sh "${TASK_ID}" "${i}" "${RUN_DIR}"; then
      success=true
      log "orchestrator" "reviewer pass on iteration ${i}"
      break
    fi
  else
    # QA failed. Generate reviewer feedback for next iteration.
    bash scripts/agent/reviewer.sh "${TASK_ID}" "${i}" "${RUN_DIR}" || true
  fi
done

if [[ "${success}" != "true" ]]; then
  log "orchestrator" "failed after ${MAX_ITERS} iteration(s)"
  {
    echo "RUN_STATUS=fail"
    echo "RUN_DIR=${RUN_DIR}"
    echo "TASK_ID=${TASK_ID}"
  } > "${RUN_DIR}/run_status.env"
  exit 1
fi

if [[ "${AUTO_RELEASE}" == "true" ]]; then
  bash scripts/agent/release.sh "${TASK_ID}" "${RUN_DIR}"
fi

{
  echo "RUN_STATUS=pass"
  echo "RUN_DIR=${RUN_DIR}"
  echo "TASK_ID=${TASK_ID}"
} > "${RUN_DIR}/run_status.env"

log "orchestrator" "success"
