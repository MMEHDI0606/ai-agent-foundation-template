$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Try-Command {
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$StopOnSuccess
  )

  try {
    Write-Host "Trying: $Command"
    $global:LASTEXITCODE = 0
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
      throw "Command exited with code $LASTEXITCODE"
    }
    Write-Host "Success: $Command"
    return $true
  } catch {
    Write-Host "Failed: $Command" -ForegroundColor Yellow
    return $false
  }
}

Write-Host "[1/5] Installing ccpm (canonical + fallback)..."
$ccpmInstalled = $false
try {
  $payload = iwr -useb https://automaze.io/ccpm/install
  if ($payload -match "<html|404") {
    throw "ccpm installer endpoint returned non-script content"
  }
  iex $payload
  $ccpmInstalled = $true
} catch {
  Write-Host "Canonical installer unavailable. Using git fallback..." -ForegroundColor Yellow
  if (-not (Test-Path ./.vendor)) {
    New-Item -ItemType Directory -Path ./.vendor | Out-Null
  }
  if (Test-Path ./.vendor/ccpm) {
    Remove-Item -Recurse -Force ./.vendor/ccpm
  }
  Try-Command -Command "git clone https://github.com/automazeio/ccpm.git ./.vendor/ccpm" | Out-Null
}

Write-Host "[2/5] Installing getshitdone / gsd candidates (probe-driven)..."
$gsdSucceeded = $false
$gsdAttempts = @(
  "npm install -g @gsd-now/gsd",
  "npm install -g gsd-cli",
  "npm install -g gsd",
  "pip install --user gsd"
)
foreach ($cmd in $gsdAttempts) {
  if (Try-Command -Command $cmd) {
    $gsdSucceeded = $true
    break
  }
}
if (-not $gsdSucceeded) {
  Write-Host "No canonical gsd package resolved automatically." -ForegroundColor Yellow
}

Write-Host "[3/5] Installing memclaude candidates..."
$memSucceeded = $false
$memAttempts = @(
  "npm install -g memclaude",
  "pip install --user memclaude"
)
foreach ($cmd in $memAttempts) {
  if (Try-Command -Command $cmd) {
    $memSucceeded = $true
    break
  }
}
if (-not $memSucceeded) {
  Write-Host "memclaude package not found in default registries from this environment." -ForegroundColor Yellow
}

$npmBin = Join-Path $env:APPDATA "npm"
if (Test-Path $npmBin) {
  $sessionPaths = $env:Path -split ';'
  if (-not ($sessionPaths -contains $npmBin)) {
    $env:Path = "$npmBin;$env:Path"
  }

  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $userPathParts = @()
  if ($null -ne $userPath -and $userPath.Length -gt 0) {
    $userPathParts = $userPath -split ';'
  }

  if (-not ($userPathParts -contains $npmBin)) {
    $newUserPath = if ($userPathParts.Count -gt 0) { "$npmBin;$userPath" } else { $npmBin }
    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    Write-Host "Added npm global bin path to user PATH: $npmBin"
  }
}

Write-Host "[4/5] Pulling skills ecosystem tools..."
$npxCmd = "npx -y skills"
Try-Command -Command "$npxCmd add vercel-labs/agent-skills --skill web-design-guidelines -y" | Out-Null
Try-Command -Command "$npxCmd add anthropics/skills --skill frontend-design -y" | Out-Null
Try-Command -Command "$npxCmd add anthropics/skills --skill mcp-builder -y" | Out-Null

Write-Host "[5/5] Verifying command surface..."
foreach ($name in @('ccpm', 'gsd', 'gsd-cli', 'memclaude')) {
  $resolved = Get-Command $name -ErrorAction SilentlyContinue
  if ($null -ne $resolved) {
    $resolved | Select-Object Name, Source
  } else {
    Write-Host "Not found on PATH: $name" -ForegroundColor Yellow
  }
}

Write-Host "Foundation initialization complete."
