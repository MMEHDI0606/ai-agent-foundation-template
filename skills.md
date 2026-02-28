# Skills Registry

## Local Skill Loader
- Script: `skills.sh`
- Bootstrap (WSL/Ubuntu): `.bootstrap.sh`
- Bootstrap (Windows): `scripts/bootstrap-agent-foundation.ps1`
- Runtime: `npx skills@latest`
- Command: `bash ./skills.sh`

## Imported Skills
- `vercel-labs/skills/find-skills`
- `vercel-labs/agent-skills/web-design-guidelines`
- `anthropics/skills/frontend-design`
- `remotion-dev/skills/remotion-best-practices`

## Action Contract
- Discover skills with `npx -y skills@latest`
- Add new skill packages into `skills.sh`
- Keep this file synchronized with every imported skill

## Tool Probes
- `gsd` may resolve as `gsd` or `gsd-cli` depending on installed package.
- `memclaude` is probe-based and may require a git/url install target if not present in default registries.
