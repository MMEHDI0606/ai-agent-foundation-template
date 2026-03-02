[CmdletBinding()]
param(
	[string]$NexusPath = "$HOME/ai-agent-foundation-template",
	[string]$TargetPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

function Copy-IfExists {
	param(
		[Parameter(Mandatory = $true)][string]$Source,
		[Parameter(Mandatory = $true)][string]$Destination
	)

	if (Test-Path $Source) {
		$destDir = Split-Path -Parent $Destination
		if (-not (Test-Path $destDir)) {
			New-Item -ItemType Directory -Force -Path $destDir | Out-Null
		}
		Copy-Item -Force $Source $Destination
		Write-Host "Copied: $Destination"
	} else {
		Write-Host "Missing source, skipped: $Source" -ForegroundColor Yellow
	}
}

if (-not (Test-Path $NexusPath)) {
	throw "NexusPath not found: $NexusPath"
}

if (-not (Test-Path $TargetPath)) {
	New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
}

$folders = @(
	'.github',
	'.claude',
	'.planning',
	'scripts'
)

foreach ($folder in $folders) {
	$path = Join-Path $TargetPath $folder
	New-Item -ItemType Directory -Force -Path $path | Out-Null
}

$fileMap = @{
	'claude.md' = 'claude.md'
	'skills.md' = 'skills.md'
	'skills.sh' = 'skills.sh'
	'.bootstrap.sh' = '.bootstrap.sh'
	'.clauderules' = '.clauderules'
	'.github/copilot-instructions.md' = '.github/copilot-instructions.md'
	'.claude/config.md' = '.claude/config.md'
	'scripts/bootstrap-agent-foundation.ps1' = 'scripts/bootstrap-agent-foundation.ps1'
	'scripts/install-ecc.ps1' = 'scripts/install-ecc.ps1'
}

foreach ($entry in $fileMap.GetEnumerator()) {
	$source = Join-Path $NexusPath $entry.Key
	$dest = Join-Path $TargetPath $entry.Value
	Copy-IfExists -Source $source -Destination $dest
}

$planningDefaults = @(
	'README.md',
	'current.md',
	'backlog.md'
)

foreach ($name in $planningDefaults) {
	$source = Join-Path $NexusPath ".planning/$name"
	$dest = Join-Path $TargetPath ".planning/$name"
	if (-not (Test-Path $dest)) {
		Copy-IfExists -Source $source -Destination $dest
	}
}

Write-Host "Nexus sync complete. Target: $TargetPath"
