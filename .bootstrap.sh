#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Installing ccpm (canonical + fallback)..."
if curl -fsSL https://automaze.io/ccpm/install | bash; then
  echo "ccpm canonical installer executed"
else
  echo "ccpm canonical installer unavailable, using git fallback"
  mkdir -p ./.vendor
  rm -rf ./.vendor/ccpm
  git clone https://github.com/automazeio/ccpm.git ./.vendor/ccpm
fi

echo "[2/5] Probe/Install gsd candidates..."
npm search gsd --json > ./.planning/npm-search-gsd.json || true
GSD_OK=0
for cmd in \
  "npm install -g @gsd-now/gsd" \
  "npm install -g gsd-cli" \
  "npm install -g gsd"
do
  if bash -lc "$cmd"; then
    GSD_OK=1
    break
  fi
done
if [ "$GSD_OK" -eq 0 ]; then
  echo "No canonical gsd package resolved automatically"
fi

echo "[3/5] Probe/Install memclaude candidates..."
npm search memclaude --json > ./.planning/npm-search-memclaude.json || true
MEM_OK=0
for cmd in \
  "npm install -g memclaude" \
  "python3 -m pip install --user memclaude"
do
  if bash -lc "$cmd"; then
    MEM_OK=1
    break
  fi
done
if [ "$MEM_OK" -eq 0 ]; then
  echo "memclaude package not found in default registries from this environment"
fi

echo "[4/6] Importing skills.sh capabilities..."
npx -y skills add vercel-labs/agent-skills --skill web-design-guidelines -y || true
npx -y skills add anthropics/skills --skill frontend-design -y || true
npx -y skills add anthropics/skills --skill mcp-builder -y || true

echo "[5/6] Installing Antigravity Awesome Skills pack..."
if npx -y antigravity-awesome-skills --path .agents/skills; then
  echo "Antigravity installed via npm registry package"
elif npx -y github:sickn33/antigravity-awesome-skills --path .agents/skills; then
  echo "Antigravity installed via github: fallback"
else
  echo "Antigravity install failed; continuing with base skills"
fi

echo "[6/6] Verifying command surface..."
command -v ccpm || true
command -v gsd || true
command -v gsd-cli || true
command -v memclaude || true

echo "Bootstrap complete."