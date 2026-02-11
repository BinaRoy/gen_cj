# Cangjie HarmonyOS AI Chat App Design

## Related Documents
- Implementation plan: `docs/plans/2026-02-11-cangjie-ai-chat-app-implementation-plan.md`
- Process log: `docs/process/2026-02-11-project-log.md`
- Multi-session protocol: `docs/process/2026-02-11-multi-session-coordination.md`

## Scope
- Target: HarmonyOS NEXT mobile app, app-side implemented in pure Cangjie.
- MVP: internal testing release, no login, chat completion, conversation list, local persistence.
- Backend: Cloudflare Workers Free as API layer, OpenAI API as model provider.
- Storage: local full history on app, cloud-side minimal sync data in D1 and KV.

## Confirmed Decisions
- App category: AI chat assistant.
- Client platform: HarmonyOS NEXT.
- Backend model: cloud API pattern (`App -> Worker -> OpenAI`).
- Backend infra: Cloudflare Workers Free.
- Model provider: OpenAI API.
- Auth in MVP: no login, but preserve interfaces for invite code and full account system.
- MVP feature set: minimal version, with architecture reserved for streaming, regenerate, multi-model, and auth upgrades.
- Data sync strategy: local + cloud.

## Architecture
Use a layered architecture with stable boundaries:
- App (pure Cangjie): `ui`, `domain`, `data`, `network`, `storage`.
- Worker backend: `routes`, `middlewares`, `services`, `repos`, `schemas`.
- OpenAI adapter: isolated in service layer so provider switching can be added later.

Data flow:
1. App sends message to `POST /v1/chat` with `X-Client-Id` and optional reserved headers.
2. Worker validates payload and request metadata, adds request id and basic rate control.
3. Chat service calls OpenAI, persists conversation/message metadata, returns response.
4. App renders response and persists full message history locally.

## API Contract (V1)
- `POST /v1/chat`
- `GET /v1/conversations`
- `GET /v1/messages`
- `POST /v1/feedback`

Reserved compatibility fields/headers:
- Headers: `X-Client-Id`, `X-Invite-Code`, `Authorization`
- Request fields: `model`, `temperature`, `stream`

## Error Handling
- Unified backend error body: `code`, `message`, `request_id`.
- App error mapping categories: `NetworkError`, `ServerError`, `RateLimitError`, `UnknownError`.

## Testing Strategy
- App: domain/data unit tests + one end-to-end happy path for send/receive/render.
- Backend: route schema tests, OpenAI failure fallback tests, minimal integration checks.

## Non-Goals (MVP)
- No full auth/account system.
- No multi-model routing UI.
- No streaming output in first release.

## Documentation Policy
- Keep decision log and change history in `docs/process/`.
- Keep implementation plan in `docs/plans/`.
- Record each milestone with date, scope, result, and next action.
- Keep design/plan/process docs cross-linked and updated together.
