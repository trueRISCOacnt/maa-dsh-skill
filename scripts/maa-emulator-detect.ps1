# maa-emulator-detect.ps1 - Detect installed emulators and locate them for MAA / maa-cli.
# Emulator brands follow MAA official docs (docs.maa.plus/manual/connection + device/windows):
#   fully supported: MuMu 12, LDPlayer 9, BlueStacks 5 (incl. global), Nox, MEmu
#   partial: MuMu 6 (legacy, manual config), WSA (legacy), AVD, Google Play Games (dev)
# Works with Windows PowerShell 5.1+ and PowerShell 7+.
# ASCII-only output on purpose (PS 5.1 without BOM would mangle non-ASCII).
#
# Usage:
#   pwsh -File maa-emulator-detect.ps1                     # auto detect from registry/processes/common paths
#   pwsh -File maa-emulator-detect.ps1 -Path "D:\Games\LDPlayer9"   # manual: locate emulator by install dir
#   pwsh -File maa-emulator-detect.ps1 -Adb "D:\x\adb.exe" -Address "127.0.0.1:5555"  # manual: explicit adb+address
#   pwsh -File maa-emulator-detect.ps1 -Probe              # also probe live ports (MuMuManager/adb connect; needs full sandbox access)
#
# Exit code: 0 = at least one emulator found; 1 = nothing found.

param(
    [string]$Path = "",      # manual: emulator install directory
    [string]$Adb = "",       # manual: adb executable path
    [string]$Address = "",   # manual: connection address, e.g. 127.0.0.1:16416 or emulator-5554
    [switch]$Probe           # probe live adb ports (spawns adb/MuMuManager; restricted sandbox blocks this)
)

$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Brand table (order = MAA official priority: MuMu, LDPlayer, BlueStacks, Nox, MEmu)
# Official auto-detect port lists from https://docs.maa.plus/zh-cn/manual/connection.html
# ---------------------------------------------------------------------------
$brands = @(
    @{ Name = 'MuMu Player 12';     Key = 'MuMu|Netease|MuMuPlayer';            Ports = @(16384,16416,16448,16480,16512,16544,16576); AdbNames = @('adb.exe');            AdbRel = @('nx_device\12.0\shell\adb.exe','shell\adb.exe','adb.exe') },
    @{ Name = 'LDPlayer 9';         Key = 'leidian|LDPlayer|dnplayer';          Ports = @(5555,5557,5559,5561);                         AdbNames = @('adb.exe');            AdbRel = @('adb.exe') },
    @{ Name = 'BlueStacks 5';       Key = 'BlueStacks';                         Ports = @(5555,5556,5565,5575,5585,5595,5554);         AdbNames = @('HD-Adb.exe');         AdbRel = @('HD-Adb.exe') },
    @{ Name = 'Nox';                Key = 'Nox|Yeshen|夜神';                    Ports = @(62001,59865);                               AdbNames = @('nox_adb.exe','adb.exe'); AdbRel = @('bin\nox_adb.exe','adb.exe') },
    @{ Name = 'MEmu';               Key = 'MEmu|Microvirt|逍遥';                Ports = @(21503);                                     AdbNames = @('adb.exe');            AdbRel = @('adb.exe') }
)

$commonRoots = @(
    "$env:ProgramFiles", "${env:ProgramFiles(x86)}", "D:\Program Files", "D:\Program Files (x86)",
    "$env:LOCALAPPDATA", "$env:ProgramData", "D:\", "C:\"
)

function Test-DirExists([string]$d) { return ($d -ne '' -and (Test-Path -LiteralPath $d -PathType Container)) }

function Find-AdbInDir([string]$dir, [hashtable]$brand) {
    foreach ($rel in $brand.AdbRel) {
        $p = Join-Path $dir $rel
        if (Test-Path -LiteralPath $p -PathType Leaf) { return $p }
    }
    # fallback: shallow search for brand adb names (depth 3)
    foreach ($name in $brand.AdbNames) {
        $hit = Get-ChildItem -LiteralPath $dir -Filter $name -File -Recurse -Depth 3 -ErrorAction SilentlyContinue |
               Select-Object -First 1 -ExpandProperty FullName
        if ($hit) { return $hit }
    }
    return ''
}

function Get-UninstallDirs() {
    $dirs = @{}
    $roots = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
               'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
               'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')
    foreach ($r in $roots) {
        Get-ItemProperty $r -ErrorAction SilentlyContinue | ForEach-Object {
            $dn = "$($_.DisplayName)"; $loc = "$($_.InstallLocation)"
            foreach ($b in $brands) {
                if ($dn -match $b.Key -and $loc -and (Test-Path -LiteralPath $loc)) {
                    $dirs[$loc] = $b.Name
                }
            }
        }
    }
    return $dirs
}

function Get-ProcessBrands() {
    $found = @{}
    $procs = Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    foreach ($p in $procs) {
        foreach ($b in $brands) {
            if ($p -match 'MuMuNx|MuMuPlayer|NemuPlayer' -and $b.Name -like 'MuMu*') { $found[$b.Name] = $true }
            if ($p -match 'dnplayer|LDPlayer' -and $b.Name -like 'LD*') { $found[$b.Name] = $true }
            if ($p -match 'HD-Player|BlueStacks' -and $b.Name -like 'Blue*') { $found[$b.Name] = $true }
            if ($p -match '^Nox' -and $b.Name -eq 'Nox') { $found[$b.Name] = $true }
            if ($p -match '^MEmu' -and $b.Name -eq 'MEmu') { $found[$b.Name] = $true }
        }
    }
    return $found
}

# ---------------------------------------------------------------------------
# Manual mode: -Path or -Adb
# ---------------------------------------------------------------------------
if ($Adb) {
    if (-not (Test-Path -LiteralPath $Adb)) { Write-Host "ERROR: adb not found: $Adb"; exit 1 }
    $brand = $brands[0]
    $portList = ($brand.Ports | ForEach-Object { "127.0.0.1:$_" }) -join '/'
    Write-Host "[manual] adb: $Adb"
    Write-Host "[manual] address: $Address (leave empty; use 'adb devices' or emulator docs)"
    Write-Host ""
    Write-Host "Suggested profile (profiles/default.toml):"
    Write-Host "[connection]"
    Write-Host "adb_path = `"$($Adb -replace '\\','/')`""
    if ($Address) { Write-Host "address = `"$Address`"" }
    Write-Host "config = `"General`""
    exit 0
}

if ($Path) {
    if (-not (Test-DirExists $Path)) { Write-Host "ERROR: directory not found: $Path"; exit 1 }
    $brand = $null
    foreach ($b in $brands) { if ($Path -match $b.Key) { $brand = $b; break } }
    if (-not $brand) { $brand = $brands[0]; Write-Host "[manual] brand not recognized from path, assuming generic; check adb below." }
    $adbPath = Find-AdbInDir $Path $brand
    if (-not $adbPath) {
        Write-Host "ERROR: no adb found under $Path (looked for: $($brand.AdbNames -join ', '))"
        Write-Host "Hint: emulator adb names per MAA docs: adb.exe / HD-adb.exe / adb_server.exe / nox_adb.exe"
        exit 1
    }
    $portList = ($brand.Ports | ForEach-Object { "127.0.0.1:$_" }) -join '/'
    Write-Host "[manual] brand: $($brand.Name)"
    Write-Host "[manual] install dir: $Path"
    Write-Host "[manual] adb: $adbPath"
    Write-Host "[manual] official ports: $portList"
    Write-Host ""
    Write-Host "Suggested profile (profiles/default.toml):"
    Write-Host "[connection]"
    Write-Host "adb_path = `"$($adbPath -replace '\\','/')`""
    if ($Address) { Write-Host "address = `"$Address`"" }
    Write-Host "config = `"General`""
    exit 0
}

# ---------------------------------------------------------------------------
# Auto detect mode
# ---------------------------------------------------------------------------
Write-Host "=== Emulator Detection (MAA official priority: MuMu > LDPlayer > BlueStacks > Nox > MEmu) ==="

$running = Get-ProcessBrands
$uninstall = Get-UninstallDirs
$results = @()   # @{ Brand=...; Dir=...; Running=...; Adb=... }

foreach ($b in $brands) {
    $dir = ''
    # 1) uninstall registry location
    foreach ($k in $uninstall.Keys) { if ($uninstall[$k] -eq $b.Name) { $dir = $k; break } }
    # 2) common roots x brand name patterns
    if (-not $dir) {
        $patterns = switch ($b.Name) {
            'MuMu Player 12' { @('Netease\MuMu Player 12','Netease\MuMuPlayerGlobal-12.0','Netease\YXArknights-12.0','Netease\MuMuPlayer-12.0') }
            'LDPlayer 9'     { @('leidian\LDPlayer9','LDPlayer\LDPlayer9') }
            'BlueStacks 5'   { @('BlueStacks_nxt','BlueStacks_nxt_cn') }
            'Nox'            { @('Nox','Program Files\Nox') }
            'MEmu'           { @('Microvirt') }
            default          { @() }
        }
        foreach ($root in $commonRoots) {
            foreach ($pat in $patterns) {
                $p = Join-Path $root $pat
                if (Test-DirExists $p) { $dir = $p; break }
            }
            if ($dir) { break }
        }
    }

    $isRunning = $running.ContainsKey($b.Name)
    $adbPath = ''
    if ($dir) { $adbPath = Find-AdbInDir $dir $b }

    if ($dir -or $isRunning) {
        $results += @{ Brand = $b.Name; Dir = $dir; Running = $isRunning; Adb = $adbPath; Ports = $b.Ports; Key = $b.Key }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No emulator detected."
    Write-Host "Hint: run with -Path <emulator install dir> or -Adb <adb.exe path> to locate manually."
    Write-Host "MAA officially supports (Windows): MuMu 12, LDPlayer 9, BlueStacks 5 (global too), Nox, MEmu."
    exit 1
}

# Probe a single adb port with a timeout (Start-Job; no .NET static calls, PS 5.1 safe)
function Test-AdbPort([string]$adb, [int]$port, [int]$timeoutSec = 8) {
    $job = Start-Job -ScriptBlock { param($a, $p) & $a connect "127.0.0.1:$p" 2>&1 } -ArgumentList $adb, $port
    if (Wait-Job $job -Timeout $timeoutSec) {
        $out = Receive-Job $job -ErrorAction SilentlyContinue
        Remove-Job $job -Force -ErrorAction SilentlyContinue
        return (($out -join ' ') -match 'connected')
    }
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -Force -ErrorAction SilentlyContinue
    return $false
}

$i = 0
foreach ($r in $results) {
    $i++
    $portList = ($r.Ports | ForEach-Object { "127.0.0.1:$_" }) -join '/'
    Write-Host ""
    Write-Host "[$i] Brand: $($r.Brand) $(if ($r.Running) { '(RUNNING)' } else { '(not running)' })"
    if ($r.Dir)  { Write-Host "    InstallDir: $($r.Dir)" }
    if ($r.Adb)  { Write-Host "    Adb: $($r.Adb)" } else { Write-Host "    Adb: (not found - locate adb manually)" }
    Write-Host "    Official ports: $portList"

    $androidUp = $false
    # live probe (needs full sandbox access: spawns processes)
    if ($Probe) {
        if ($r.Brand -like 'MuMu*' -and $r.Dir) {
            $mgr = Join-Path $r.Dir 'nx_main\MuMuManager.exe'
            if (Test-Path -LiteralPath $mgr) {
                Write-Host "    [probe] MuMuManager info:"
                try {
                    $json = & $mgr info -v all 2>$null | Out-String
                    $parsed = $json | ConvertFrom-Json
                    foreach ($prop in $parsed.PSObject.Properties) {
                        $inst = $prop.Value
                        if ($inst.is_android_started) { $androidUp = $true }
                        Write-Host "      instance '$($inst.name)' (idx $($prop.Name)) adb_port=$($inst.adb_port) running=$($inst.is_android_started)"
                    }
                } catch { Write-Host "      (MuMuManager query failed: $($_.Exception.Message))" }
            }
        }
        # only probe adb ports when the emulator is plausibly up
        if ($r.Adb -and ($r.Running -or $androidUp)) {
            foreach ($port in $r.Ports) {
                if (Test-AdbPort $r.Adb $port) {
                    Write-Host "    [probe] adb connect 127.0.0.1:$port -> connected"
                    if (-not $script:livePort) { $script:livePort = $port }
                    break
                }
            }
        } elseif ($r.Adb) {
            Write-Host "    [probe] emulator not running, skipped adb port probing"
        }
    }
}

# ---------------------------------------------------------------------------
# Suggest a profile for the first (highest priority) found emulator
# ---------------------------------------------------------------------------
$first = $results[0]
Write-Host ""
Write-Host "Suggested profile (profiles/default.toml) for $($first.Brand):"
Write-Host "[connection]"
if ($first.Adb) { Write-Host "adb_path = `"$($first.Adb -replace '\\','/')`"" }
if ($script:livePort) { Write-Host "address = `"127.0.0.1:$($script:livePort)`"" }
Write-Host "config = `"General`""
Write-Host ""
Write-Host "Notes:"
Write-Host "  - BlueStacks 5: enable 'ADB connection' in emulator settings; Hyper-V may change port per boot (see MAA docs)."
Write-Host "  - MuMu 12: port may differ per instance (multi-open); use MuMuManager or -Probe to get the real one."
Write-Host "  - The suggested port is from MAA official auto-detect list; verify with 'adb devices' if connection fails."
exit 0
