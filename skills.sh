#!/usr/bin/env bash
set -euo pipefail

npx -y skills add vercel-labs/agent-skills --skill web-design-guidelines -y
npx -y skills add anthropics/skills --skill frontend-design -y
npx -y skills add anthropics/skills --skill mcp-builder -y
npx -y antigravity-awesome-skills --path .agents/skills || npx -y github:sickn33/antigravity-awesome-skills --path .agents/skills
