$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot
. (Join-Path $PSScriptRoot 'env.ps1')
New-Item -ItemType Directory -Force logs | Out-Null

# Invoke directly, never inside run_logged.py: each child takes its own lock.
$Python = (Get-Command python -ErrorAction Stop).Source
$RunToken = [Guid]::NewGuid().ToString('N')

function Invoke-Logged {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$Command,
        [int]$Timeout = 600,
        [int]$MemoryEstimateMb = 800
    )
    $UniqueLabel = "check-$Label-$RunToken"
    $RunnerArgs = @('scripts/run_logged.py', '--label', $UniqueLabel,
        '--timeout', "$Timeout", '--memory-estimate-mb', "$MemoryEstimateMb", '--') + $Command
    & $Python @RunnerArgs | Out-Host
    $CommandExit = $LASTEXITCODE
    if ($CommandExit -ne 0) { exit $CommandExit }
    $Files = @(Get-ChildItem -LiteralPath 'logs/current-run' -Filter "*_$UniqueLabel.json")
    if ($Files.Count -ne 1) { throw "Expected one actual runner result for $UniqueLabel" }
    $Metadata = Get-Content -LiteralPath $Files[0].FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Metadata.status -ne 'passed' -or $Metadata.child_exit_code -ne 0) {
        throw "Runner result was not a successful actual command: $UniqueLabel"
    }
    $Metadata | Add-Member -MemberType NoteProperty -Name runner_metadata_path -Value $Files[0].FullName
    return $Metadata
}

Invoke-Logged -Label 'static' -Command @($Python, 'scripts/static_check.py') -Timeout 60 -MemoryEstimateMb 64 | Out-Null
$LakeVersion = Invoke-Logged -Label 'lake-version' -Command @('lake', '--version') -Timeout 60 -MemoryEstimateMb 64
$LeanVersion = Invoke-Logged -Label 'lean-version' -Command @('lake', 'env', 'lean', '--version') -Timeout 60 -MemoryEstimateMb 128
$VersionPath = Join-Path $ProjectRoot 'logs/lean-version.txt'
[System.IO.File]::WriteAllBytes($VersionPath, [byte[]](
    [System.IO.File]::ReadAllBytes($LakeVersion.log) + [System.IO.File]::ReadAllBytes($LeanVersion.log)))

# Dependency-first module builds avoid starting every certificate leaf at once.
# Install matching mathlib/dependency caches before running this entry point.
& $Python scripts/build_serial.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$Build = Invoke-Logged -Label 'lake-build' -Command @('lake', 'build')
Copy-Item -LiteralPath $Build.log -Destination 'logs/lean-build.log' -Force
$Audit = Invoke-Logged -Label 'lean-audit' -Command @('lake', 'env', 'lean', 'Audit.lean')
Copy-Item -LiteralPath $Audit.log -Destination 'logs/lean-axioms.log' -Force
Invoke-Logged -Label 'axiom-parser' -Command @($Python, 'scripts/check_axioms.py',
    '--runner-metadata', $Audit.runner_metadata_path, '--require-core') -Timeout 60 -MemoryEstimateMb 64 | Out-Null
Write-Output 'Actual project compilation and requested axiom reports passed. Consult VERIFICATION_REPORT.md for which mathematical targets are proved; compiled proposition definitions alone are not proofs.'
