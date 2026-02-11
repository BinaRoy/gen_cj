# Backend Module Contract (Cloudflare Worker)

## Scope
- This directory contains the API layer between the app and OpenAI.
- Responsibilities: validation, normalized errors, request context, persistence integration.

## Layer Boundaries
- `routes`: HTTP surface and contract-level request/response handling.
- `middlewares`: cross-cutting request context, tracing, and guards.
- `services`: business logic and provider integration.
- `repos`: D1/KV persistence access only.
- `schemas`: request/response validation and shared schema definitions.

## Rules
- `routes` should delegate logic to `services` instead of embedding provider logic.
- `services` should depend on `repos` abstractions for persistence operations.
- Error responses should keep unified shape: `code`, `message`, `request_id`.

## Related Docs
- Design: `docs/plans/2026-02-11-cangjie-ai-chat-app-design.md`
- Implementation Plan: `docs/plans/2026-02-11-cangjie-ai-chat-app-implementation-plan.md`
- Project Log: `docs/process/2026-02-11-project-log.md`
