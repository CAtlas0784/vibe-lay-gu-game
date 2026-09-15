$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $Root
$ConfigPath = Join-Path $ProjectRoot 'config\private-server.json'
$ProxyDir = Join-Path $Root 'proxy'

if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing config: $ConfigPath" }
$Config = Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json

$required = @(
    (Join-Path $ProxyDir 'server.js'),
    (Join-Path $ProxyDir 'private_server_config.js'),
    (Join-Path $ProxyDir 'package.json'),
    (Join-Path $ProxyDir 'public\fastpatch_4229938.zip')
)
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing proxy file: $path" }
}

$NodeExe = $env:Ananta_NODE_EXE
if (-not $NodeExe) { $NodeExe = $env:ANANTA_NODE_EXE }
if (-not $NodeExe) {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if ($cmd) { $NodeExe = $cmd.Source }
}
if (-not $NodeExe) {
    foreach ($candidate in @(
        (Join-Path $Root 'tools\node\node.exe'),
        'C:\Program Files\nodejs\node.exe'
    )) {
        if (Test-Path -LiteralPath $candidate) { $NodeExe = $candidate; break }
    }
}
if (-not $NodeExe) { throw 'node.exe was not found. Install Node.js LTS or set Ananta_NODE_EXE.' }

$env:Ananta_CONFIG = $ConfigPath
$env:Ananta_ROOT = $ProjectRoot

Push-Location $ProxyDir
try {
    & $NodeExe -e "require('./private_server_config.js'); console.log('[OK] proxy config loaded')"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Host '[OK] Proxy files and private-server config are ready.' -ForegroundColor Green
