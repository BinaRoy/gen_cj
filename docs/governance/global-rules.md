# Global Rules / 全局规则

## 1. Scope
- This rulebook applies to all engineering推进任务 (implementation/migration/verification/release docs updates).
- Discussion-only messages are excluded.

## 2. Hard Gate (Must Pass)
- No completion claim without evidence.
- No cross-task expansion without explicit user approval.
- No marking task completed without reviewer confirmation.
- App-side implementation must remain Pure Cangjie unless user approves exception.

## 3. Mandatory 4-Item Update Template
- Every engineering progress response must include:
1. `Task commit hash`
2. `Modified file list`
3. `Exact test/verify command(s)`
4. `Test summary (TOTAL/PASSED/FAILED)`

If any item is missing, status is `NOT COMPLETE`.

## 4. Session Safety
- New session must read:
1. `docs/plans/2026-02-11-cangjie-ai-chat-app-implementation-plan.md`
2. `docs/process/2026-02-11-multi-session-coordination.md`
3. `docs/process/2026-02-11-project-log.md`
- New session must start with Strict Handover Pack.

## 5. Source of Truth
- Execution status and historical decision log are recorded in:
- `docs/process/2026-02-11-project-log.md`

## 6. Verification Priority
- Evidence order:
1. exact commands
2. raw logs
3. pass/fail summary
4. risk/blocker statement

## 7. Rule Evolution
- Any new rule must be recorded in `docs/governance/changelog/` first.
- Then update module playbook/template files.
