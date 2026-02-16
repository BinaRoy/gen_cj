# Agent Orchestrator

## Purpose
- Run a full role pipeline automatically: Planner -> Implementer -> QA -> Reviewer -> Release (optional).
- Keep role outputs in files and logs, not chat context.

## Workflow
- GitHub Actions workflow: `.github/workflows/agent-orchestrator.yml`
- Trigger: `workflow_dispatch`
- Inputs:
  - `task_id`
  - `max_iterations`
  - `auto_release`

## Role Runtime
- Orchestrator entrypoint: `scripts/agent/orchestrate.sh`
- Role scripts:
  - `scripts/agent/planner.sh`
  - `scripts/agent/implementer.sh`
  - `scripts/agent/qa.sh`
  - `scripts/agent/reviewer.sh`
  - `scripts/agent/release.sh`

## External Agent Hooks
- Configure role-specific commands via repository secrets:
  - `AGENT_PLANNER_CMD`
  - `AGENT_IMPLEMENTER_CMD`
  - `AGENT_QA_CMD`
  - `AGENT_REVIEWER_CMD`
  - `AGENT_RELEASE_CMD`
- If a role command is not set, fallback logic is used.

## Fallback Behavior
- Planner: validates `docs/plan.md` and `docs/tasks.md`.
- Implementer: runs `scripts/lint.sh` + `scripts/test.sh`.
- QA: runs `scripts/test.sh` and writes pass/fail summary.
- Reviewer: gates by QA result and writes blocking feedback on failure.
- Release: writes release output; tag push disabled by default.

## Artifacts
- Run outputs are written to `artifacts/agent-runs/<run-id>/`.
- CI uploads these artifacts on every run (pass or fail).
