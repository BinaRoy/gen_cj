# Collaboration Plan

## Milestone
P0 real chat loop:
- App UI -> app domain/network -> backend `/v1/chat` -> OpenAI -> app UI.

## Acceptance Criteria
- No hardcoded demo reply path in entry flow.
- Conversation continuity and isolation verified.
- Error categories and retry behavior are user-visible and test-covered.
- Runtime secrets/config managed via environment, not committed values.

## Risks
- Parallel sessions editing overlapping files can invalidate review evidence.
- Runtime transport differences (CLI vs device) can hide integration issues.
- Placeholder conversation id in backend can break history continuity.

## Not In Scope
- Login/account/auth flows.
- Multimodal capabilities.
- Multi-model marketplace and prompt orchestration.

## Source Of Truth
- Tasks: `docs/tasks.md`
- Decisions: `docs/decisions/`
- Governance: `docs/governance/README.md`
- Pipeline: `docs/pipeline/multi-role-pipeline.md`

## First Phase Delivery Gate
- Lint/format gate: `bash scripts/lint.sh`
- Smoke test gate: `bash scripts/test.sh`
- Reviewer gate: blocking/non-blocking checklist with pass/fail decision
