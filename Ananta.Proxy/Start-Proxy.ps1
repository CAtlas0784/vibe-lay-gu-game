$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $Root
$ConfigPath = Join-Path $ProjectRoot 'config\private-server.json'
$ProxyDir = Join-Path $Root 'proxy'

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Private server config is missing: $ConfigPath"
}
$Config = Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json
$env:Ananta_CONFIG = $ConfigPath

$DnsName = [string]$Config.network.proxy.updateHost
$PfxPath = Join-Path $ProxyDir ("certs\{0}.pfx" -f $DnsName)
if (-not (Test-Path -LiteralPath $PfxPath)) {
    throw 'Proxy certificate is missing. Run SETUP_PROXY_AS_ADMIN.ps1 once as Administrator.'
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
if (-not $NodeExe) {
    throw 'node.exe was not found. Install Node.js LTS or set Ananta_NODE_EXE.'
}

$ports = @(
    [int]$Config.network.proxy.httpPort,
    [int]$Config.network.proxy.httpsPort,
    [int]$Config.network.proxy.loginListPort,
    [int]$Config.network.proxy.loginTcpPort,
    [int]$Config.network.proxy.gameTcpPort,
    [int]$Config.network.proxy.sceneSubPort
) | Select-Object -Unique

New-Item -ItemType Directory -Force -Path (Join-Path $ProxyDir 'logs') | Out-Null
Set-Location $ProxyDir

Write-Host "Starting Ananta-ps proxy with: $NodeExe"
Write-Host ("Config: {0}" -f $ConfigPath)
Write-Host ("Ports: {0}" -f (($ports | Sort-Object) -join ', '))
& $NodeExe 'server.js'
