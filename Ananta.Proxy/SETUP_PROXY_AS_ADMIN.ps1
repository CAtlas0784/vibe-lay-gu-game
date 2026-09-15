$ErrorActionPreference = 'Stop'

trap {
    $logDir = Join-Path $PSScriptRoot 'proxy\logs'
    $logPath = Join-Path $logDir 'setup-error.log'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    ($_ | Out-String) | Set-Content -LiteralPath $logPath -Encoding UTF8
    Write-Host "Proxy setup failed. Details: $logPath" -ForegroundColor Red
    Write-Host ($_ | Out-String) -ForegroundColor Red
    exit 1
}

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
if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing config: $ConfigPath" }
$Config = Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json
$ProxyDir = Join-Path $Root 'proxy'
$CertDir = Join-Path $ProxyDir 'certs'
$BackupDir = Join-Path $ProxyDir 'backups'
$HostsPath = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
$DnsName = [string]$Config.network.proxy.updateHost
$PassPlain = [string]$Config.network.proxy.certificatePassphrase

$Domains = @(
    $DnsName,
    'serverlist-test.l50.leihuo.netease.com',
    'l50.gdl.netease.com',
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

New-Item -ItemType Directory -Force -Path $CertDir, $BackupDir | Out-Null

Write-Host '[1/3] Preparing local proxy CA and TLS certificate...'
$RootSubject = 'CN=Ananta Local Proxy Root'
$RootCerPath = Join-Path $CertDir 'Ananta-local-root.cer'
$CerPath = Join-Path $CertDir "$DnsName.cer"
$PfxPath = Join-Path $CertDir "$DnsName.pfx"
$SecurePass = ConvertTo-SecureString -String $PassPlain -AsPlainText -Force

# Older builds used one self-signed CA=TRUE certificate as both trust anchor and
# HTTPS server certificate. Unity's early downloader accepts that, while a later
# HTTP stack can reject it during the same boot. Remove only that old Ananta-style
# self-signed leaf from the machine root store before creating a normal chain.
foreach ($old in @(Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue | Where-Object {
    $_.Subject -eq "CN=$DnsName" -and $_.Issuer -eq "CN=$DnsName"
})) {
    try { Remove-Item -LiteralPath ("Cert:\LocalMachine\Root\{0}" -f $old.Thumbprint) -Force -ErrorAction SilentlyContinue } catch { }
}

# Reuse one persistent local CA instead of changing trust identity every launch.
$rootCert = Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Subject -eq $RootSubject -and $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date).AddDays(7)
    } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

if (-not $rootCert) {
    $rootCert = New-SelfSignedCertificate `
        -Type Custom `
        -Subject $RootSubject `
        -FriendlyName 'Ananta Local Proxy Root' `
        -CertStoreLocation 'Cert:\LocalMachine\My' `
        -KeyAlgorithm RSA `
        -KeyLength 3072 `
        -HashAlgorithm SHA256 `
        -KeyExportPolicy Exportable `
        -KeyUsage CertSign,CRLSign,DigitalSignature `
        -NotBefore (Get-Date).AddMinutes(-10) `
        -NotAfter (Get-Date).AddYears(5) `
        -TextExtension @('2.5.29.19={critical}{text}ca=1&pathlength=1')
}

Export-Certificate -Cert $rootCert -FilePath $RootCerPath -Force | Out-Null
$trustedRoot = Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue |
    Where-Object { $_.Thumbprint -eq $rootCert.Thumbprint } |
    Select-Object -First 1
if (-not $trustedRoot) {
    Import-Certificate -FilePath $RootCerPath -CertStoreLocation 'Cert:\LocalMachine\Root' | Out-Null
}

# Always refresh only the leaf. It is CA=FALSE, carries the complete SAN set and
# is signed by the stable Ananta root above. This is the normal chain expected by
# stricter TLS clients.
$leaf = New-SelfSignedCertificate `
    -Type Custom `
    -Subject "CN=$DnsName" `
    -FriendlyName 'Ananta Local HTTPS Proxy' `
    -DnsName (($Domains + 'localhost') | Select-Object -Unique) `
    -Signer $rootCert `
    -CertStoreLocation 'Cert:\LocalMachine\My' `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -HashAlgorithm SHA256 `
    -KeyExportPolicy Exportable `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -NotBefore (Get-Date).AddMinutes(-10) `
    -NotAfter (Get-Date).AddDays(120) `
    -TextExtension @(
        '2.5.29.19={critical}{text}ca=0',
        '2.5.29.37={text}1.3.6.1.5.5.7.3.1'
    )

Export-Certificate -Cert $leaf -FilePath $CerPath -Force | Out-Null
Export-PfxCertificate -Cert $leaf -FilePath $PfxPath -Password $SecurePass -ChainOption BuildChain -Force | Out-Null

# The proxy only needs the exported leaf PFX; keep the CA private key for future
# leaf renewal but remove the redundant leaf copy from LocalMachine\My.
try { Remove-Item -LiteralPath ("Cert:\LocalMachine\My\{0}" -f $leaf.Thumbprint) -Force -ErrorAction SilentlyContinue } catch { }

Write-Host '[2/3] Checking hosts entries...'

$hostsExisted = Test-Path -LiteralPath $HostsPath
$lines = if ($hostsExisted) { @(Get-Content -LiteralPath $HostsPath -ErrorAction Stop) } else { @() }
# Keep every line that is NOT one of our managed-domain entries (preserves the
# user's own custom hosts entries untouched).
$kept = foreach ($line in $lines) {
    $managed = $false
    $trimmed = ([string]$line).Trim()
    if ($trimmed -and -not $trimmed.StartsWith('#')) {
        # Remove any pre-existing mapping for one of our managed domains,
        # regardless of IP (127.0.0.1, ::1, stale LAN/VPN address, etc.).
        # Duplicate/conflicting hosts entries are enough to send UniSDK to the
        # real mgbsdk endpoint and produce login code 220.
        $tokens = @($trimmed -split '\s+' | Where-Object { $_ -and -not $_.StartsWith('#') })
        if ($tokens.Count -ge 2) {
            foreach ($domain in $Domains) {
                if ($tokens[1..($tokens.Count - 1)] -contains $domain) {
                    $managed = $true
                    break
                }
            }
        }
    }
    if (-not $managed) { $line }
}

$out = @($kept)
foreach ($domain in $Domains) {
    $out += "127.0.0.1 $domain # Ananta-ps local proxy"
}

# IDEMPOTENT: only touch the hosts file if it would actually change. This stops the
# "rewrite + new backup + flushdns on every run" behavior. Compare the would-be
# content against the current content (ignoring trailing blank lines / CRLF).
$desired = ($out -join "`n").TrimEnd()
$currentContent = (($lines -join "`n")).TrimEnd()

if ($desired -eq $currentContent) {
    Write-Host '   hosts entries are already correct - no changes and no new backup.'
} else {
    # Back up ONCE per distinct previous state (skip if an identical backup already exists).
    $existingBackups = Get-ChildItem -Path $BackupDir -Filter 'hosts-before-Ananta-*.txt' -ErrorAction SilentlyContinue
    $alreadyBackedUp = $false
    foreach ($b in $existingBackups) {
        if (((Get-Content -LiteralPath $b.FullName -Raw -ErrorAction SilentlyContinue)).TrimEnd() -eq $currentContent) {
            $alreadyBackedUp = $true; break
        }
    }
    if ($hostsExisted -and -not $alreadyBackedUp) {
        $backup = Join-Path $BackupDir ("hosts-before-Ananta-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        Copy-Item -LiteralPath $HostsPath -Destination $backup -Force
        Write-Host "   Hosts backup: $backup"
    } elseif (-not $hostsExisted) {
        Write-Host "   Hosts file did not exist and will be created: $HostsPath"
    }
    Set-Content -LiteralPath $HostsPath -Value $out -Encoding ASCII
    ipconfig /flushdns | Out-Null
    Write-Host '   hosts entries updated.'
}

Write-Host '[3/3] Done.'
Write-Host "Certificate: $CerPath"
Write-Host 'Setup ready. START.cmd will continue automatically.'
