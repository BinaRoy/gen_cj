# Task Board

## Rules
- Task size target: 0.5 to 1 day.
- One owner role per task at a time.
- Completion requires reviewer confirmation with command evidence.
- Every handoff uses `docs/pipeline/role-handoff-template.md`.

## Active

### EX1-P0-1 App real-path wiring (Executor-1)
- Role: Implementer
- Scope: app-side default gateway/transport integration.
- Files: `app/src/network/**`, `app/src/ui/index.cj`, `app/src/ui/DefaultGatewayFactory.cj`, `app/test/**`
- Acceptance:
  - default entry flow does not use demo reply generator.
  - tests prove reply content comes from transport/backend path.
- Status: in progress
- Required handoff: commit hash + modified files + exact commands + TOTAL/PASSED/FAILED

### EX2-P0-2 Backend conversation id correctness (Executor-2)
- Role: Implementer
- Scope: remove placeholder conversation id behavior.
- Files: `backend/src/routes/chat.ts`, related backend tests.
- Acceptance:
  - response `conversation_id` is not fixed placeholder.
  - contract tests and chat service tests pass.
- Status: pending reviewer of first patch
- Required handoff: commit hash + modified files + exact commands + TOTAL/PASSED/FAILED

### QA-P0-SMOKE Core smoke and failure reproduction
- Role: QA
- Scope: run `scripts/test.sh`; if fail, provide reproducible steps and raw logs.
- Files: `docs/process/compile-logs/**`, test files only when needed.
- Acceptance:
  - every failure has exact repro commands
  - logs archived with timestamped filenames
- Status: ready

### REV-P0-GATE Review gate
- Role: Reviewer
- Scope: review EX1/EX2/QA outputs and issue blocking/non-blocking decisions.
- Files: review comments and gate record in process log.
- Acceptance:
  - blocking vs non-blocking clearly separated
  - pass/fail decision tied to evidence
- Status: ready

### REL-P0-CUT Local release cut
- Role: Release
- Scope: tag verified snapshot and record rollback point.
- Files: `docs/process/2026-02-11-project-log.md`
- Acceptance:
  - tag created from verified commit
  - rollback point recorded
- Status: pending QA + Reviewer pass

## Next

### EXB-P0-3 Error/retry UX
- Role: Implementer
- Scope: map timeout/429/5xx/network to explicit UI state and retry path.
- Status: todo

### EXB-P0-4 Config/secret hardening
- Role: Implementer
- Scope: environment-driven config and no secret leakage in logs.
- Status: todo
