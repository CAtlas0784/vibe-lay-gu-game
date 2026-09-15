$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $Root
$ConfigPath = Join-Path $ProjectRoot 'config\private-server.json'
if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing config: $ConfigPath" }
$Config = Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json

$ports = @(
    [int]$Config.network.proxy.httpPort,
    [int]$Config.network.proxy.httpsPort,
    [int]$Config.network.proxy.loginListPort,
    [int]$Config.network.proxy.loginTcpPort,
    [int]$Config.network.proxy.gameTcpPort,
    [int]$Config.network.proxy.sceneSubPort,
    [int]$Config.network.loginPorts[0],
    [int]$Config.network.loginPorts[1],
    [int]$Config.network.gamePort
) | Select-Object -Unique

Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in $ports } |
    Select-Object LocalAddress,LocalPort,OwningProcess,@{Name='Process';Expression={
        try { (Get-Process -Id $_.OwningProcess -ErrorAction Stop).ProcessName } catch { '?' }
    }} |
    Sort-Object LocalPort |
    Format-Table -AutoSize
