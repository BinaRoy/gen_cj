# Internal Test Release Checklist

## Scope
- Date: 2026-02-12
- Target: Internal MVP validation package for Task 1-8 baseline
- Non-goals: No Task 9+ feature work, no production rollout changes

## 1. Environment Variables and Secret Management

### Required Variables
- `OPENAI_API_KEY` (backend runtime)
- `OPENAI_BASE_URL` (optional endpoint override)
- `OPENAI_MODEL` (default model)
- `CF_ACCOUNT_ID`, `CF_API_TOKEN` (Cloudflare deployment operations)
- `D1_DATABASE_ID`, `KV_NAMESPACE_ID` (backend persistence resources)

### Secret Hygiene Checklist
- [ ] No secret hardcoded in source, tests, docs screenshots, or commit messages
- [ ] Runtime secrets injected via environment, not in route payloads
- [ ] API token scope is minimal (least privilege)
- [ ] Rotation window defined before internal test kickoff
- [ ] Revocation plan confirmed for leaked/expired credential

### Rotation and Revocation Procedure
1. Create replacement secret in provider console (OpenAI/Cloudflare).
2. Update runtime secret store and deployment environment.
3. Invalidate old secret immediately after successful smoke tests.
4. Re-run backend smoke tests to confirm new secret validity.
5. Record rotation timestamp and operator in release notes.

## 2. Smoke Test Procedure

### Backend Smoke Tests
Run from repository root:

```bash
npm test -- backend/test/routes.contract.test.ts
npm test -- backend/test/chat.service.test.ts
npm test -- backend/test/persistence.integration.test.ts
npm test -- backend/test/feedback.route.test.ts
```

Pass criteria:
- All commands exit with code `0`
- No failed test suite
- Error shape stays normalized (`code/message/request_id`)

### App Smoke Tests (Pure Cangjie)
Run from repository root:

```bash
source /usr/local/bin/cangjie/envsetup.sh && cjc --test app/src/domain/models/ChatModels.cj app/src/network/ApiClient.cj app/src/domain/ChatUseCase.cj app/src/storage/LocalStore.cj app/src/ui/ChatPage.cj app/src/ui/ConversationListPage.cj app/test/domain/chat_use_case_test.cj app/test/ui/chat_page_smoke_test.cj -o /tmp/task8_full_app_test && /tmp/task8_full_app_test
```

Pass criteria:
- `TOTAL` equals expected test count for current branch
- `FAILED` equals `0`
- Debug trace remains opt-in only (no request_id exposure when debug disabled)

## 3. Rollback Procedure

### Trigger Conditions
- Smoke test regression (`FAILED > 0`)
- Request-id or error schema contract break
- Sensitive content exposure in logs or debug output
- Deployment artifact mismatch with reviewed commit hash

### Rollback Commands
Rollback local integration branch to previous known-good commit:

```bash
git log --oneline -n 10
git revert <bad_commit_hash>
```

If multiple sequential commits must be rolled back:

```bash
git revert <oldest_bad_commit_hash>^..<newest_bad_commit_hash>
```

### Post-Rollback Validation
1. Re-run backend smoke tests.
2. Re-run app Cangjie smoke tests.
3. Verify `docs/process/2026-02-11-project-log.md` includes rollback record.
4. Verify release candidate commit hash matches reviewer-approved baseline.

## 4. Risks and Known Limitations
- Current app persistence is in-memory backend abstraction; no durable device storage implementation yet.
- Debug request_id visibility depends on explicit debug mode toggle and should not be enabled in user-facing builds by default.
- Parallel session workflow can still introduce sequencing risk if cherry-pick order is not strictly tracked.
- Internal test baseline is contract/smoke focused; long-duration soak and load testing are out of current scope.
- Secrets rotation remains manual and operator-dependent; no automated key health monitor in this scope.

## Sign-off
- [ ] Backend smoke suite pass
- [ ] App smoke suite pass
- [ ] Secret rotation/revocation checklist confirmed
- [ ] Rollback rehearsal steps validated
- [ ] Reviewer handoff prepared
