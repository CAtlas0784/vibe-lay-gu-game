$ErrorActionPreference = 'Stop'

function Require-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($id)
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script as Administrator.'
    }
}

Require-Admin

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $Root
$ConfigPath = Join-Path $ProjectRoot 'config\private-server.json'
$BackupDir = Join-Path $Root 'proxy\backups'
$HostsPath = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
$DnsName = $null
if (Test-Path -LiteralPath $ConfigPath) {
    try { $DnsName = [string]((Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json).network.proxy.updateHost) } catch { }
}
if ([string]::IsNullOrWhiteSpace($DnsName)) { throw 'Cannot read network.proxy.updateHost from config/private-server.json.' }

$Domains = @(
    $DnsName,
    'l50.gph.netease.com',
    'l50.gsgph.netease.com',
    'service.mkey.163.com',
    'qatest.g.mkey.163.com',
    'qatest-1.g.mkey.163.com',
    'qatest-2.g.mkey.163.com',
    'qatest-3.g.mkey.163.com',
    'qatest-4.g.mkey.163.com',
    'qatest-5.g.mkey.163.com',
    'qatest-6.g.mkey.163.com',
    'qatest-7.g.mkey.163.com',
    'qatest-8.g.mkey.163.com',
    'bind-mobile.g.mkey.163.com',
    'bind-mobile-test.g.mkey.163.com',
    'mpay-common-server.g.mkey.163.com',
    'mpay-common-server-test.g.mkey.163.com',
    'mpay-personal-privacy-protection.g.mkey.163.com',
    'mpay-personal-privacy-protection-dev.g.mkey.163.com',
    'whoami.nie.netease.com',
    'whoami.nie.easebar.com',
    'protocol.unisdk.netease.com',
    'tpsl.nie.netease.com',
    'g0.gsf.netease.com',
    'g0.gsf.easebar.com',
    'mcount.easebar.com',
    'analytics.mpay.netease.com',
    'applog.matrix.netease.com',
    'applog.matrix.easebar.com',
    'mgbsdktest.matrix.netease.com',
    'mgbsdk.matrix.netease.com',
    'mgbsdk.matrix.easebar.com',
    'dns.update.netease.com',
    'dns.update.easebar.com',
    'openapi.music.163.com'
)

New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$backup = Join-Path $BackupDir ("hosts-before-remove-Ananta-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Copy-Item -LiteralPath $HostsPath -Destination $backup -Force

$lines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
$kept = foreach ($line in $lines) {
    $managed = $false
    foreach ($domain in $Domains) {
        if ($line -match "^\s*#?\s*127\.0\.0\.1\s+$([regex]::Escape($domain))(\s|$)") {
            $managed = $true
            break
        }
    }
    if (-not $managed) { $line }
}

Set-Content -LiteralPath $HostsPath -Value $kept -Encoding ASCII
ipconfig /flushdns | Out-Null

Write-Host "Ananta-ps hosts entries removed. Backup: $backup"
