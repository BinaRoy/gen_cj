# ADR-0001: Single-Repo Collaboration Interface

## Status
Accepted (2026-02-16)

## Context
Multiple roles (Planner/Executor/Reviewer) need stable handoff across sessions and potentially across agent frameworks.

## Decision
Use repository-native collaboration interfaces:
- `docs/plan.md` for milestone, acceptance, risks, and non-goals.
- `docs/tasks.md` for executable task board and ownership boundaries.
- `docs/decisions/` for major architectural/process decisions.
- `scripts/dev.sh` and `scripts/test.sh` as common execution entrypoints.
- `.env.example` + `.gitignore` for secret-safe reproducibility.

## Consequences

### Positive
- Reduces context drift between sessions.
- Keeps task boundaries explicit and reviewable.
- Makes agent/framework replacement low-friction.

### Negative
- Requires discipline to keep docs synchronized with code changes.
- Slight overhead for every task checkpoint.
