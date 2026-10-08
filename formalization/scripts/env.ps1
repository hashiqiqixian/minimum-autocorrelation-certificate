# Dot-source this file: . .\scripts\env.ps1
# These changes apply only to the current PowerShell session and its children.
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LeanBin = Join-Path $ProjectRoot '.tools\lean-4.19.0-windows\bin'
$PythonBin = Join-Path $ProjectRoot '.tools\venv\Scripts'
$env:PATH = "$LeanBin;$PythonBin;$env:PATH"
$env:LEAN_NUM_THREADS = '1'
$env:OMP_NUM_THREADS = '1'
$env:MAX_JOBS = '1'
$env:CMAKE_BUILD_PARALLEL_LEVEL = '1'
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
$env:RAYON_NUM_THREADS = '1'
$env:MATHLIB_CACHE_DIR = Join-Path $ProjectRoot '.tools\mathlib-cache'
$env:CURL_HOME = Join-Path $ProjectRoot '.tools\curl-config'
$env:GIT_TERMINAL_PROMPT = '0'
$env:GIT_HTTP_LOW_SPEED_LIMIT = '1024'
$env:GIT_HTTP_LOW_SPEED_TIME = '30'
# Git HTTPS has no supported http.connectTimeout setting. run_logged.py enforces
# a whole-command timeout; SSH has its own supported connection timeout.
if (-not $env:GIT_SSH_COMMAND) {
    $env:GIT_SSH_COMMAND = 'ssh -o ConnectTimeout=20 -o ServerAliveInterval=15 -o ServerAliveCountMax=2 -o BatchMode=yes'
}
