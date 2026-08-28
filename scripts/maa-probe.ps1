# maa-probe.ps1 - Probe maa-cli / MaaCore installation status.
# Works with Windows PowerShell 5.1+ and PowerShell 7+.
# Usage: pwsh -File maa-probe.ps1   (or: powershell -File maa-probe.ps1)
# Exit code: 0 = a usable maa binary was found; 1 = not installed.
# NOTE: ASCII-only on purpose, so the file parses correctly on any Windows
# PowerShell without a UTF-8 BOM.

$ErrorActionPreference = 'Stop'

# 1) Locate the binary (winget installs `maa-cli`, other installers `maa`).
$bin = $null
foreach ($name in @('maa', 'maa-cli')) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { $bin = $cmd.Source; break }
}

if (-not $bin) {
    Write-Host "[probe] maa-cli is NOT installed. See SKILL.md section 3 for install options:"
    Write-Host "  winget install maa-cli      # Windows (binary name is maa-cli)"
    Write-Host "  or run the install script:  https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/main/install.ps1"
    exit 1
}

Write-Host "[probe] binary: $bin"
$exe = Split-Path $bin -Leaf

# 2) Version (fails if MaaCore is missing; capture separately).
Write-Host "--- version ---"
& $exe version 2>&1 | ForEach-Object { Write-Host "  $_" }
if ($LASTEXITCODE -ne 0) {
    Write-Host "[probe] note: MaaCore may not be installed. Run: $exe install" -ForegroundColor Yellow
}

# 3) Key directories.
Write-Host "--- directories ---"
foreach ($d in @('config', 'log', 'data')) {
    $out = & $exe dir $d 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  $d -> $out" }
}

# 4) Available tasks.
Write-Host "--- tasks (maa list) ---"
& $exe list 2>&1 | ForEach-Object { Write-Host "  $_" }

# 5) Relevant environment variables.
Write-Host "--- env ---"
foreach ($v in @('MAA_CONFIG_DIR', 'MAA_LOG', 'MAA_LOG_PREFIX')) {
    $val = [Environment]::GetEnvironmentVariable($v)
    if ($val) { Write-Host "  $v=$val" }
}

Write-Host "[probe] done. See SKILL.md section 9 for troubleshooting."
exit 0
