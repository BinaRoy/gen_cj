# P0 Real Chat Development Flow (2026-02-13)

## Goal
- Move from baseline demo behavior to a real, testable chat loop:
- `App UI -> App Domain -> Backend /v1/chat -> OpenAI -> App UI`.

## Scope
- In Scope:
- P0-1 real request path on app side (remove hardcoded demo reply path).
- P0-2 conversation continuity and isolation correctness.
- P0-3 error handling and retry UX baseline (timeout/429/5xx/network).
- P0-4 runtime config and secret safety baseline.
- P0-5 regression evidence and reviewer gate closeout.
- Out of Scope:
- Login/account system.
- Multimodal input/output.
- Model marketplace and advanced prompt orchestration.

## Task Sequence (Strict)
1. P0-1 Real path wiring
2. P0-2 Conversation correctness
3. P0-3 Error/retry UX
4. P0-4 Config/security
5. P0-5 Verification and review handoff

## Hard Gates
- No completion claim without command evidence.
- No cross-task expansion without explicit user approval.
- No task completion without reviewer confirmation.
- App-side implementation remains Pure Cangjie unless approved otherwise.

## Acceptance Criteria by Task

### P0-1 Real path wiring
- Entry path no longer depends on hardcoded `Echo/Demo` reply generator.
- Chat result content comes from injected transport/backend response path.
- Preserve testability through transport abstraction.

### P0-2 Conversation correctness
- No cross-conversation message contamination.
- Restart can restore latest transcript for existing conversation id.

### P0-3 Error/retry UX
- User-visible states exist for network, rate-limit, and server failures.
- Retry action can recover without app restart.

### P0-4 Config/security
- Base URL and runtime endpoint are configurable.
- Secret values are never committed or printed in logs.

### P0-5 Verification/review
- Provide exact commands and raw logs under `docs/process/compile-logs/`.
- Provide `TOTAL/PASSED/FAILED` summary and blocker/risk statement.
- Provide 4-item review handoff template fields.

## Required Evidence Template (Each Checkpoint)
- Task commit hash
- Modified file list
- Exact test/verify command(s)
- Test summary (TOTAL/PASSED/FAILED)

## Session Handover Requirements
- branch
- latest commit hash
- completed items
- pending items
- key files touched
- latest test command(s)
- latest test summary
- risks/blockers
- rollback point
- next exact command(s)

## Cangjie References Used
- `docs/governance/references/reference-index.md` (F: project internal rules)
- `docs/references/cangjie_docs/docs/dev-guide/source_zh_cn/Net/net_http.md` (HTTP programming and client builder)
