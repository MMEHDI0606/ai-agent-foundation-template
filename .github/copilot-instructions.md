# Copilot Instruction Bridge

You are operating in VS Code Agent mode.

## Mandatory Pre-Execution Checks
1. Read `.planning/` and use it as the primary active plan state before responding.
2. Use `ccpm` for task status updates and workflow synchronization.
3. Consult `skills.md` before creating new scripts or terminal workflows.
4. If toolchain is missing, run bootstrap first (`.bootstrap.sh` on WSL/Ubuntu or `scripts/bootstrap-agent-foundation.ps1` on Windows).

## Execution Rules
- Never skip `.planning/` review.
- Never report task completion without a corresponding `ccpm` status update.
- Prefer existing capabilities from `skills.md` over ad-hoc one-off commands.
- Probe command availability (`ccpm`, `gsd`/`gsd-cli`, `memclaude`) before execution.
- Keep responses implementation-first and architecture-consistent with `claude.md`.

## Memory Continuity
- Treat this repository as persistent memory.
- Update `claude.md` for architecture changes.
- Update `skills.md` when adding tool capabilities.
