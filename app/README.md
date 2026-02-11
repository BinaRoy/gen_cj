# App Module Contract (Pure Cangjie)

## Scope
- This directory contains the HarmonyOS NEXT mobile app implementation.
- App-side code must stay pure Cangjie.

## Layer Boundaries
- `ui`: page/state rendering and interaction orchestration only.
- `domain`: use cases, business rules, and app-level error mapping.
- `data`: repository-level coordination between network and local storage.
- `network`: API client, DTO mapping, and transport error normalization.
- `storage`: local persistence for full conversation history.

## Rules
- `ui` must not call `network` directly; go through `domain`/`data`.
- `domain` must not depend on platform UI components.
- `storage` keeps local-first history as source of truth for app rendering.

## Related Docs
- Design: `docs/plans/2026-02-11-cangjie-ai-chat-app-design.md`
- Implementation Plan: `docs/plans/2026-02-11-cangjie-ai-chat-app-implementation-plan.md`
- Project Log: `docs/process/2026-02-11-project-log.md`
