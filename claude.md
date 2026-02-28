# Claude Project DNA

## Mission Context
This workspace drives two parallel initiatives:
1. **Eyes**: Real-time visual intelligence platform.
2. **Shoplifting Detection**: Retail safety detection pipeline with alert orchestration.

## Architecture Directives
- Treat detection and notification as separate bounded contexts.
- Keep model orchestration isolated from UI and API edges.
- All product behavior must be spec-first, then code.

## Core Runtime Layers
- `ingest`: camera/video/frame adapters.
- `detect`: object + behavior inference.
- `reason`: policy thresholds and confidence gating.
- `alert`: escalation rules and notification fan-out.
- `audit`: event timeline, explainability, and retention controls.

## Execution Discipline
- Read active plans from `.planning/` before implementation.
- Sync task progression with `ccpm` commands during execution.
- Reference `skills.md` before writing ad-hoc scripts.

## Decision Record
- Any architectural change must be appended to this file under a timestamped heading.
