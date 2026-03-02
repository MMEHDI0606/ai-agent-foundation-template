[CmdletBinding()]
param(
  [ValidateSet('project', 'user', 'both')]
  [string]$Scope = 'project',

  [ValidateSet('typescript', 'python', 'golang', 'swift')]
  [string[]]$TechStacks = @('typescript'),

  [switch]$InstallCommands,
  [switch]$InstallSkills
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$vendorRoot = Join-Path $ProjectRoot '.vendor'
$eccPath = Join-Path $vendorRoot 'everything-claude-code'

if (-not (Test-Path $vendorRoot)) {
  New-Item -ItemType Directory -Force -Path $vendorRoot | Out-Null
}

if (Test-Path $eccPath) {
  Write-Host 'Updating existing ECC clone...'
  Push-Location $eccPath
  git pull --ff-only
  Pop-Location
} else {
  Write-Host 'Cloning ECC...'
  git clone https://github.com/affaan-m/everything-claude-code.git $eccPath
}

if (-not (Test-Path (Join-Path $eccPath 'rules'))) {
  throw 'ECC repository is missing rules/ directory.'
}

function Copy-DirSafe {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination
  )

  if (-not (Test-Path $Source)) {
    Write-Host "Skipped missing source: $Source" -ForegroundColor Yellow
    return
  }

  if (Test-Path $Destination) {
    Remove-Item -Recurse -Force $Destination
  }

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
  Copy-Item -Recurse -Force $Source $Destination
  Write-Host "Installed: $Destination"
}

$targets = @()
if ($Scope -in @('project', 'both')) {
  $targets += (Join-Path $ProjectRoot '.claude')
}
if ($Scope -in @('user', 'both')) {
  $targets += (Join-Path $HOME '.claude')
}

foreach ($targetRoot in $targets) {
  Write-Host "Applying ECC to: $targetRoot"
  $rulesRoot = Join-Path $targetRoot 'rules'
  New-Item -ItemType Directory -Force -Path $rulesRoot | Out-Null

  Copy-DirSafe -Source (Join-Path $eccPath 'rules/common') -Destination (Join-Path $rulesRoot 'common')
  foreach ($stack in $TechStacks) {
    Copy-DirSafe -Source (Join-Path $eccPath ("rules/$stack")) -Destination (Join-Path $rulesRoot $stack)
  }

  if ($InstallCommands) {
    Copy-DirSafe -Source (Join-Path $eccPath 'commands') -Destination (Join-Path $targetRoot 'commands')
  }

  if ($InstallSkills) {
    Copy-DirSafe -Source (Join-Path $eccPath 'skills') -Destination (Join-Path $targetRoot 'skills')
  }
}

Write-Host 'ECC integration complete.'