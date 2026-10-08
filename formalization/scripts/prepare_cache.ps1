# Reproduce the bounded, project-local mathlib cache setup using installed tools.
# Run this script directly, not inside run_logged.py (each command takes its lock).
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot
. (Join-Path $PSScriptRoot 'env.ps1')
$Python = (Get-Command python -ErrorAction Stop).Source

function Invoke-CacheLogged {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$Command,
        [int]$Timeout = 900,
        [int]$MemoryEstimateMb = 500
    )
    $RunnerArgs = @('scripts/run_logged.py', '--label', $Label,
        '--timeout', "$Timeout", '--memory-estimate-mb', "$MemoryEstimateMb", '--') + $Command
    & $Python @RunnerArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# urllib reads the already configured process/system proxy settings on Windows.
# Capture the result privately: never print proxy URLs or credentials, and never
# write them to .curlrc, command arguments, log files, or global configuration.
$ProxyJson = & $Python -c 'import json, urllib.request; print(json.dumps(urllib.request.getproxies()))'
if ($LASTEXITCODE -ne 0) { throw 'Could not read existing proxy settings.' }
$ExistingProxies = $ProxyJson | ConvertFrom-Json
$ProxyNames = @{ http = 'http_proxy'; https = 'https_proxy'; all = 'all_proxy'; no = 'no_proxy' }
foreach ($ProxyKind in $ProxyNames.Keys) {
    $VariableName = $ProxyNames[$ProxyKind]
    $ProxyProperty = $ExistingProxies.PSObject.Properties[$ProxyKind]
    $AlreadySet = [System.Environment]::GetEnvironmentVariable($VariableName, 'Process')
    if (-not $AlreadySet -and $null -ne $ProxyProperty -and $ProxyProperty.Value) {
        [System.Environment]::SetEnvironmentVariable($VariableName, [string]$ProxyProperty.Value, 'Process')
    }
}
$ProxyJson = $null
$ExistingProxies = $null
$ProxyProperty = $null

$env:CURL_HOME = Join-Path $ProjectRoot '.tools/curl-config'
$env:MATHLIB_CACHE_DIR = Join-Path $ProjectRoot '.tools/mathlib-cache'
New-Item -ItemType Directory -Force -Path $env:CURL_HOME, $env:MATHLIB_CACHE_DIR | Out-Null
$CurlConfig = @'
# At most 8 concurrent network transfers; this is network I/O only.
# Cache compilation below is sequential; leantar unpacking uses --jobs 1.
connect-timeout = 15
max-time = 120
parallel-max = 8
'@
[System.IO.File]::WriteAllText((Join-Path $env:CURL_HOME '.curlrc'),
    $CurlConfig + "`n", [System.Text.UTF8Encoding]::new($false))

$MathlibPath = Join-Path $ProjectRoot '.lake/packages/mathlib'
$CacheIO = Join-Path $MathlibPath 'Cache/IO.lean'
$PatchPath = Join-Path $ProjectRoot 'scripts/patches/mathlib-cache-single-worker.patch'
if (-not (Test-Path -LiteralPath $CacheIO)) { throw 'mathlib source is missing; run lake update first.' }
$SingleWorkerPattern = '#\["--jobs",\s*"1",\s*"-x",\s*"--delete-corrupted",\s*"-j",\s*"-"\]'
$IOSource = [System.IO.File]::ReadAllText($CacheIO)
if ($IOSource -notmatch $SingleWorkerPattern) {
    if (-not (Test-Path -LiteralPath $PatchPath)) { throw 'Required single-worker cache patch is missing.' }
    $PatchBytes = [System.IO.File]::ReadAllBytes($PatchPath)
    if ($PatchBytes.Length -ge 3 -and $PatchBytes[0] -eq 239 -and $PatchBytes[1] -eq 187 -and $PatchBytes[2] -eq 191) {
        throw 'Cache patch contains a UTF-8 BOM; provide the original BOM-free patch before git apply.'
    }
    Invoke-CacheLogged -Label 'cache-patch-check' -Command @('git', '-C', $MathlibPath, 'apply', '--check', $PatchPath) -Timeout 30 -MemoryEstimateMb 64
    Invoke-CacheLogged -Label 'cache-patch-apply' -Command @('git', '-C', $MathlibPath, 'apply', $PatchPath) -Timeout 30 -MemoryEstimateMb 64
    if ([System.IO.File]::ReadAllText($CacheIO) -notmatch $SingleWorkerPattern) {
        throw 'Applied patch did not establish single-worker cache unpacking.'
    }
} else {
    Write-Output 'Single-worker cache unpacking patch already present.'
}

# Cache's five modules form this import chain in pinned mathlib v4.19.0.
# Build one module's native object at a time so rebuilding after the IO patch
# cannot fan out into concurrent compiler processes. :o is the default native
# object facet used by this Windows cache executable (supportInterpreter=false).
foreach ($Module in @('Cache.Lean', 'Cache.IO', 'Cache.Hashing', 'Cache.Requests', 'Cache.Main')) {
    Invoke-CacheLogged -Label "cache-compile-$Module" -Command @('lake', 'build', "+${Module}:o")
}

$CacheRoots = @(
    'Mathlib.Analysis.Calculus.Deriv.MeanValue',
    'Mathlib.Analysis.Calculus.Deriv.Pow',
    'Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus',
    'Mathlib.Tactic.Convert',
    'Mathlib.Tactic.NormNum',
    'Mathlib.Tactic.Ring',
    'Mathlib.Tactic.Linarith',
    'Mathlib.Tactic.FieldSimp'
)
Invoke-CacheLogged -Label 'cache-prepare-targeted' -Command (@('lake', 'exe', 'cache', 'get') + $CacheRoots)
Write-Output 'Requested mathlib cache command completed. Project proofs still require check.ps1 and the separate mathematical verification report.'
