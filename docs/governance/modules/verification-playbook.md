# Verification Playbook / 验证流程

## Verification Layers
1. unit tests
2. integration tests
3. build/package verification
4. deployment/smoke checks (if in scope)

## Output Standard
- Must provide exact command lines.
- Must provide TOTAL/PASSED/FAILED summary.
- Must provide blocker/risk statement.

## Log Policy
- Store raw logs under `docs/process/compile-logs/` with timestamped names.
- Prefer preserving full command + output.

## Hard Gate
- If command evidence or pass/fail summary is missing, status is `NOT COMPLETE`.
