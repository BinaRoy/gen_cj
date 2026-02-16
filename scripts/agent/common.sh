#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[agent][%s] %s\n' "$1" "$2"
}

ensure_file() {
  local f="$1"
  [[ -f "$f" ]] || {
    echo "missing file: $f" >&2
    return 1
  }
}

run_optional_role_cmd() {
  local role="$1"
  local cmd="${2:-}"
  if [[ -z "${cmd}" ]]; then
    return 10
  fi
  log "${role}" "running external role command"
  bash -lc "${cmd}"
  return $?
}
