# Implementation Playbook / 开发流程

## Core Policy
- Use strict TDD flow: RED -> GREEN -> REFACTOR.
- Keep app-side code Pure Cangjie.

## Cangjie-First Policy
- Development must reference Cangjie docs/samples first.
- Each engineering update must include `Cangjie references used`.
- If references are missing for a specific problem, mark `Spec Gap` and implement only minimal reversible code.

## Multi-Session Collaboration (Same Task)
- Recommended role split:
1. Planner session: task split + acceptance criteria.
2. Executor session: implementation + self-test.
3. Reviewer session: regression/risk review + merge decision.
4. Archivist session: logs/docs/handover update.

## Concurrency Rules
- Only one session can edit the same file at a time.
- Executor cannot mark completed without reviewer approval.

## Hard Gate
- No completed claim without RED/GREEN evidence.
- No merge request without updated project log and command evidence.
