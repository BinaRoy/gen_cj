# Multi-Role Pipeline (Single Repo)

## Goal
- Convert multi-session collaboration into a file-and-command-driven pipeline.
- Keep collaboration independent from chat memory and portable to other agent frameworks.

## Source of Truth
- Git repository state (branches, commits, tags, PRs)
- CI result (green/red)
- Task board (`docs/tasks.md`)

## Roles and Deliverables

### Planner
- Owns: `docs/plan.md`, `docs/tasks.md`
- Must output:
  - milestone scope and acceptance criteria
  - explicit out-of-scope list
  - task split (0.5-1 day per task)

### Implementer
- Owns: code changes for assigned task only
- Must output:
  - small commits
  - PR description with exact verify commands and results

### QA
- Owns: test additions/fixes and reproducible failure reports
- Must output:
  - failing test evidence
  - reproducible command sequence
  - raw log path under `docs/process/compile-logs/`

### Reviewer
- Owns: code review checklist and gate decision
- Must output:
  - blocking issues
  - non-blocking issues
  - pass/fail gate with reasons

### Release
- Owns: version tag/changelog/rollback point
- Must output:
  - release note summary
  - exact rollback commit or previous tag

## Pipeline Stages
1. Planner updates `docs/plan.md` + `docs/tasks.md`
2. Implementer submits code + command evidence
3. QA verifies and archives failure/pass logs
4. Reviewer gates task completion
5. Release tags and updates release notes

## CI Minimum Contract
- Step 1: `bash scripts/lint.sh`
- Step 2: `bash scripts/test.sh`

## Working Rules
- No role edits outside its ownership unless task explicitly says so.
- No task completion claim without command evidence.
- No release without reviewer pass.
