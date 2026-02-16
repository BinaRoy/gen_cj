# Gen Cangjie

Pure-Cangjie HarmonyOS NEXT AI chat app with a Cloudflare Worker backend.

## What This Project Is

- `app/`: mobile app (Pure Cangjie).
- `backend/`: API boundary and provider integration.
- `docs/`: governance, plans, tasks, decisions, and process logs.

## Quick Start (Local)

1. Install Node.js 20+.
2. Install dependencies:
```bash
npm ci
```
3. Create local env:
```bash
cp .env.example .env
```
4. Run baseline checks:
```bash
bash scripts/dev.sh
```

## Run Tests

Run backend tests:
```bash
npm test
```

Run unified test script (backend + optional Cangjie test detection):
```bash
bash scripts/test.sh
```

Run repository lint checks:
```bash
bash scripts/lint.sh
```

## Multi-Role Collaboration Entry

- Plan and scope: `docs/plan.md`
- Task board: `docs/tasks.md`
- Decisions (ADR): `docs/decisions/`
- Pipeline contract: `docs/pipeline/multi-role-pipeline.md`
- Governance rules: `docs/governance/README.md`

## FAQ

### Q: Why does app UI still show network failure in some runs?
A: If transport is not configured for real HTTP yet, app-side gateway returns a network-category result. Follow `docs/plan.md` P0 tasks.

### Q: Where do I put secrets?
A: Local `.env` only. Never commit real secrets.

### Q: Why is there no Python lock file?
A: This repo currently runs with Node/Cangjie toolchains only. Add Python lock files only when Python runtime is introduced.
