# Clean only this project's build products, preserving dependency caches.
# Run directly, not inside run_logged.py; check.ps1 bounds each child command.
$ErrorActionPreference = 'Stop'
$ProjectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
Set-Location -LiteralPath $ProjectRoot
$Stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmss.fffffffZ')
$BuildPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot '.lake/build'))
$BackupPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot ".tools/build-backups/$Stamp"))
$Prefix = $ProjectRoot.TrimEnd('\') + '\'
foreach ($Target in @($BuildPath, $BackupPath)) {
    if (-not $Target.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Build move target escapes the verified project root: $Target"
    }
}
if ($BuildPath -ne (Join-Path $ProjectRoot '.lake\build')) { throw 'Unexpected build source path.' }
if (Test-Path -LiteralPath $BuildPath) {
    if ((Get-Item -LiteralPath $BuildPath).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Refusing to move a build directory that is a reparse point.'
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $BackupPath) | Out-Null
    if (Test-Path -LiteralPath $BackupPath) { throw 'Build backup already exists.' }
    Move-Item -LiteralPath $BuildPath -Destination $BackupPath
}
if (Test-Path -LiteralPath $BuildPath) { throw 'Project build directory was not cleared.' }
$LogPath = Join-Path $ProjectRoot "logs/current-run/${Stamp}_clean-check.log"
$MetadataPath = Join-Path $ProjectRoot "logs/current-run/${Stamp}_clean-check.json"
$Sources = @{}
$SourceFiles = @(Get-ChildItem -LiteralPath $ProjectRoot -Filter '*.lean' -File) +
    @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'Autocorrelation') -Filter '*.lean' -File -Recurse) +
    @((Get-Item -LiteralPath 'lean-toolchain'), (Get-Item -LiteralPath 'lakefile.toml'),
      (Get-Item -LiteralPath 'lake-manifest.json'), (Get-Item -LiteralPath 'certificate.json'))
foreach ($File in $SourceFiles) {
    $Sources[$File.FullName.Substring($Prefix.Length).Replace('\', '/')] =
        (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
}
$Metadata = [ordered]@{
    started_utc = [DateTime]::UtcNow.ToString('o')
    command = @('pwsh', '-NoProfile', '-File', 'scripts/check.ps1')
    cwd = $ProjectRoot
    moved_build_path = $BuildPath
    preserved_backup_path = $BackupPath
    project_build_absent_before_check = $true
    dependency_caches_preserved = $true
    source_sha256 = $Sources
    log = $LogPath
    status = 'running'
    child_exit_code = $null
}
$Metadata | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $MetadataPath -Encoding utf8
$ShellPath = (Get-Process -Id $PID).Path
& $ShellPath -NoProfile -File (Join-Path $PSScriptRoot 'check.ps1') 2>&1 |
    Tee-Object -FilePath $LogPath
$Code = $LASTEXITCODE
$Metadata.child_exit_code = $Code
$Metadata.status = if ($Code -eq 0) { 'passed' } else { 'failed' }
$Metadata.finished_utc = [DateTime]::UtcNow.ToString('o')
$Metadata | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $MetadataPath -Encoding utf8
Write-Output "Clean-check metadata: $MetadataPath"
exit $Code
