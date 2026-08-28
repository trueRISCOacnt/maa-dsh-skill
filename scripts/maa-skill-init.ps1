<#
.SYNOPSIS
    MAA skill 初始化脚本（Windows）：探测 MAA / maa-cli / 模拟器 / 权限设置，
    并读写 skill 下的 skill-config.toml。

.DESCRIPTION
    - 首次使用：探测并生成 skill-config.toml（MAA 目录、maa-cli 二进制、
      模拟器品牌/路径/adb、是否同意完整权限），随后任务初始化即可读取。
    - 非首次使用：直接读取已保存的 skill-config.toml 并打印。
    - -Force 重新探测并覆盖；-FullAccess 声明"用户同意使用完整权限"（写入配置）。

    提示：如果用户已经知道 MAA 或 maa-cli 的位置，请用 -MaaPath / -CliPath
    直接提供（文件夹或二进制路径），可省去自动搜索的时间与 token。

.PARAMETER Force
    忽略已有配置，重新探测并覆盖写入。

.PARAMETER FullAccess
    用户明确同意运行真实任务时使用完整权限（Full Access），写入 [permission] full_access = true。

.PARAMETER MaaPath
    手动指定 MAA 安装/便携目录（含 MaaCore.dll 与 resource/）。提供后可跳过自动搜索。

.PARAMETER CliPath
    手动指定 maa-cli 二进制路径（maa.exe 或 maa）。提供后可跳过自动搜索。

.PARAMETER EmuPath
    手动指定模拟器安装目录。提供后可跳过自动搜索。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .dsh/skills/maa-cli/scripts/maa-skill-init.ps1
    powershell -ExecutionPolicy Bypass -File .dsh/skills/maa-cli/scripts/maa-skill-init.ps1 -Force -FullAccess
    # 用户提供位置，省去自动搜索：
    powershell -ExecutionPolicy Bypass -File .dsh/skills/maa-cli/scripts/maa-skill-init.ps1 -MaaPath "D:\MAA-win-x64" -CliPath "D:\maa\maa.exe"
#>
param(
    [switch]$Force,
    [switch]$FullAccess,
    [string]$MaaPath = "",
    [string]$CliPath = "",
    [string]$EmuPath = ""
)

$ErrorActionPreference = "SilentlyContinue"

# ---------- 1) 确定 skill 配置文件路径（Windows） ----------
# Windows 下 skill 配置固定存放在 %USERPROFILE%\.dsh\maa-config\skill-config.toml，
# 与 maa-cli 自身的配置目录（$MAA_CONFIG_DIR：profiles/、tasks/、cli.toml）分离，
# 也与 skill 包目录分离（skill 更新/分发不会覆盖用户配置）。
# 注意：Linux/macOS 仍沿用 $MAA_CONFIG_DIR/skill-config.toml（见 maa-skill-init.sh，未验证）。
$configDir = Join-Path $env:USERPROFILE ".dsh\maa-config"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
$configPath = Join-Path $configDir "skill-config.toml"
# 迁移：老版本配置存放在 %APPDATA%\maa\skill-config.toml（或 $MAA_CONFIG_DIR\skill-config.toml），
# 若新路径不存在而老路径存在，复制过去，避免用户已有配置丢失。
if (-not (Test-Path $configPath)) {
    $legacyPaths = @()
    if ($env:MAA_CONFIG_DIR) { $legacyPaths += (Join-Path $env:MAA_CONFIG_DIR "skill-config.toml") }
    $legacyPaths += (Join-Path $env:APPDATA "maa\skill-config.toml")
    foreach ($p in $legacyPaths) {
        if (Test-Path $p) {
            Copy-Item $p $configPath -Force
            Write-Host "已迁移旧配置: $p -> $configPath"
            break
        }
    }
}

# ---------- 非首次：读取已有配置 ----------
if ((Test-Path $configPath) -and -not $Force) {
    Write-Host "=== 读取已有配置: $configPath ==="
    Get-Content $configPath -Encoding UTF8
    exit 0
}

Write-Host "=== MAA skill 初始化：探测环境 ==="
Write-Host "[提示] 如果你知道 MAA 或 maa-cli 的位置（文件夹/二进制路径），"
Write-Host "       请用 -MaaPath / -CliPath 提供，可省去自动搜索的时间与 token。"

# ---------- 2) 探测 maa-cli 二进制 ----------
$cliBinary = $CliPath
if (-not $cliBinary) {
    $c = Get-Command maa.exe, maa, maa-cli -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { $cliBinary = $c.Source }
}
$cliVersion = ""
if ($cliBinary) {
    $cliVersion = (& $cliBinary version 2>$null | Select-Object -First 1) -join " "
}
Write-Host "maa-cli  : $cliBinary  ($cliVersion)"

# ---------- 3) 探测 MAA（MaaCore.dll + resource/） ----------
$maaDir = $MaaPath
if (-not $maaDir) {
    # 常见安装/便携目录
    $candidates = @(
        "$env:ProgramFiles\MAA", "$env:ProgramFiles(x86)\MAA",
        "$env:LOCALAPPDATA\Programs\MAA", "D:\MAA", "D:\MAA-win-x64"
    )
    foreach ($d in $candidates) {
        if (Test-Path (Join-Path $d "MaaCore.dll")) { $maaDir = $d; break }
    }
    # 注册表卸载项
    if (-not $maaDir) {
        $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -match "MAA|MaaAssistant" }
        if ($reg) { $maaDir = $reg | Select-Object -First 1 -ExpandProperty InstallLocation }
    }
}
$maaCoreOk = $maaDir -and (Test-Path (Join-Path $maaDir "MaaCore.dll"))
Write-Host "MAA     : $maaDir  (MaaCore.dll: $maaCoreOk)"

# ---------- 4) 探测模拟器 ----------
$emuBrand = ""; $emuInstall = $EmuPath; $emuAdb = ""
# 手动指定目录时按路径推断品牌
if ($emuInstall -and -not $emuBrand) {
    $emuBrand = if ($emuInstall -match "MuMu|Netease") { "MuMu" }
                elseif ($emuInstall -match "LDPlayer|dnplayer") { "LDPlayer" }
                elseif ($emuInstall -match "BlueStacks") { "BlueStacks" }
                elseif ($emuInstall -match "Nox") { "Nox" }
                elseif ($emuInstall -match "Microvirt") { "逍遥" }
                else { "Unknown" }
}
$emuTable = @{
    "MuMu"    = @("$env:ProgramFiles\Netease\MuMu", "$env:ProgramFiles\Netease\MuMu Player 12", "$env:LOCALAPPDATA\Netease\MuMu Player 12")
    "LDPlayer"= @("$env:ProgramFiles\LDPlayer9", "D:\LDPlayer9")
    "BlueStacks" = @("$env:ProgramFiles\BlueStacks_nxt", "$env:ProgramFiles\BlueStacks")
    "Nox"     = @("$env:ProgramFiles\Nox", "D:\Nox")
    "逍遥"     = @("$env:ProgramFiles\Microvirt")
}
foreach ($brand in $emuTable.Keys) {
    foreach ($d in $emuTable[$brand]) {
        if ($d -and (Test-Path $d)) { $emuBrand = $brand; $emuInstall = $d; break }
    }
    if ($emuBrand) { break }
}
# 从运行中的模拟器进程反查安装路径
if (-not $emuInstall) {
    $proc = Get-Process | Where-Object { $_.Path -match "MuMu|LDPlayer|BlueStacks|Nox|dnplayer" } | Select-Object -First 1
    if ($proc -and $proc.Path) { $emuInstall = Split-Path $proc.Path -Parent; $emuBrand = if ($proc.Path -match "MuMu") {"MuMu"} elseif ($proc.Path -match "LD|dnplayer") {"LDPlayer"} elseif ($proc.Path -match "BlueStacks") {"BlueStacks"} elseif ($proc.Path -match "Nox") {"Nox"} else {"Unknown"} }
}
# 查找模拟器自带 adb
if ($emuInstall) {
    $emuAdb = (Get-ChildItem $emuInstall -Recurse -Filter "adb.exe" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
Write-Host "模拟器  : $emuBrand @ $emuInstall"
Write-Host "adb     : $emuAdb"

# ---------- 5) 完整权限 ----------
$fullAccess = $FullAccess
if (-not $fullAccess -and (Test-Path $configPath)) {
    $old = Get-Content $configPath -Raw
    if ($old -match 'full_access\s*=\s*true') { $fullAccess = $true }
}
Write-Host "Full Access: $fullAccess"

# ---------- 写入 skill-config.toml ----------
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$toml = @"
# MAA skill 初始化配置（由 scripts/maa-skill-init.ps1 生成/更新）
# 首次初始化时写入；非首次初始化时由技能读取本文件，无需重新探测。
[meta]
created_at = "$stamp"

[maa]
maa_core_path = "$maaDir"
maa_core_ready = $maaCoreOk

[maa_cli]
binary_path = "$cliBinary"
version = "$cliVersion"

[emulator]
brand = "$emuBrand"
install_path = "$emuInstall"
adb_path = "$emuAdb"
# 实际连接地址/端口请用 scripts/maa-emulator-detect.ps1 -Probe 确认后填写，如 "127.0.0.1:16384"
address = ""

[permission]
# 用户是否同意运行真实任务时使用完整权限（Full Access）。
# true 表示用户在初始化时已明确同意；false 时运行真实任务前需向用户确认。
full_access = $fullAccess
# 技能内容保护：是否允许 harness/agent 更改本 skill 的内容（SKILL.md / README.md / scripts/ / references/ 等）。
# 默认 false；该值只能由用户明确指示更改，harness/agent 不得自行修改（本脚本也只会原样保留）。
modify_skill = false
"@
# 保留旧配置中手动填写的连接地址（端口无法自动探测，避免 -Force 重新生成时丢失）
$oldAddress = ""
if (Test-Path $configPath) {
    $old = Get-Content $configPath -Raw
    if ($old -match '(?m)^address = "([^"]*)"' -and $Matches[1]) { $oldAddress = $Matches[1] }
}
if ($oldAddress -and $toml -match 'address = ""') {
    $toml = $toml -replace 'address = ""', ('address = "' + $oldAddress + '"')
}
# 保护开关 modify_skill 原样保留：仅在新建时默认为 false，绝不覆盖已有值（该值只能由用户明确指示更改）
$oldModify = ""
if (Test-Path $configPath) {
    $old = Get-Content $configPath -Raw
    if ($old -match '(?m)^modify_skill\s*=\s*(true|false)') { $oldModify = $Matches[1] }
}
if ($oldModify -and $toml -match 'modify_skill = false') {
    $toml = $toml -replace 'modify_skill = false', ('modify_skill = ' + $oldModify)
}
# 用 .NET 写 UTF-8（带 BOM），避免 GBK 代码页的 Windows PowerShell 5.1 将无 BOM 的中文注释按 ANSI 解析而乱码/报错；
# TOML 解析器可正常处理 BOM（旧版无 BOM 配置由 -Encoding UTF8 / .NET ReadAllText 读取，兼容）。
[System.IO.File]::WriteAllText($configPath, $toml, [System.Text.UTF8Encoding]::new($true))
Write-Host "=== 已写入: $configPath ==="
