# Structure & Archive Playbook / 结构与归档流程

## Goal
- Keep workspace structure, DevEco target structure, and evidence archive consistent.

## Required Artifacts
- mapping document (source -> target paths)
- executable migration commands
- compile/verify logs in `docs/process/compile-logs/`

## Directory Convention
- governance rules: `docs/governance/`
- process history: `docs/process/`
- external references: `docs/references/`
- release checklist: `docs/release/`

## Hard Gate
- No migration accepted without:
1. mapping evidence
2. exact migration commands
3. post-migration verification result
