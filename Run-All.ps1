$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $Root 'config\private-server.json'
$ProxyRoot = Join-Path $Root 'Ananta.Proxy'
$ProxyDir = Join-Path $ProxyRoot 'proxy'
$ServerProject = Join-Path $Root 'Ananta.Server\Ananta.App\Ananta.App.csproj'
$HostsPath = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'

$script:ConsoleLogLatest = $null
$script:ConsoleLogArchive = $null

function Append-RunLog([string]$Text) {
    if (-not $script:ConsoleLogLatest) { return }
    $line = $Text + [Environment]::NewLine
    try { [System.IO.File]::AppendAllText($script:ConsoleLogLatest, $line, [System.Text.UTF8Encoding]::new($false)) } catch { }
    try { [System.IO.File]::AppendAllText($script:ConsoleLogArchive, $line, [System.Text.UTF8Encoding]::new($false)) } catch { }
}

function Status([string]$Text, [System.ConsoleColor]$Color = [System.ConsoleColor]::Gray) {
    Microsoft.PowerShell.Utility\Write-Host $Text -ForegroundColor $Color
    Append-RunLog $Text
}

function Fail([string]$Text) {
    Status "[ERROR] $Text" Red
    if ($script:ConsoleLogLatest) { Status "[LOG] $script:ConsoleLogLatest" DarkGray }
    exit 1
}

function Test-AnantaAdministrator {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-Exe([string]$EnvName, [string]$CommandName, [string[]]$Fallbacks = @()) {
    $fromEnv = [Environment]::GetEnvironmentVariable($EnvName)
    if ($fromEnv -and (Test-Path -LiteralPath $fromEnv)) { return $fromEnv }
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($candidate in $Fallbacks) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }
    return $null
}

function Quote-WindowsProcessArgument([string]$Value) {
    if ($null -eq $Value) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }
    $escaped = [System.Text.RegularExpressions.Regex]::Replace($Value, '(\\*)"', '$1$1\\"')
    $escaped = [System.Text.RegularExpressions.Regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-SilentNative {
    param([string]$FilePath, [string[]]$Arguments, [string]$WorkingDirectory)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.WorkingDirectory = if ($WorkingDirectory) { $WorkingDirectory } else { $Root }
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    try { $psi.StandardOutputEncoding = $utf8 } catch { }
    try { $psi.StandardErrorEncoding = $utf8 } catch { }
    $psi.Arguments = (($Arguments | ForEach-Object { Quote-WindowsProcessArgument ([string]$_) }) -join ' ')

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    if (-not $process.Start()) { return 1 }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    foreach ($text in @($stdoutTask.Result, $stderrTask.Result)) {
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        foreach ($line in ($text -split "`r?`n")) {
            if ($line.Length -gt 0) { Append-RunLog $line }
        }
    }
    return $process.ExitCode
}

function Stop-StaleAnantaProcesses {
    foreach ($proc in @(Get-Process -Name 'Ananta.App' -ErrorAction SilentlyContinue)) {
        try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch { }
    }
    try {
        $proxyServerJs = [System.IO.Path]::GetFullPath((Join-Path $ProxyDir 'server.js'))
        foreach ($proc in @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue)) {
            $cmd = [string]$proc.CommandLine
            if ($cmd -and ($cmd.IndexOf($proxyServerJs, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)) {
                try { Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue } catch { }
            }
        }
    } catch { }
    Start-Sleep -Milliseconds 200
}

# START.cmd remains the only launcher. Elevate once for certificate/hosts setup and ports 80/443.
if (-not (Test-AnantaAdministrator)) {
    $psExe = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $psExe)) { $psExe = 'powershell.exe' }
    try {
        $elevated = Start-Process -FilePath $psExe -Verb RunAs -ArgumentList ('-NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '"') -WorkingDirectory $Root -Wait -PassThru
        exit $elevated.ExitCode
    } catch {
        Microsoft.PowerShell.Utility\Write-Host "[ERROR] administrator launch failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

$ExampleConfigPath = Join-Path $Root 'config\private-server.example.json'
foreach ($required in @(
    $ServerProject,
    (Join-Path $ProxyDir 'server.js'),
    (Join-Path $ProxyDir 'package.json'),
    (Join-Path $ProxyDir 'tools\generate_client_config_patch.js'),
    $ExampleConfigPath,
    (Join-Path $Root 'Ananta.Server\ClientData\4229938\MethodIds.json'),
    (Join-Path $Root 'Ananta.Server\ClientData\4229938\RpcSurface.json')
)) {
    if (-not (Test-Path -LiteralPath $required)) { Fail "server package is incomplete: $required" }
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Copy-Item -LiteralPath $ExampleConfigPath -Destination $ConfigPath
}
try { $Config = Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath | ConvertFrom-Json }
catch { Fail "invalid config/private-server.json: $($_.Exception.Message)" }

$RunId = Get-Date -Format 'yyyyMMdd-HHmmss'
$LogDir = [string]$Config.logging.directory
if ([string]::IsNullOrWhiteSpace($LogDir)) { $LogDir = 'logs' }
if (-not [System.IO.Path]::IsPathRooted($LogDir)) { $LogDir = Join-Path $Root $LogDir }
$LogDir = [System.IO.Path]::GetFullPath($LogDir)
[System.IO.Directory]::CreateDirectory($LogDir) | Out-Null
$ConsoleLoggingEnabled = [bool]$Config.logging.console.enabled
$PacketLoggingEnabled = [bool]$Config.logging.packets.enabled
$script:ConsoleLogLatest = $null
$script:ConsoleLogArchive = $null

if ($ConsoleLoggingEnabled) {
    $script:ConsoleLogLatest = Join-Path $LogDir 'console-latest.log'
    $script:ConsoleLogArchive = Join-Path $LogDir ("console-{0}.log" -f $RunId)
    foreach ($file in @($script:ConsoleLogLatest, $script:ConsoleLogArchive)) {
        [System.IO.File]::WriteAllText($file, '', [System.Text.UTF8Encoding]::new($false))
    }
    $env:Ananta_CONSOLE_LOG_LATEST = $script:ConsoleLogLatest
    $env:Ananta_CONSOLE_LOG_ARCHIVE = $script:ConsoleLogArchive
} else {
    Remove-Item Env:Ananta_CONSOLE_LOG_LATEST -ErrorAction SilentlyContinue
    Remove-Item Env:Ananta_CONSOLE_LOG_ARCHIVE -ErrorAction SilentlyContinue
}

$PacketLogLatest = $null
$PacketLogArchive = $null
if ($PacketLoggingEnabled) {
    $PacketLogLatest = Join-Path $LogDir 'packets-latest.log'
    $PacketLogArchive = Join-Path $LogDir ("packets-{0}.log" -f $RunId)
    foreach ($file in @($PacketLogLatest, $PacketLogArchive)) {
        [System.IO.File]::WriteAllText($file, '', [System.Text.UTF8Encoding]::new($false))
    }
    $env:Ananta_PACKET_LOG_LATEST = $PacketLogLatest
    $env:Ananta_PACKET_LOG_ARCHIVE = $PacketLogArchive
} else {
    Remove-Item Env:Ananta_PACKET_LOG_LATEST -ErrorAction SilentlyContinue
    Remove-Item Env:Ananta_PACKET_LOG_ARCHIVE -ErrorAction SilentlyContinue
}
$env:Ananta_RUN_ID = $RunId
$env:Ananta_LOG_DIR = $LogDir
$env:Ananta_LOGS_PREPARED = '1'

# Preserve the useful bootstrap diagnostics in the normal log files without printing them.
$consoleDisplay = if ($ConsoleLoggingEnabled) { $script:ConsoleLogLatest } else { 'disabled' }
$packetDisplay = if ($PacketLoggingEnabled) { $PacketLogLatest } else { 'disabled' }
Append-RunLog '[START] launching standalone bootstrap...'
Append-RunLog ("[LOGS] console={0} | packets={1}" -f $consoleDisplay, $packetDisplay)
Append-RunLog ("[BUILD] Ananta Private Server | client {0} | world-entry + switching + buffs/combat" -f $Config.client.version)
Append-RunLog "[CONFIG] $ConfigPath"
Append-RunLog "[CONFIG] pid=$($Config.player.pid) spirit=$($Config.player.initialSpiritTemplateId) raid=$($Config.world.raidId)"

$env:Ananta_CONFIG = $ConfigPath
$env:Ananta_ROOT = $Root
$env:Ananta_COMPACT_LOG = '1'
$env:Ananta_HIDE_BOOT_LOG = '1'
Remove-Item Env:Ananta_QUIET_CONSOLE -ErrorAction SilentlyContinue
$env:DOTNET_CLI_UI_LANGUAGE = 'en-US'
$env:DOTNET_NOLOGO = '1'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'


$NodeExe = Find-Exe 'Ananta_NODE_EXE' 'node' @('C:\Program Files\nodejs\node.exe')
if (-not $NodeExe) { Fail 'Node.js was not found. Install Node.js LTS.' }
$DotnetExe = Find-Exe 'Ananta_DOTNET_EXE' 'dotnet'
if (-not $DotnetExe) { Fail '.NET 8 SDK was not found.' }

$FengariPackage = Join-Path $ProxyDir 'node_modules\fengari\package.json'
if (-not (Test-Path -LiteralPath $FengariPackage)) {
    $NpmExe = Find-Exe 'Ananta_NPM_EXE' 'npm.cmd' @((Join-Path (Split-Path -Parent $NodeExe) 'npm.cmd'))
    if (-not $NpmExe) { Fail 'Node dependencies are missing and npm.cmd was not found.' }
    if ((Invoke-SilentNative $NpmExe @('ci', '--ignore-scripts', '--no-audit', '--no-fund') $ProxyDir) -ne 0) {
        Fail 'npm dependency restore failed'
    }
}
if (-not (Test-Path -LiteralPath $FengariPackage)) { Fail 'fengari dependency is missing.' }
Append-RunLog '[NODE] exact Lua serializer dependency OK (fengari)'

Stop-StaleAnantaProcesses

$DnsName = [string]$Config.network.proxy.updateHost
$PfxPath = Join-Path $ProxyDir ("certs\{0}.pfx" -f $DnsName)
$PfxPassphrase = [string]$Config.network.proxy.certificatePassphrase

# The login screen depends on more than the update CDN. In particular,
# mgbsdk.matrix.netease.com must resolve to the local HTTPS proxy; otherwise
# UniSDK's /sdk/uni_sauth request reaches the real service and the client stops
# at the menu with login code 220. Validate the whole runtime redirect set.
$RequiredProxyDomains = @(
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
) | Select-Object -Unique

$hostsOk = Test-Path -LiteralPath $HostsPath
if ($hostsOk) {
    $hostLines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
    foreach ($domain in $RequiredProxyDomains) {
        $pattern = '^\s*127\.0\.0\.1\s+' + [regex]::Escape($domain) + '(?:\s|$)'
        if (-not ($hostLines | Where-Object { $_ -match $pattern })) {
            $hostsOk = $false
            break
        }
    }
}

$certOk = $false
if (Test-Path -LiteralPath $PfxPath) {
    try {
        $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($PfxPath, $PfxPassphrase)
        $trustedRoot = Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue | Where-Object { $_.Subject -eq 'CN=Ananta Local Proxy Root' }
        # Require the new normal root->leaf chain. Old packages used a self-signed
        # CA=TRUE server certificate, which a later client TLS stack can reject.
        $certOk = (
            $pfx.NotAfter -gt (Get-Date).AddHours(1) -and
            $pfx.Subject -eq ("CN={0}" -f $DnsName) -and
            $pfx.Issuer -eq 'CN=Ananta Local Proxy Root' -and
            $null -ne $trustedRoot
        )
        $pfx.Dispose()
    } catch { $certOk = $false }
}
if (-not $certOk -or -not $hostsOk) {
    Append-RunLog '[PROXY] repairing certificate/hosts redirects for login services'
    $setupScript = Join-Path $ProxyRoot 'SETUP_PROXY_AS_ADMIN.ps1'
    if (-not (Test-Path -LiteralPath $setupScript)) { Fail 'proxy setup script is missing' }
    if ((Invoke-SilentNative 'powershell.exe' @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setupScript) $Root) -ne 0) {
        Fail 'certificate/hosts setup failed'
    }
}

# Fail early instead of opening a client that can only reach the menu.
$hostLines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
foreach ($domain in @('serverlist-test.l50.leihuo.netease.com','l50.gdl.netease.com','service.mkey.163.com','mgbsdk.matrix.netease.com')) {
    $pattern = '^\s*127\.0\.0\.1\s+' + [regex]::Escape($domain) + '(?:\s|$)'
    if (-not ($hostLines | Where-Object { $_ -match $pattern })) {
        Fail "local proxy redirect is missing for $domain"
    }
}

# Generate the only client Lua override: UID/watermark branding.
Append-RunLog '[1/3] fastpatch + startup checks'
if ((Invoke-SilentNative $NodeExe @('.\tools\generate_client_config_patch.js') $ProxyDir) -ne 0) {
    Fail 'fastpatch generation failed'
}
$FastPatchPath = Join-Path $ProxyDir ("public\fastpatch_{0}.zip" -f $Config.client.version)
$RuntimeFastPatchRoot = [string]$Config.paths.runtimeFastpatch
if (-not [System.IO.Path]::IsPathRooted($RuntimeFastPatchRoot)) { $RuntimeFastPatchRoot = Join-Path $Root $RuntimeFastPatchRoot }
$FastPatchSource = Join-Path $RuntimeFastPatchRoot ([string]$Config.client.version)
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    $temp = "$FastPatchPath.tmp"
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($FastPatchSource, $temp, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    if (Test-Path -LiteralPath $FastPatchPath) { Remove-Item -LiteralPath $FastPatchPath -Force }
    Move-Item -LiteralPath $temp -Destination $FastPatchPath
} catch { Fail "cannot build fastpatch: $($_.Exception.Message)" }

# Clean rebuild; output goes to logs instead of filling the console.
Append-RunLog '[2/3] build (clean)'
$cleanDirs = @(Get-ChildItem -LiteralPath (Join-Path $Root 'Ananta.Server') -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('bin','obj') } | Select-Object -ExpandProperty FullName)
$cleanDirs += @((Join-Path $Root 'Ananta.SDK\bin'), (Join-Path $Root 'Ananta.SDK\obj'))
foreach ($dir in $cleanDirs | Select-Object -Unique) {
    if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
}
if ((Invoke-SilentNative $DotnetExe @('build', $ServerProject, '--nologo', '-v:q') $Root) -ne 0) {
    Fail 'server build failed'
}

$wantedPorts = @(
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
try {
    $busy = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $wantedPorts -contains $_.LocalPort })
    if ($busy.Count -gt 0) {
        $desc = ($busy | Sort-Object LocalPort -Unique | ForEach-Object { ":$($_.LocalPort) pid=$($_.OwningProcess)" }) -join ', '
        Fail "ports already in use: $desc"
    }
} catch { }


Append-RunLog '[3/3] start'
Append-RunLog '[OK] one console | Ctrl+C stops the stack'

# All bootstrap diagnostics were already written to the normal console log files.
# Keep the interactive window clean and let only runtime traffic appear from this point on.
try { Clear-Host } catch { }
try { $Host.UI.RawUI.WindowTitle = 'Ananta 4229938 Private Server' } catch { }

$proxy = $null
$serverExit = 0
try {
    $proxy = Start-Process -FilePath $NodeExe -ArgumentList @('server.js') -WorkingDirectory $ProxyDir -NoNewWindow -PassThru
    Start-Sleep -Milliseconds 500
    if ($proxy.HasExited) { Fail "proxy exited with code $($proxy.ExitCode)" }

    & $DotnetExe run --no-build --project $ServerProject
    $serverExit = $LASTEXITCODE
} finally {
    if ($proxy -and -not $proxy.HasExited) {
        try { Stop-Process -Id $proxy.Id -Force -ErrorAction SilentlyContinue } catch { }
    }
    Stop-StaleAnantaProcesses
    Append-RunLog '[STOP] Ananta stack stopped'
}
if ($serverExit -ne 0) { exit $serverExit }
