# Agent Nexus Foundation — Detailed Process & Operations Guide

## Purpose

This repository (`agent-nexus`) is a reusable **agent foundation template**.

It solves four persistent problems:

1. Context gets lost across chat resets.
2. Tool installation is brittle across Windows/WSL and package availability changes.
3. New repos start without standardized planning + execution behavior.
4. Agent instructions drift if not anchored in versioned files.

The result is a portable stack you can stamp into any repository in one command.

---

## What Was Achieved

### 1) Persistent context + instruction layer

Created and connected:

- `claude.md` — project DNA and architecture directives.
- `.clauderules` — Nexus memory/behavior contract.
- `.claude/config.md` — sub-agent role definitions (Architect/Reviewer/Coder).
- `.github/copilot-instructions.md` — strict execution bridge for Copilot Agent.

### 2) Bootstrap automation (self-healing)

Created two bootstrap entrypoints:

- Windows: `scripts/bootstrap-agent-foundation.ps1`
- WSL/Ubuntu: `.bootstrap.sh`

These scripts:

- Attempt canonical install paths first.
- Probe and fallback for missing tools.
- Continue with resilient behavior where safe.
- Verify command surface at the end.

### 3) Skills capability layer

Created:

- `skills.sh`
- `skills.md`

Then wired verified `skills` imports (valid repo + skill names) using `npx skills`.

Also integrated a large community skill pack from:

- `https://github.com/sickn33/antigravity-awesome-skills`

Installed through `npx antigravity-awesome-skills --path .agents/skills` with a GitHub fallback.

### 4) Cross-repo onboarding automation

Created:

- `scripts/sync-from-nexus.ps1`

This copies the full Nexus stack into any target repo and seeds `.planning` templates if missing.

### 5) `.planning` source-of-truth templates

Created starter files so `.planning` is never empty:

- `.planning/README.md`
- `.planning/current.md`
- `.planning/backlog.md`

---

## Exact File Inventory

### Core context and memory

- `claude.md`
- `.clauderules`
- `.claude/config.md`

### Copilot bridge

- `.github/copilot-instructions.md`

### Tooling + skills

- `skills.md`
- `skills.sh`
- `scripts/bootstrap-agent-foundation.ps1`
- `.bootstrap.sh`

### Planning state

- `.planning/README.md`
- `.planning/current.md`
- `.planning/backlog.md`

### Portability

- `scripts/sync-from-nexus.ps1`

---

## Process Timeline (How It Was Done)

1. **Scaffolded foundation directories** (`.github`, `.claude`, `.planning`, `scripts`).
2. **Wrote initial context/instruction/skills/bootstrap files**.
3. **Ran install probes** and identified environment realities:
	- `ccpm` canonical installer endpoint was unstable/unusable in this host context.
	- `getshitdone`/`memclaude` canonical package names were not resolvable in default registries.
	- `gsd` alternatives (`gsd-cli`, `@gsd-now/gsd`) were installable.
4. **Hardened bootstrap logic**:
	- Added fallback clone path for `ccpm` (`.vendor/ccpm`).
	- Added probe-driven candidates for `gsd` and `memclaude`.
	- Fixed command runner so non-zero native exit codes are treated as failures.
	- Added PATH normalization for `%APPDATA%\\npm` on Windows.
5. **Fixed skills imports**:
	- Replaced invalid skills source usage with validated repository/skill combinations.
6. **Added portability script** (`sync-from-nexus.ps1`).
7. **Smoke-tested in a temporary repo** and confirmed all files copy correctly, including `.planning` defaults.

---

## Clarification: Where `.planning` Files Come From

`.planning` files are **not** pulled from an external service.

They come from your Nexus template itself and are copied into each repo via:

- `scripts/sync-from-nexus.ps1`

Then they are updated by your day-to-day work and workflows (`ccpm` updates, manual edits, etc.).

---

## How to Use in a Different Repo

### Step A — Sync Nexus into target repo

From inside target repo:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME/agent-nexus/scripts/sync-from-nexus.ps1" -TargetPath (Get-Location).Path
```

### Step B — Run bootstrap in target repo

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/bootstrap-agent-foundation.ps1
```

WSL/Ubuntu:

```bash
bash ./.bootstrap.sh
```

### Step C — Validate command surface

```powershell
gsd --help
gsd-cli --help
npx -y skills list
Test-Path ./.agents/skills
```

(`memclaude` may remain unresolved until a valid package source is provided.)

### Step D — Configure Nexus for THIS repo (required)

After sync/bootstrap, customize the template so it matches the current repository.

#### 1) Fill project identity in `claude.md`

Update at minimum:

- project name
- business goal
- main architecture boundaries
- runtime stack
- non-functional constraints

Quick open commands:

```powershell
code ./claude.md
code ./.planning/current.md
code ./.github/copilot-instructions.md
```

#### 2) Seed active work in `.planning/current.md`

Populate:

- `Project`
- `Goal`
- first 1-3 in-progress tasks
- blockers (if any)
- next 3 moves

#### 3) Optional repo-specific Copilot guardrails

In `.github/copilot-instructions.md`, add any repo-only rules (test command, lint command, forbidden directories, deployment constraints).

---

### Copy-Paste Prompt: Configure current repo now

Use this prompt directly in Copilot Chat from the target repo root:

```text
You are configuring this repository to use Agent Nexus.

Context:
- Nexus templates are already synced into this repo.
- Required files exist: claude.md, .planning/current.md, .planning/backlog.md, .github/copilot-instructions.md, skills.md.

Tasks:
1) Inspect this repository structure and detect stack (language, framework, package manager, test/lint commands).
2) Update claude.md with repo-specific DNA:
	- Project name and objective
	- Core modules/bounded contexts
	- Runtime/build/test commands
	- Key constraints and quality gates
3) Update .planning/current.md with an actionable initial plan:
	- Active Context
	- 3 concrete in-progress tasks
	- blockers
	- next 3 moves
4) Update .github/copilot-instructions.md to include repo-specific execution rules:
	- Mandatory plan check (.planning)
	- Required test/lint/build command before completion
	- Any forbidden paths/actions for this repo
5) Keep changes minimal and practical. Do not add extra files unless necessary.
6) At the end, summarize exactly what was changed and which commands should be run next.
```

#### 4) Run this validation sequence

```powershell
# Validate tooling
gsd --help
gsd-cli --help
npx -y skills list

# Validate planning exists and is populated
Get-Content ./.planning/current.md

# Optional: check changed files
git status
```

---

## Daily Operating Loop (Per Repo)

1. Open `.planning/current.md`.
2. Execute top active task.
3. Sync status through `ccpm` workflow.
4. Reflect outcomes in `.planning` files.
5. Keep `claude.md` and `skills.md` updated when architecture/capability changes.

---

## Troubleshooting

### `npx antigravity-awesome-skills` returns 404

Symptom:

- npm registry lookup fails for antigravity package.

Behavior:

- bootstrap falls back to `npx -y github:sickn33/antigravity-awesome-skills --path .agents/skills`.

### `ccpm` canonical install fails

Symptom:

- installer URL returns HTML/404/non-script.

Behavior:

- bootstrap falls back to cloning `https://github.com/automazeio/ccpm.git` into `.vendor/ccpm`.

### `gsd` command not found after install

Symptom:

- package installed, command missing.

Behavior:

- bootstrap adds `%APPDATA%\\npm` to user PATH and session PATH.

### `memclaude` install fails

Symptom:

- npm/pip package not found.

Behavior:

- script records probe failure and continues; requires explicit repository/package source once known.

### `skills` import fails

Symptom:

- invalid skills source or wrong command syntax.

Behavior:

- migrated to validated `npx skills add <repo> --skill <name> -y` usage.

---

## Operational Status Snapshot

- `gsd` stack: installable/resolvable in this environment.
- `ccpm`: fallback clone path available when canonical endpoint is unstable.
- `memclaude`: unresolved by default registries; probe-based failure handling in place.
- `skills`: validated import/list workflow functioning.
- `antigravity-awesome-skills`: integrated with registry + `github:` fallback installer.

---

## Full Command Cookbook (Build Agent Nexus Anywhere)

Use one of the two paths below.

### Path 1 — Build from this existing Nexus template (fastest)

#### Windows PowerShell

```powershell
# 1) Go to target repository
Set-Location "C:\path\to\your\target-repo"

# 2) Sync complete Nexus foundation into this repo
powershell -ExecutionPolicy Bypass -File "$HOME/agent-nexus/scripts/sync-from-nexus.ps1" -TargetPath (Get-Location).Path

# 3) Run bootstrap installer/probes in this repo
powershell -ExecutionPolicy Bypass -File ./scripts/bootstrap-agent-foundation.ps1

# 4) Validate tools and skills
gsd --help
gsd-cli --help
npx -y skills list
Test-Path ./.agents/skills

# 5) Open active planning state
Get-Content ./.planning/current.md
```

#### WSL/Ubuntu

```bash
# 1) Go to target repository
cd /path/to/your/target-repo

# 2) (If template exists in Windows home) copy from mounted location
powershell.exe -ExecutionPolicy Bypass -File "$HOME/agent-nexus/scripts/sync-from-nexus.ps1" -TargetPath "$(pwd)"

# 3) Run Linux bootstrap
bash ./.bootstrap.sh

# 4) Validate tools and skills
gsd --help || true
gsd-cli --help || true
npx -y skills list

# 5) Open active planning state
cat ./.planning/current.md
```

---

### Path 2 — Build Agent Nexus from zero (no existing template)

#### Windows PowerShell (create foundation skeleton)

```powershell
# 1) Create a fresh repository folder
Set-Location $HOME
New-Item -ItemType Directory -Force -Path ./agent-nexus | Out-Null
Set-Location ./agent-nexus

# 2) Create core directory structure
New-Item -ItemType Directory -Force -Path .github,.claude,.planning,scripts | Out-Null

# 3) Create required files
New-Item -ItemType File -Force -Path ./claude.md | Out-Null
New-Item -ItemType File -Force -Path ./.clauderules | Out-Null
New-Item -ItemType File -Force -Path ./.claude/config.md | Out-Null
New-Item -ItemType File -Force -Path ./.github/copilot-instructions.md | Out-Null
New-Item -ItemType File -Force -Path ./skills.md | Out-Null
New-Item -ItemType File -Force -Path ./skills.sh | Out-Null
New-Item -ItemType File -Force -Path ./.bootstrap.sh | Out-Null
New-Item -ItemType File -Force -Path ./scripts/bootstrap-agent-foundation.ps1 | Out-Null
New-Item -ItemType File -Force -Path ./scripts/sync-from-nexus.ps1 | Out-Null
New-Item -ItemType File -Force -Path ./.planning/README.md | Out-Null
New-Item -ItemType File -Force -Path ./.planning/current.md | Out-Null
New-Item -ItemType File -Force -Path ./.planning/backlog.md | Out-Null
```

#### Add toolchain dependencies manually (PowerShell)

```powershell
# Node (required for skills and npm probes) should already be installed.
# Install GSD candidates:
npm install -g @gsd-now/gsd
npm install -g gsd-cli

# Probe memclaude candidates (may fail if package not published):
npm install -g memclaude
pip install --user memclaude

# Install skills and import verified skills
npx -y skills add vercel-labs/agent-skills --skill web-design-guidelines -y
npx -y skills add anthropics/skills --skill frontend-design -y
npx -y skills add anthropics/skills --skill mcp-builder -y
npx -y antigravity-awesome-skills --path .agents/skills
# fallback if registry package is unavailable
npx -y github:sickn33/antigravity-awesome-skills --path .agents/skills

# Verify
gsd --help
gsd-cli --help
npx -y skills list
Test-Path ./.agents/skills
```

#### Optional ccpm install attempts

```powershell
# Canonical (may fail if endpoint is unstable)
iwr -useb https://automaze.io/ccpm/install | iex

# Fallback clone for local access
New-Item -ItemType Directory -Force -Path ./.vendor | Out-Null
git clone https://github.com/automazeio/ccpm.git ./.vendor/ccpm
```

---

### Repo bootstrap smoke test (recommended)

```powershell
Set-Location $HOME
$test = Join-Path $HOME 'nexus-smoketest-repo'
if (Test-Path $test) { Remove-Item -Recurse -Force $test }
New-Item -ItemType Directory -Path $test | Out-Null

powershell -ExecutionPolicy Bypass -File "$HOME/agent-nexus/scripts/sync-from-nexus.ps1" -TargetPath $test
Set-Location $test
powershell -ExecutionPolicy Bypass -File ./scripts/bootstrap-agent-foundation.ps1
Get-ChildItem -Recurse -File | Select-Object FullName
```

---

## Optional Enhancement

If you have a known `memclaude` source (git URL/package tarball/private registry), add it into both bootstrap scripts as first-priority candidate and keep fallback probes behind it.

