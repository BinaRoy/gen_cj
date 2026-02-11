# Cangjie HarmonyOS AI Chat App Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a pure-Cangjie HarmonyOS NEXT mobile AI chat MVP for internal testing, backed by Cloudflare Workers Free and OpenAI API.

**Architecture:** The app is fully implemented in Cangjie and split into UI/domain/data/network/storage layers. A Cloudflare Worker provides a stable API boundary with validation, error normalization, and OpenAI delegation. Persistence is local-first on app, with cloud-side conversation/message metadata in D1/KV.

**Tech Stack:** Cangjie (HarmonyOS NEXT app), Cloudflare Workers, Cloudflare D1, Cloudflare KV, OpenAI Chat API.

---

### Task 1: Bootstrap repository structure and documentation baseline

**Files:**
- Create: `app/README.md`
- Create: `backend/README.md`
- Create: `docs/process/2026-02-11-project-log.md`
- Modify: `docs/plans/2026-02-11-cangjie-ai-chat-app-design.md`

**Step 1: Add app/backend folder contract docs**
- Define module boundaries and responsibilities.

**Step 2: Add process log template**
- Include sections: decisions, change log, verification log, risks, next actions.

**Step 3: Cross-link design and plan docs**
- Add references between design, plan, and process log.

**Step 4: Verification**
Run: `rg --files docs app backend`
Expected: all new files visible with intended paths.

**Step 5: Commit**
```bash
git add docs app backend
git commit -m "docs: scaffold architecture and process documentation"
```

### Task 2: Define backend API contract and schemas

**Files:**
- Create: `backend/src/schemas/chat.ts`
- Create: `backend/src/schemas/common.ts`
- Create: `backend/src/routes/chat.ts`
- Create: `backend/src/routes/conversations.ts`
- Create: `backend/src/routes/messages.ts`
- Create: `backend/src/routes/feedback.ts`
- Test: `backend/test/routes.contract.test.ts`

**Step 1: Write failing route contract tests**
- Validate required fields, status codes, and response shape.

**Step 2: Run tests and confirm failure**
Run: `npm test -- backend/test/routes.contract.test.ts`
Expected: FAIL because routes/schemas not implemented.

**Step 3: Implement minimal schema validation and route stubs**
- Return normalized error shape and placeholder success bodies.

**Step 4: Re-run tests**
Run: `npm test -- backend/test/routes.contract.test.ts`
Expected: PASS for contract-level expectations.

**Step 5: Commit**
```bash
git add backend/src backend/test
git commit -m "feat(backend): add v1 route contracts and schema validation"
```

### Task 3: Implement OpenAI-backed chat service

**Files:**
- Create: `backend/src/services/openaiClient.ts`
- Create: `backend/src/services/chatService.ts`
- Create: `backend/src/middlewares/requestContext.ts`
- Modify: `backend/src/routes/chat.ts`
- Test: `backend/test/chat.service.test.ts`

**Step 1: Write failing tests for chat service**
- Cases: success, provider timeout, invalid response, rate limit forwarding.

**Step 2: Run tests and confirm failure**
Run: `npm test -- backend/test/chat.service.test.ts`
Expected: FAIL due to missing service implementation.

**Step 3: Implement service and route integration**
- Add request id propagation and unified error mapping.

**Step 4: Re-run tests**
Run: `npm test -- backend/test/chat.service.test.ts`
Expected: PASS.

**Step 5: Commit**
```bash
git add backend/src backend/test
git commit -m "feat(backend): integrate OpenAI chat service with normalized errors"
```

### Task 4: Add cloud persistence with D1/KV

**Files:**
- Create: `backend/src/repos/conversationRepo.ts`
- Create: `backend/src/repos/messageRepo.ts`
- Modify: `backend/src/routes/conversations.ts`
- Modify: `backend/src/routes/messages.ts`
- Modify: `backend/src/services/chatService.ts`
- Test: `backend/test/persistence.integration.test.ts`

**Step 1: Write failing persistence tests**
- Cover create conversation, append message, paginated list.

**Step 2: Run tests and confirm failure**
Run: `npm test -- backend/test/persistence.integration.test.ts`
Expected: FAIL due to missing repo integration.

**Step 3: Implement repo layer for D1/KV**
- Use D1 for queryable records, KV for short-lived cache.

**Step 4: Re-run tests**
Run: `npm test -- backend/test/persistence.integration.test.ts`
Expected: PASS.

**Step 5: Commit**
```bash
git add backend/src backend/test
git commit -m "feat(backend): add D1/KV persistence for conversations and messages"
```

### Task 5: Build pure-Cangjie app networking and domain layer

**Files:**
- Create: `app/src/network/ApiClient.cj`
- Create: `app/src/domain/ChatUseCase.cj`
- Create: `app/src/domain/models/ChatModels.cj`
- Create: `app/test/domain/chat_use_case_test.cj`

**Step 1: Write failing Cangjie domain tests**
- Validate request building, response mapping, and error category mapping.

**Step 2: Run tests and confirm failure**
Run: `<cangjie-test-command> app/test/domain/chat_use_case_test.cj`
Expected: FAIL due to missing classes.

**Step 3: Implement minimal network/domain code**
- Support `POST /v1/chat` and local model mapping.

**Step 4: Re-run tests**
Run: `<cangjie-test-command> app/test/domain/chat_use_case_test.cj`
Expected: PASS.

**Step 5: Commit**
```bash
git add app/src app/test
git commit -m "feat(app): add pure-cangjie chat domain and api client"
```

### Task 6: Build pure-Cangjie UI and local persistence

**Files:**
- Create: `app/src/ui/ChatPage.cj`
- Create: `app/src/ui/ConversationListPage.cj`
- Create: `app/src/storage/LocalStore.cj`
- Create: `app/test/ui/chat_page_smoke_test.cj`

**Step 1: Write failing UI/storage tests**
- Case: send message, render assistant response, app restart restores history.

**Step 2: Run tests and confirm failure**
Run: `<cangjie-test-command> app/test/ui/chat_page_smoke_test.cj`
Expected: FAIL due to missing UI/store implementation.

**Step 3: Implement minimal UI and local-first persistence**
- Keep full conversation history local.

**Step 4: Re-run tests**
Run: `<cangjie-test-command> app/test/ui/chat_page_smoke_test.cj`
Expected: PASS.

**Step 5: Commit**
```bash
git add app/src app/test
git commit -m "feat(app): add chat ui, conversation list, and local persistence"
```

### Task 7: Wire feedback endpoint and observability baseline

**Files:**
- Modify: `backend/src/routes/feedback.ts`
- Modify: `app/src/domain/ChatUseCase.cj`
- Modify: `app/src/ui/ChatPage.cj`
- Create: `docs/process/2026-02-11-verification-log.md`

**Step 1: Write failing tests for feedback flow**
- Validate rating/comment submission and UI confirmation state.

**Step 2: Run tests and confirm failure**
Run: backend and app test commands for feedback flow
Expected: FAIL before implementation.

**Step 3: Implement feedback and request-id trace display in debug mode**
- Keep logs privacy-safe (no full sensitive content in logs).

**Step 4: Re-run tests**
Run: targeted tests for feedback route and app behavior
Expected: PASS.

**Step 5: Commit**
```bash
git add backend app docs/process
git commit -m "feat: add feedback flow and verification log baseline"
```

### Task 8: Internal test packaging and release checklist

**Files:**
- Create: `docs/release/internal-test-checklist.md`
- Modify: `docs/process/2026-02-11-project-log.md`
- Modify: `docs/process/2026-02-11-verification-log.md`

**Step 1: Write checklist for internal release**
- Include env vars, secrets rotation, smoke tests, rollback notes.

**Step 2: Run full verification**
Run: backend test suite + app test suite + manual smoke test checklist
Expected: all required checks pass.

**Step 3: Record outputs**
- Capture command, timestamp, summary result.

**Step 4: Final documentation update**
- Mark completed scope and deferred scope.

**Step 5: Commit**
```bash
git add docs
git commit -m "docs: add internal testing release checklist and verification records"
```

## Notes
- Replace `<cangjie-test-command>` with the project-standard Cangjie test command once toolchain bootstrap is completed.
- Keep app-side implementation strictly in Cangjie; no mixed-language client modules.
- Do not add login in MVP; only keep extension points in contracts and middleware.
