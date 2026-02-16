# Task Board

## Rules
- Task size target: 0.5 to 1 day.
- One owner role per task at a time.
- Completion requires reviewer confirmation with command evidence.

## Active

### EX1-P0-1 App real-path wiring (Executor-1)
- Scope: app-side default gateway/transport integration.
- Files: `app/src/network/**`, `app/src/ui/index.cj`, `app/src/ui/DefaultGatewayFactory.cj`, `app/test/**`
- Acceptance:
  - default entry flow does not use demo reply generator.
  - tests prove reply content comes from transport/backend path.
- Status: in progress

### EX2-P0-2 Backend conversation id correctness (Executor-2)
- Scope: remove placeholder conversation id behavior.
- Files: `backend/src/routes/chat.ts`, related backend tests.
- Acceptance:
  - response `conversation_id` is not fixed placeholder.
  - contract tests and chat service tests pass.
- Status: pending reviewer of first patch

## Next

### EXB-P0-3 Error/retry UX
- Scope: map timeout/429/5xx/network to explicit UI state and retry path.
- Status: todo

### EXB-P0-4 Config/secret hardening
- Scope: environment-driven config and no secret leakage in logs.
- Status: todo
