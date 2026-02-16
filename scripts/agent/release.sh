#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"
source scripts/agent/common.sh

TASK_ID="${1:-manual-task}"
OUT_DIR="${2:-artifacts/agent-runs/manual}"
mkdir -p "${OUT_DIR}"

if run_optional_role_cmd "release" "${AGENT_RELEASE_CMD:-}"; then
  log "release" "external command finished"
  exit 0
fi

TAG_NAME="auto-${TASK_ID}-$(date +%Y%m%d-%H%M%S)"
{
  echo "# Release Output"
  echo "- task_id: ${TASK_ID}"
  echo "- suggested_tag: ${TAG_NAME}"
  echo "- rollback_point: $(git rev-parse --short HEAD)"
  echo "- note: AUTO_PUSH_TAG is disabled by default"
} > "${OUT_DIR}/release_output.md"

if [[ "${AUTO_PUSH_TAG:-false}" == "true" ]]; then
  git tag "${TAG_NAME}"
  git push origin "${TAG_NAME}"
  log "release" "tag pushed: ${TAG_NAME}"
else
  log "release" "skipped tag push (set AUTO_PUSH_TAG=true to enable)"
fi
