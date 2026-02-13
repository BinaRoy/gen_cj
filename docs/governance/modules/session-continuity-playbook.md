# Session Continuity Playbook / 会话续航流程

## Strict Handover Pack (Required)
- `branch`
- `latest commit hash`
- `completed items`
- `pending items`
- `key files touched`
- `latest test command(s)`
- `latest test summary`
- `risks/blockers`
- `rollback point`
- `next exact command(s)`

## Usage
- Before ending current session, generate handover pack.
- Before starting new session, paste handover pack and required context docs.

## Hard Gate
- Missing any Strict Handover Pack key field => handover invalid.
