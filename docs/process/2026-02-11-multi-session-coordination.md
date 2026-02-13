# Multi-Session Coordination Protocol

## Purpose
- Keep context consistent across parallel sessions.
- Prevent decision drift and duplicate/conflicting changes.
- Enforce review gates before task completion claims.

## Single Source of Truth
- Master plan: `docs/plans/2026-02-11-cangjie-ai-chat-app-implementation-plan.md`
- Master log: `docs/process/2026-02-11-project-log.md`
- This protocol: `docs/process/2026-02-11-multi-session-coordination.md`
- Governance root: `docs/governance/README.md`
- Global hard rules: `docs/governance/global-rules.md`

## Session Isolation Rules
- One task at a time per session from the implementation plan.
- Do not edit files owned by another active task/session.
- Any new decision must be written to project log before coding continues.
- No task may be marked done without test evidence and file-level change summary.
- Active worktrees for this project must be created under repository root `.worktrees/`.
- Do not create new project worktrees under `/tmp` going forward.
- Existing `/tmp` worktrees have been migrated; active paths are:
- `/.worktrees/task1-docs-bootstrap` (branch `task1/docs-bootstrap`)
- `/.worktrees/task2-backend-contracts` (branch `task2/backend-contracts`)

## Sync Message Template (for every checkpoint)
- Session ID:
- Task ID:
- Branch/Commit:
- Files changed:
- Commands run:
- Test results:
- Open risks/blockers:
- Next planned step:

## Review Handoff (Required in every task feedback)
- Task commit hash:
- Modified file list:
- Exact `cjc --test` command(s):
- Test summary (TOTAL / PASSED / FAILED):

## Review Gate (Lead Reviewer Session)
- Reviewer checks:
  - Scope match with selected task.
  - Pure Cangjie requirement preserved on app side.
  - API contract compatibility preserved.
  - Verification evidence provided (not claimed).
  - Docs updated (`project-log` verification + change notes).
- Only after pass: task status can move to "completed".

## Status Board
- Task 1: pending
- Task 2: completed (reviewed, cherry-picked to `main` as `9822c80`)
- Task 3: completed (reviewed, cherry-picked to `main` as `969f6a6` + `b903408`)
- Task 4: completed (reviewed, cherry-picked to `main` as `a8b338b` + `ca39650`)
- Task 5: completed (reviewed, cherry-picked to `main` as `e6fad7d` + `85e2d9b` + `4139a46` + `46aeabb`)
- Task 6: completed (reviewed, cherry-picked to `main` as `fee2c93` + `190b29d`)
- Task 7: completed (reviewed, cherry-picked to `main` as `0c7a8f3` + `f4103c6`)
- Task 8: completed (reviewed, cherry-picked to `main` as `b562058`)

## Escalation Rules
- If two sessions touch overlapping files: stop both and reassign ownership.
- If verification fails: rollback at task scope and reopen task.
- If requirement conflict appears: record conflict in project log and wait for user decision.
