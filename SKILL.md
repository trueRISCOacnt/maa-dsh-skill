---
name: maa-dsh-skill
description: 使用 MaaAssistantArknights (MAA) 官方命令行工具 maa-cli 驱动 MaaCore 自动完成《明日方舟》游戏任务：刷关卡 (fight)、集成战略 (roguelike)、生息演算 (reclamation)、自动抄作业 (copilot / sscopilot / paradoxcopilot)、启动与关闭游戏客户端 (startup / closedown)，以及自定义任务编排 (run)、MaaCore 与资源安装更新 (install / update)、配置管理 (init / import / profiles / tasks)。跨平台（Windows / Linux / macOS）。当用户要求用 MAA 自动化明日方舟、安装或管理 MAA 及其 CLI、编写自定义任务配置、排查 ADB/模拟器连接问题时使用。
whenToUse: 用户要求自动化《明日方舟》日常任务（刷图、肉鸽、生息演算、抄作业、基建、公招等），或要求安装、更新、配置 MAA / maa-cli / MaaCore，或要求排查 MAA 连接与运行问题时，加载本技能并按其中流程执行。
metadata:
  version: "0.0.1-rc5"
  maa-cli-docs: https://github.com/MaaAssistantArknights/maa-cli/tree/main/crates/maa-cli/docs
  compatible:
    maa-cli: "v0.7.5"
    maa: ">= v6.11.0"
---

# maa-dsh-skill — 明日方舟自动化

> 📦 **技能版本：0.0.1-rc5**，适用于 **maa-cli v0.7.5**（对应 **MAA v6.11.0 及以后**）。

本技能指导你在 DeepSeek Harness 环境中，通过 MAA 官方命令行工具 **maa-cli** 驱动 **MaaCore**，自动化完成《明日方舟》游戏任务，并覆盖 Windows / Linux / macOS 三个平台的安装、配置与使用。

- MAA 主仓库 README 的「CLI 支持」一节指向官方使用指南：<https://docs.maa.plus/zh-cn/manual/cli/>
- maa-cli 项目主页：<https://github.com/MaaAssistantArknights/maa-cli>
- 本技能 `references/` 目录内置了 maa-cli 官方文档（中英文），内容以仓库内文档为准，联网不便时直接读取本地副本。

## 0. 概念与定位

| 组件 | 作用 | 说明 |
| --- | --- | --- |
| MAA (MaaAssistantArknights) | 明日方舟辅助 | 本体项目，提供 MaaCore 与 GUI |
| **maa-cli** | 命令行前端 | Rust 编写的 CLI，本技能操作的对象 |
| **MaaCore** | 核心库/引擎 | 实际执行任务的动态库，由 `maa install` 安装 |
| 资源 (resource) | 识别与任务数据 | 随 MaaCore 安装，可热更新（`maa hot-update`） |

maa-cli 只是命令行前端，**必须先安装 MaaCore 和资源**才能运行任务。典型链路：安装 maa-cli → 安装 MaaCore → 配置连接（ADB/模拟器）→ 运行任务。

> ⚠️ **重要：使用前请先确认用户是否知道 maa-cli 的默认配置**
>
> 如果目标机器上**还没有事先运行过 MAA（GUI 或便携版）**，本技能将以 **MAA 的默认配置**执行任务，可能出现意想不到的事故。目前已知：
>
> - **基建人员被打乱**：默认配置下基建任务按 MAA 内置默认逻辑自动入驻（不是基建换班），可能调动用户不希望调整的干员。
>
>
> 首次使用前，**提醒/引导用户先手动运行一次 MAA 并保存好设置**（尤其是基建排班方案、常刷关卡、理智药策略）；运行真实任务前先 `maa run <任务> --dry-run` 校验配置。

## 1. 标准工作流程

在 DSH 中按以下顺序执行；每一步都先探测、再行动，不要臆测命令。

0. **确认 MAA 是否已事先运行配置过**：若用户从未运行过 MAA（无已保存的基建方案/设置），先明确提示「将以 MAA 默认配置运行」的风险（见上方警告，如基建人员被打乱），并建议用户先手动运行一次 MAA 或确认相关设置。
1. **探测环境**：确认 maa-cli 是否已安装及其二进制名（`maa` 还是 `maa-cli`）、MaaCore 是否就绪。
2. **安装**（如缺失）：按平台安装 maa-cli，再 `maa install` 安装 MaaCore 与资源。
3. **配置**：确保连接配置（模拟器/ADB）正确；必要时创建 `profiles/default.toml` 或运行 `maa init`。
4. **校验**：对配置类操作先 `--dry-run` 验证，避免连不上设备时长时间卡住。
5. **运行任务**：预定义任务（`maa fight` 等）或自定义任务（`maa run <task>`）。
6. **收集结果**：读取任务总结与日志（`maa dir log`、`--log-file`），向用户汇报掉落/次数/结果。
7. **意图 ↔ 指令查表（不确定用户要干什么时）**：若不确定用户的请求对应哪个 maa-cli 指令/任务参数，**先查本地副本 `references/maa-official/integration.html`**（MAA 集成文档：全部任务类型 StartUp / CloseDown / Fight / Recruit / Infrast / Depot / Roguelike / Copilot / Reclamation … 及各自全部参数与示例），再对照 `references/cli/commands.md`（全部命令 `--help`）与 `references/zh-CN/`（官方使用指南）确定对应指令；**不要臆测命令或参数**。

## 1.5 初始化与配置持久化（每次会话开始必做）

skill 的初始化参数（MAA 位置、maa-cli 位置、模拟器位置、用户是否同意完整权限等）**持久化保存在独立的 skill 配置文件中**，与 skill 本体分离（skill 更新/分发不会覆盖用户配置），也与 maa-cli 自身的配置（`$MAA_CONFIG_DIR`：profiles/、tasks/、cli.toml）分离：

| 项 | 值 |
| --- | --- |
| 配置文件（Windows） | `%USERPROFILE%\.dsh\maa-config\skill-config.toml`（即 `C:\Users\<用户名>\.dsh\maa-config\skill-config.toml`） |
| 配置文件（Linux/macOS） | `$MAA_CONFIG_DIR/skill-config.toml`（沿用；定位优先级 `$env:MAA_CONFIG_DIR` > `maa dir config` > 平台默认 `~/.config/maa` / `~/Library/Application Support/maa`；**未验证**） |
| 生成/读取脚本 | `scripts/maa-skill-init.ps1`（Windows）/ `scripts/maa-skill-init.sh`（Linux/macOS） |

**流程**（每次加载本 skill 后执行）：

1. 读取配置：运行初始化脚本（无参数）——存在 `skill-config.toml` 时直接打印已有配置（非首次，跳过探测）；不存在时自动探测并生成（首次）。
2. **首次使用时先询问用户**：是否知道 MAA 或 maa-cli 所在的位置（文件夹或二进制路径）？用户提供则直接用 `-MaaPath`/`-CliPath`（Windows）或 `--maa`/`--cli`（Linux/macOS）传给初始化脚本——**告诉用户这样可以省去自动搜索的时间与 token**；用户不知道时脚本才自动搜索常见路径。
3. 首次生成后，把探测结果与用户确认：MAA 目录、maa-cli 二进制、模拟器品牌/路径/adb 是否准确；**询问用户是否同意运行真实任务时使用完整权限**（`[permission] full_access = true/false`，用户同意用 `-FullAccess` 参数或改配置文件写入 `true`）。
4. 模拟器 ADB 端口需用 `scripts/maa-emulator-detect.ps1 -Probe` 实测后填入配置的 `[emulator] address`（脚本探测不到端口；`-Force` 重新生成时会保留旧配置中已填的 address，不会丢失）。
5. 之后每次会话直接读取 `skill-config.toml` 使用，无需重复探测；环境变化时（如换了模拟器/重装 MAA）用 `-Force` 重新探测更新。

配置文件结构：

```toml
[meta]
created_at = "..."

[maa]
maa_core_path = "..."      # MAA 安装/便携目录（含 MaaCore.dll 与 resource/）
maa_core_ready = true

[maa_cli]
binary_path = "..."        # maa-cli 二进制全路径
version = "..."

[emulator]
brand = "MuMu"             # MuMu / LDPlayer / BlueStacks / Nox / 逍遥 / Waydroid ...
install_path = "..."
adb_path = "..."           # 模拟器自带 adb
address = "127.0.0.1:16384" # 实测端口（maa-emulator-detect -Probe 确认）

[permission]
full_access = false        # 用户是否同意运行真实任务时使用完整权限
modify_skill = false       # 是否允许 harness/agent 更改本 skill 的内容（默认 false，仅用户可改）
```

> 🔒 **技能内容保护（modify_skill）**：`skill-config.toml` 中 `[permission] modify_skill` 控制是否允许 harness/agent **修改本 skill 的内容**（SKILL.md、README.md、scripts/、references/、schemas/ 等）。**默认 `false`**：除非用户明确要求，否则不得修改 skill 内任何文件。**该值只能由用户明确指示更改**——harness/agent 不得自行修改它（初始化脚本 `maa-skill-init.ps1` / `.sh` 只会原样保留该值，不会覆盖）。

## 2. 探测环境（第一步必做）

先判断操作系统，再探测二进制（跨平台差异集中在二进制名）：

```bash
# Windows (pwsh): $IsWindows / $env:OS 判断；二进制名可能是 maa 或 maa-cli
Get-Command maa -ErrorAction SilentlyContinue
Get-Command maa-cli -ErrorAction SilentlyContinue

# Linux/macOS (bash)
command -v maa; command -v maa-cli
```

找到二进制后（下文以 `maa` 指代；若为 `maa-cli` 则替换），执行基础探测：

```bash
maa version          # maa-cli 与 MaaCore 版本；MaaCore 未安装会报错
maa dir config       # 配置目录
maa list             # 列出全部可用任务（含自定义任务）
maa --help           # 完整子命令
maa <子命令> --help  # 查看某子命令的参数
```

若 `maa version` 报「MaaCore 找不到/未安装」，先执行第 3 节的安装步骤。

## 3. 跨平台安装

### 3.1 安装 maa-cli 本体

| 平台 | 方式 | 安装后二进制名 |
| --- | --- | --- |
| Windows | `winget install maa-cli` | **`maa-cli`**（注意：winget 装的是 `maa-cli` 而非 `maa`） |
| Windows | 安装脚本：`Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/main/install.ps1" -OutFile install.ps1; .\install.ps1` | `maa` |
| macOS | `brew install MaaAssistantArknights/tap/maa-cli`（Beta 用 `maa-cli-beta`） | `maa` |
| Linux (Arch) | `yay -S maa-cli` | `maa` |
| Linux (Nix) | `nix run nixpkgs#maa-cli`（Nix 版强制依赖 MaaCore，无需手动装） | `maa` |
| Linux/macOS | 安装脚本：`curl -fsSL https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/main/install.sh | bash` | `maa` |
| 任意（有 Rust） | `cargo install maa-cli --git https://github.com/MaaAssistantArknights/maa-cli.git --bin maa --tag stable --locked` | `maa` |

> **二进制名陷阱（跨平台最容易踩的坑）**：winget 安装后命令是 `maa-cli`，其余方式通常是 `maa`。执行任何命令前先探测（见第 2 节），或者统一用「先 `maa --version`，失败再 `maa-cli --version`」的探测逻辑。winget 用户更新/卸载用 `winget update/uninstall maa-cli`，`maa self update` 对包管理器安装无效。

### 3.2 安装 MaaCore 与资源（必需）

```bash
maa install   # 下载安装 MaaCore 库 + 基础资源 + 热更新资源
maa update    # 更新 MaaCore 与资源
maa self update   # 更新 maa-cli 自身（仅脚本/编译安装可用）
maa hot-update    # 仅热更新资源（需已安装基础资源）
```

**Windows 特别要求**：`maa install` 前需以管理员身份安装 VC++ 运行库，否则 MaaCore 可能无法加载：

```bat
winget install "Microsoft.VCRedist.2015+.x64" --override "/repair /passive /norestart" --uninstall-previous --accept-package-agreements --force
```

**网络注意**：`maa install/update` 默认从 GitHub 下载，国内网络可能失败。可在 `cli.toml` 中配置 `api_url` / `download_url` 镜像（见第 4.3 节）。

## 4. 配置

### 4.1 配置目录

```bash
maa dir config   # 输出配置目录（默认由 OS 决定，可用环境变量 MAA_CONFIG_DIR 覆盖）
```

所有配置文件支持 TOML / YAML / JSON 三种格式（按扩展名识别），可混用。部分任务参数接受相对路径，相对于配置目录的对应子目录（如基建计划相对 `$MAA_CONFIG_DIR/infrast`，保全派驻作业相对 `$MAA_CONFIG_DIR/ssscopilot`）。

### 4.2 MaaCore 配置（profiles）

连接与运行参数放在 `$MAA_CONFIG_DIR/profiles/<名字>.toml`（默认读取 `default`；旧版兼容 `$MAA_CONFIG_DIR/asst.toml`）。运行任务时用 `-p/--profile <名字>` 选择。

```toml
[connection]
preset = "MuMuPro"          # 模拟器预设（目前有 MuMuPro、PlayCover[macOS]、Waydroid[Linux]）
adb_path = "adb"            # adb 可执行文件路径，默认在 PATH 中找
address = "127.0.0.1:5555"  # 连接地址：模拟器端口或设备序列号；省略时用 `adb devices` 探测
config = "General"          # 平台/模拟器相关配置；Linux 默认 CompatPOSIXShell，macOS CompatMac

[resource]
global_resource = "YoStarEN"   # 非简中客户端资源（外服）
platform_diff_resource = "iOS" # iOS 客户端资源
user_resource = true           # 加载用户自定义资源

[static_options]
cpu_ocr = false
gpu_ocr = 1

[instance_options]
touch_mode = "MaaTouch"        # ADB / MiniTouch / MaaTouch / MacPlayTools
deployment_with_pause = false
adb_lite_enabled = false
kill_adb_on_exit = false
```

- 不指定 `address` 时：若 `adb devices` 只有一个设备则用它，否则回退 `emulator-5554`。
- **`adb_path` 必须指向实际可执行的 adb**（MaaCore 会直接执行它）：adb 已在 PATH 中时可省略，否则必须写全路径。例如 MuMu 12 自带 adb：`D:\Program Files\Netease\MuMu Player 12\nx_device\12.0\shell\adb.exe`。写错或缺失时运行报 `Connection command failed to exec`。
- **实际 adb 端口以模拟器为准**：官方自动检测端口表见 4.5 节（MuMu 16384/16416/…、雷电 5555/5557/…、蓝叠 5555/5556/…、夜神 62001/59865、逍遥 21503）；多开实例端口会偏移，MuMu 可用 `MuMuManager.exe info -v all` 查询实际端口。
- 用 `-a/--addr` 可在单次运行时临时覆盖连接地址，不必改配置。

### 4.3 CLI 配置（cli.toml）

`$MAA_CONFIG_DIR/cli.toml` 控制安装/更新与热更新行为：

```toml
[core]
channel = "Stable"           # Alpha / Beta / Stable；Alpha 仅 Windows
api_url = "..."              # MaaCore 版本查询地址（国内可配镜像）
test_time = 3

[cli]
channel = "Stable"
api_url = "..."              # maa-cli 版本查询地址
download_url = "..."         # maa-cli 二进制下载地址

[resource]
auto_update = true           # 每次运行任务前自动热更新资源（默认 false）
backend = "libgit2"          # git 或 libgit2；用 git 后端要求本机有 git
warn_on_update_failure = true
```

### 4.4 自定义任务（tasks/）

每个自定义任务一个文件，位于 `$MAA_CONFIG_DIR/tasks/<任务名>.toml`（或 .yaml/.json）。运行时 `maa run <任务名>`（不带扩展名）。`maa list` 会列出全部自定义任务。

```toml
[[tasks]]
name = "启动游戏"
type = "StartUp"
params = { client_type = "Official", start_game_enabled = true }

[[tasks]]
type = "Fight"

# 条件变体：满足条件时使用对应 params（默认策略 first：第一个匹配的生效）
[[tasks.variants]]
condition = { type = "Weekday", weekdays = ["Tue", "Thu", "Sat"] }
params = { stage = "CE-6" }

# 无条件的变体放最后作为默认
[[tasks.variants]]
params = { stage = "1-7", medicine = 3 }
```

- 任务类型与参数名对应 MAA 集成文档的任务类型（<https://docs.maa.plus/zh-cn/protocol/integration.html>；**本地副本：`references/maa-official/integration.html`**）；maa-cli 不校验参数名，写错可能静默无效，务必与文档核对。
- 条件类型：`Time`（HH:MM:SS，结束小于开始视为次日）、`DateTime`（ISO 时间区间）、`Weekday`（weekdays: Mon..Sun，timezone 可为数字偏移或客户端名如 "Official"，官服时区是东四区）、`DayMod`（divisor/remainder 周期，用 `maa remainder <divisor>` 查当天偏移）、`OnSideStory`（活动期间，依赖热更新资源）；可用 `And` / `Or` / `Not` 组合。
- `strategy = "merge"` 时多个匹配变体的参数合并（后者覆盖前者同名键）；`first`（默认）取第一个。
- 无任何变体匹配时该子任务不执行——可用于「只在某时间段做某事」。
- 用户输入参数：`params` 中某键可写为 `{ alternatives = [...], default_index = n, description = "..." }`（Select）或 `{ default = "...", description = "..." }`（Input）；运行时交互式询问，`--batch` 跳过交互并使用默认值（无默认值会报错）。
- 基建计划文件是 JSON 且由 MaaCore 读取，须放在 `$MAA_CONFIG_DIR/infrast/`，时间分班靠任务条件里的 `plan_index` 切换。
- 官方 JSON Schema（编辑器校验/补全）：`task.schema.json`、`asst.schema.json`、`cli.schema.json`，见 maa-cli 仓库 `crates/maa-cli/schemas/` 目录；本技能 `references/` 中也有一份。

### 4.5 模拟器检测与连接（官方优先品牌）

**模拟器品牌以 MAA 官方文档为准**（`references/maa-official/` 内置官方连接与设备文档副本）：

| 平台 | ✅ 完美支持（优先） | ⚠️ 部分支持 | 🚫 不支持 |
| --- | --- | --- | --- |
| Windows | **MuMu 12**（+截图增强）、**雷电 9**（+截图增强）、**蓝叠 5 / 国际版**、**夜神**、**逍遥** | MuMu 6（旧版需手动）、WSA（已弃）、AVD、Google Play Games（开发者版，端口 6520） | 腾讯应用宝、Google Play Games（玩家版） |
| macOS | **PlayCover**（MaaTools，无 adb）、**MuMu Pro**、蓝叠 air（5555）、AVD | — | — |
| Linux | **AVD**、**Waydroid**、**redroid**（5555） | Genymotion | — |

**MAA 官方自动检测端口表**（连接文档，MAA v5.22.3+）：

- BlueStacks 5：`127.0.0.1:5555/5556/5565/5575/5585/5595/5554`
- MuMu：`127.0.0.1:16384/16416/16448/16480/16512/16544/16576`（实例越多端口越靠后）
- 雷电 9：`emulator-5554/5556/5558/5560`、`127.0.0.1:5555/5557/5559/5561`
- 夜神：`127.0.0.1:62001/59865`；逍遥：`127.0.0.1:21503`

**模拟器自带 adb 文件名模式**（官方文档）：`adb.exe`、`HD-Adb.exe`（蓝叠）、`adb_server.exe`、`nox_adb.exe`（夜神）。

**使用检测脚本（自动 + 手动定位）**：

```powershell
# Windows：自动检测（注册表/进程/常见路径，官方优先品牌排序）
powershell -File .dsh/skills/maa-cli/scripts/maa-emulator-detect.ps1

# 手动定位：指定模拟器安装目录（脚本在目录内找 adb 并推断品牌）
powershell -File .dsh/skills/maa-cli/scripts/maa-emulator-detect.ps1 -Path "D:\Games\LDPlayer9"

# 手动指定 adb 与连接地址
powershell -File .dsh/skills/maa-cli/scripts/maa-emulator-detect.ps1 -Adb "D:\x\adb.exe" -Address "127.0.0.1:5555"

# -Probe：查询实际端口（MuMu 用 MuMuManager 读实例端口，并逐个尝试官方端口连接；涉及 spawn adb/模拟器，一开始就用完整沙箱权限运行）
powershell -File .dsh/skills/maa-cli/scripts/maa-emulator-detect.ps1 -Probe

# Linux / macOS
bash .dsh/skills/maa-cli/scripts/maa-emulator-detect.sh [-p <dir> | -a <adb> -A <address>]
```

脚本输出：检测到的品牌、安装路径、adb 路径、官方端口候选、**可直接写入 `profiles/default.toml` 的建议配置**（`-Probe` 时带真实端口）。检测不到时再让用户手动提供模拟器位置（`-Path`/`-p`）。

**各品牌连接注意**：

- 蓝叠 5：需在模拟器设置中开启「允许 ADB 连接 / Android 调试桥」；Hyper-V 下端口每次启动会变，MAA 会读 `bluestacks.conf`（`C:\ProgramData\BlueStacks_nxt\bluestacks.conf` 或 `_cn`），多开需在配置中指定 `Bluestacks.Config.Keyword`/`Path`。
- MuMu 12：支持截图增强；`显存使用策略` 勿设为「资源占用更小」。
- 雷电 9：安装器会自动静默关闭 Hyper-V，注意。
- MuMu 6：MAA 已放弃支持，需通用连接配置 + 手动 adb 路径，分辨率改 16:9。
- macOS PlayCover：触控模式 `MacPlayTools`，连接地址取游戏窗口标题 `[localhost:端口]`。
- Waydroid：分辨率需 1280x720+，adb 地址为 `waydroid` 设置里查到的 IP:5555。

### 4.6 复用已安装的 MAA 客户端（免下载 MaaCore）

如果本机已安装 MAA（GUI 或便携版，含 `MaaCore.dll` 与 `resource/`），可以让 maa-cli 直接复用它，无需 `maa install` 重新下载 MaaCore。maa-cli 按以下优先级查找 MaaCore 与资源：

- 库：`$MAA_DATA_DIR/lib/MaaCore.dll` → `maa.exe` 同目录 → `maa.exe` 父目录的 `lib/`
- 资源：`$MAA_DATA_DIR/resource/` → `maa.exe` 同目录的 `resource/` → 父目录 `share/maa/resource/`

做法（Windows 示例，Linux/macOS 同理）：

1. 用环境变量把 maa-cli 的目录都指到工作区内：`MAA_DATA_DIR`、`MAA_CONFIG_DIR`、`MAA_STATE_DIR`、`MAA_CACHE_DIR`（空值视为未设置）。
2. 建立目录联接（或复制）复用已有 MAA：
   ```powershell
   New-Item -ItemType Junction -Path "$env:MAA_DATA_DIR\lib" -Target "F:\path\to\MAA"          # 含 MaaCore.dll 及其依赖 DLL
   New-Item -ItemType Junction -Path "$env:MAA_DATA_DIR\resource" -Target "F:\path\to\MAA\resource"
   ```
   联接必须指向 MAA 根目录（MaaCore.dll 与依赖 DLL 同目录才能正确加载）。
3. `maa version` 应能直接读到已装 MaaCore 的版本。

注意：maa-cli 与 MAA 6.x 的 MaaCore 兼容性已实测可用（maa-cli v0.7.5 + MaaCore v6.16.8 正常执行 startup/fight）；若 `maa version` 报错或运行崩溃，说明版本组合不兼容，此时改用 `maa install` 安装官方匹配的 MaaCore。

> ✅ **已实测验证**：按上述步骤在 `$env:MAA_DATA_DIR`（如 `C:\Users\<用户>\.maa\data`）下建立 `lib`/`resource` 两个 junction 指向已装 MAA 根目录后，`maa version` 正常读到 MaaCore 版本，startup/fight/infrast/depot 全部可运行。运行日志中 `Resource directory ... not found, ignoring` 的 WARN（针对 `MaaResource` 热更新目录或 `$MAA_CONFIG_DIR/resource` 用户目录）可安全忽略——主资源经 junction 正常加载。
>
> ⚠️ **dry-run 退出码注意（实测）**：`maa run <任务> --dry-run` 即使配置全部解析成功、Summary 正常列出各子任务，进程退出码也可能是 1（且 stderr 有 WARN 噪音）——**判断 dry-run 是否通过要看 Summary 是否列出预期子任务，不要只看退出码**。

## 5. 运行任务

### 5.1 预定义任务

```bash
maa startup [client]        # 启动游戏并进入主界面；client 如 Official；留空只连接不启动游戏
maa closedown [client]      # 关闭游戏客户端（默认 Official）
maa fight [stage]           # 刷关卡；stage 如 1-7；留空刷上次/当前关卡
maa copilot <maa_uri>...    # 抄作业；uri 形如 maa://1234 或本地文件 ./1234.json，可多个
maa sscopilot <maa_uri>     # 保全派驻
maa paradoxcopilot <maa_uri># 悖论模拟
maa roguelike <theme>       # 集成战略；theme: Phantom / Mizuki / Sami / Sarkaz / JieGarden
maa reclamation <theme>     # 生息演算；目前仅 Tales
```

### 5.2 fight 常用参数

```bash
maa fight 1-7 -m 3                     # 使用 3 瓶理智药
maa fight BB-7 --times 10              # 刷 10 次后退出（times=10：10 场独立单次作战，注意与 series 的区别，见 5.2.1）
maa fight 1-7 --series 3 --times 1     # 刷 1-7 共 3 次：一场 3 倍率代理作战（series=3 连战 × times=1 场）
maa fight 1-7 -D30012=100              # 掉落 100 个固源岩(物品ID 30012)后退出，可重复 -D
maa fight 1-7 --series 6               # 单次代理作战连续次数（-1~10；-1 关闭连战）
maa fight 1-7 --expiring-medicine 100  # 使用即将过期的理智药
maa fight 1-7 --stone 10               # 使用源石
maa fight 1-7 --report-to-penguin --penguin-id=xxx   # 上报企鹅物流
maa fight 1-7 --client-type=YoStarJP   # 指定客户端（外服）
```

物品 ID 可在 MaaCore 资源的 `item_index.json` 中查。

### 5.2.1 用户指令「刷 x 次」= 一次 x 倍率作战（连战）

**解读规则（重要）**：当用户说「刷 X 次」（如「打 1-7 10 次」）时，指的是**进行一次 X 倍率的作战**——即在一场代理作战里连战 X 次，而**不是**执行 X 次相互独立的单次刷图（不要把「刷 10 次」实现成 `times = 10` 的 10 场单次作战）。

单次作战的倍率上限为 **10**，换算规则如下：

- 若 `1 ≤ X ≤ 10`：直接进行一次 **X 倍率**的作战；
- 若 `X ≥ 11`（即 `X > 10`）：先进行一次 **10 倍率**的作战（X 减去 10），重复此判断直到 `X ≤ 10`，最后再进行一次 **X 倍率**的作战。

等价伪代码：

```text
while X > 10:
    进行一次 10 倍率作战
    X = X - 10
进行一次 X 倍率作战   # 此时 1 ≤ X ≤ 10
```

**示例**：

| 用户指令 | 实际执行（场数：倍率） |
| --- | --- |
| 刷 10 次 | 1 场：10 倍率 |
| 刷 26 次 | 3 场：10 倍率 + 10 倍率 + 6 倍率 |
| 刷 11 次 | 2 场：10 倍率 + 1 倍率 |
| 刷 30 次 | 3 场：10 倍率 + 10 倍率 + 10 倍率 |

**MAA 实现映射**：一场「X 倍率作战」对应 Fight 任务的 `series = X`（单次代理作战连续次数，如 `maa fight 1-7 --series 10`）；`times` 是**总战斗次数上限**（默认无限 `2147483647`），`series` 才是连战倍率。`series` 的可接受范围以当前 MAA/游戏支持为准（早期文档为 `-1~6`，其中 `0` = 自动选当前最大可用连战；若目标倍率超出 MAA 支持上限，需拆成多场，如上限 6 时 10 倍率拆为 `6 + 4`）。多场作战可写成自定义任务里的多个 Fight 子任务依次执行。

> ⚠️ **「刷 X 次」的 `times` 取值随 MaaCore 版本而变（实测翻车点，务必遵守）**：
>
> **`times` 默认无限（2147483647）**：只设 `series = X` 而不设 `times`，MAA 会无限重复 X 倍率作战，直到理智耗尽或你手动停止（实测：`params = { stage = "1-7", series = 3 }` 未设 times，反复执行多次 3 倍率作战被手动终止）。所以「刷 X 次」必须显式设置 `times`。
>
> **`times` 的语义与 MaaCore 版本相关**：
>
> - **新版（MaaCore v6.16.8 实测）**：`times` = **总战斗次数上限（连战倍率计入次数）**。源码 `FightTimesTaskPlugin::_run()`：`if (m_fight_times + *series > m_fight_times_max) { finished = true; }`——若 `times < series`（如 `times=1, series=3`），`0 + 3 > 1` 直接判定「战斗次数超过上限」，**跳过本次作战**（日志 `fight times reached max`、`times_finished: 0`，Summary 里 Fight 却显示 Completed——**实际一次都没打**）。因此一次 X 倍率作战必须写 `{ series = X, times = X }`（每场 N 倍率同理写 `{ series = N, times = N }`）。
> - **旧版（技能早期实测）**：`times` = 场数，一次 X 倍率作战算 1 场 → 写 `{ series = X, times = 1 }`（等价 `maa fight 1-7 --series 3 --times 1`）。
>
> **正确写法（新版 v6.16.8，一次 X 倍率作战，共 X 次后停止）**：
>
> ```toml
> # 自定义任务：打 1-7 共 3 次（一场 3 倍率代理作战）
> [[tasks]]
> type = "Fight"
> params = { stage = "1-7", series = 3, times = 3 }
> ```
>
> 等价 CLI：`maa fight 1-7 --series 3 --times 3`。
>
> 只有用户明确说「一直刷到理智耗尽/掉落够为止」时才可省略 `times`（或设大值），否则一律显式设 `times`。实现前先想清楚用户意图：**「刷 X 次」= 有限次（X 次），不是无限**；不确定版本语义时先看 `maa version` 输出的 MaaCore 版本号再定 `times`。

### 5.3 roguelike 常用参数

```bash
maa roguelike Sarkaz                                  # 默认模式0（刷分）
maa roguelike Sami --mode 5 -P目空一些 -P图像损坏     # 坍缩范式模式
maa roguelike Sarkaz --mode 1 --start-with-seed       # 刷源石锭+种子
maa roguelike Sarkaz --squad "蓝图测绘分队" --core-char "维什戴尔" --roles "取长补短"
maa roguelike Mizuki --start-count 100 --difficulty 15 --stop-at-final-boss
maa roguelike Sami --use-foldartal -F英雄 -F大地
maa roguelike Phantom --disable-investment
```

- mode：0 刷分 / 1 刷源石锭 / 3 通关（未实现）/ 4 三层后存在 / 5 坍缩范式（仅 Sami）。
- `--squad`、`--core-char`、`--roles` 用中文名；`--difficulty` 对 Phantom 无效。

### 5.4 通用参数（所有运行类子命令）

```bash
-a, --addr <addr>        # 临时指定 ADB 连接地址
-p, --profile <name>     # 选择 profiles 下的配置文件
--user-resource          # 额外加载 $MAA_CONFIG_DIR/resource 下的用户资源
--dry-run                # 只解析配置不连接游戏（校验配置用，会输出 debug 日志）
--no-summary             # 关闭任务总结输出
--no-auto-reconnect      # 断线后不自动重连
--batch                  # 全局参数：跳过所有交互输入，使用默认值
-v / -q                  # 提高/降低日志级别
--log-file[=path]        # 日志写入文件（默认 $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log）
```

> **Windows 坑（实测）**：`--log-file` 不带路径时，默认日志名含 `HH:MM:SS` 的冒号（Windows 文件名非法），启动即报 `Error: 文件名、目录名或卷标语法不正确。 (os error 123)` 并退出。Windows 上务必显式指定路径：`--log-file="C:\path\to\run.log"`（或设置 `MAA_LOG` + 读 `maa dir log`）。

## 6. 其他管理命令速查

| 命令 | 作用 |
| --- | --- |
| `maa version` | maa-cli 与 MaaCore 版本（可指定 `cli` / `core`） |
| `maa dir <dir>` | 目录：`data` `library`(别名 `lib`) `config` `cache` `resource` `hot-update` `log` |
| `maa list` | 列出所有可用任务 |
| `maa run <task>` | 运行自定义任务 |
| `maa init` | 交互式初始化 MaaCore 配置（`-n` 指定 profile 名、`-f/--format` 指定格式、`--force`） |
| `maa import <file> [-t <type>]` | 导入配置：`-t` 可选 `cli` / `profile` / `infrast` 等 |
| `maa convert <in> [out] [-f json\|yaml\|toml]` | 配置格式转换（如 TOML 基建计划 → MaaCore 需要的 JSON） |
| `maa activity [client]` | 查询当前活动信息 |
| `maa remainder <divisor>` | 计算 DayMod 条件当天偏移量 |
| `maa cleanup [target...]` | 清理缓存（`cli-cache` / `core-cache` / `log` 等） |
| `maa complete <shell>` | 生成补全脚本（bash/zsh/fish/powershell/elvish） |
| `maa mangen --path <dir>` | 生成 man 手册 |
| `maa install` / `maa update` / `maa hot-update` / `maa self update` | 安装与更新（见第 3 节） |

## 7. 环境变量

| 变量 | 作用 |
| --- | --- |
| `MAA_CONFIG_DIR` | 覆盖配置目录（默认由 OS 决定，如 `~/.config/maa`、`~/Library/Application Support/maa`、`%APPDATA%/maa`） |
| `MAA_LOG` | 日志级别：`Error` / `Warn` / `Info` / `Debug` / `Trace`，默认 `Warn` |
| `MAA_LOG_PREFIX` | `Always` / `Auto` / `Never`：日志时间戳与级别前缀策略 |
| `MAA_COMPLETE` | 设置后运行 `maa` 输出对应 shell 补全（如 `MAA_COMPLETE=bash maa`） |
| `XDG_CONFIG_HOME`（macOS） | 让 maa-cli 改用 XDG 风格配置目录 |

日志默认输出到 stderr；需要落盘时用 `--log-file` 或 `MAA_LOG` 组合，日志目录可用 `maa dir log` 查看。任务结束后会输出总结（各子任务耗时；fight 含关卡/次数/理智药/掉落统计，infrast 含进驻干员，recruit 含公招统计，roguelike 含探索与投资次数）。

## 8. DSH 环境执行要点（重要）

1. **OS 检测先行**：本环境命令工具在不同平台不同（Windows 用 pwsh，Linux/macOS 用 bash）。执行前用 `$env:OS`/`$IsWindows`（pwsh）或 `uname`（bash）判断平台，再选择对应的安装与命令写法。
2. **二进制名回退**：先 `maa` 后 `maa-cli` 探测（第 2 节）。**winget 安装的是 `maa-cli`**。
3. **交互式命令禁用**：`maa init`、`maa run`（含 Input/Select 参数）、`maa import` 可能交互询问。在非交互环境中优先直接写配置文件（profiles/*.toml、tasks/*.toml），需要跳过交互时加 `--batch`。
4. **长任务用后台运行，等待上限 15 分钟**：刷图/肉鸽/基建等任务可能运行数十分钟（游戏启动约 1-3 分钟，单次刷图约 2-4 分钟，完整日常编排可达 10-20 分钟）。通过工具的 `run_in_background` 启动，用 job 读取输出，不要同步阻塞等待；结束时用 `job_output` 收集结果。**等待任务时用 15 分钟（900 秒）级超时**：短超时（如 3 分钟）后任务往往仍在进行——此时 kill/中断会破坏正在运行的模拟器操作，造成任务半途失败（实测：前台 180 秒超时被 kill 后，模拟器内任务实际仍在继续，导致后续步骤连锁失败）。除非确认任务卡死（日志长时间无新输出且模拟器画面无动作、连接已断开），否则不要过早中断后台任务；`job_output` 用 `wait: true` 时也把超时设到 900 秒以上。
5. **先 `--dry-run` 校验**：运行真实任务前，先 `maa run <task> --dry-run` 或 `maa fight ... --dry-run` 验证配置与参数，避免连不上设备时卡死。
6. **沙箱/权限（一开始就提权，不要等报错）**：涉及模拟器/游戏的操作在受限沙箱下**必然失败**，判断到命令会触碰下列任一项时，**第一步就直接以完整权限（如 danger-full-access）运行**，不要先跑一遍等 EPERM/崩溃再升级：
   - **运行真实游戏任务**（startup / fight / roguelike / copilot / `maa run` 等任何连接模拟器的命令）：MaaCore 以管道方式 spawn adb 子进程，受限沙箱直接拒绝（EPERM，日志 `Connection command failed to exec`）；
   - **启动/控制模拟器**（`MuMuManager control launch`、直接启动 `MuMuNxMain.exe` 等）：沙箱内启动会 fail-fast 崩溃（退出码 0xC0000409，疑似命名管道 IPC 受限），实测必须在完整权限下才能拉起；
   - **`maa install/update`**（网络下载 + 写用户目录）与 Windows VC++ 运行库安装（需管理员）。
   
   `maa version`、`maa dir`、`maa list`、`maa remainder`、`maa convert`、`maa run --dry-run` 等纯本地/只读命令不需要提权。

   **开始运行前检测完整权限（每次运行真实任务前必做）**：运行任何连接模拟器/游戏的真实任务前，先检查当前会话是否有完整权限（Full Access）：
   - 检测方式：查看当前会话文件策略（系统提示中的 "Current DSH file policy"）是否为完整权限；不确定时先尝试以完整权限（如 `danger-full-access`）运行命令，被拒则说明当前无完整权限。
   - 无完整权限时：**先向用户提示需要 Full Access**（说明原因：受限沙箱下 MaaCore spawn adb 子进程必然 EPERM、启动模拟器必然崩溃），征得用户同意后再提权运行。
   - **豁免（无需再提示）**：① 用户在本对话中已明确告知可以使用完整权限；② `skill-config.toml` 中 `[permission] full_access = true`（用户在初始化时已同意，见 1.5 节）。
   - 用户尚未在 DSH 设置中开启完整权限时，可建议用户在 **设置-通用设置中将权限改为 Full Access**（README.md 有说明），或授权本次运行提权。
7. **模拟器检测与连接检查**：运行任务前先用 `scripts/maa-emulator-detect.ps1`（或 `.sh`）检测模拟器品牌/安装路径/adb/端口（4.5 节）；确认模拟器实例已启动且 ADB 可达。连接问题通常是 `address` 端口不对、`adb_path` 缺失或模拟器没开 ADB 开关。**任务必须在游戏客户端或模拟器运行的环境下执行**——若本机没有模拟器/游戏，如实告知用户无法实际运行。
   - **模拟器未运行时的完整启动流程（实测）**：① `MuMuManager.exe control launch -v <实例索引>`（MuMu 在安装目录 `nx_main\MuMuManager.exe`）拉起实例；② 轮询 `adb devices` 直到设备从 offline/缺失变为 `device`（MuMu 冷启动约 1-4 分钟，期间 `is_android_started = false`；也可用 `MuMuManager info -v <idx>` 查看）；③ 游戏不在前台时执行 `maa startup Official` 启动游戏（约 1-2 分钟）——**Android 重启后游戏必然回到桌面，不能跳过 startup 直接跑任务**。
   - **用户手动结束任务**：用户可能出于对执行结果的判断中途手动终止任务（关闭模拟器/杀掉进程）。此时 maa-cli 进程可能仍在后台 job 中运行但已断连，日志表现为 `Reconnect N times` → `Disconnected` → 大量 `ScreencapFailed`，任务最终报 Error——这是预期行为，不代表 MAA 本身故障。收到用户反馈「已手动结束」后：先 `job_kill` 清理残留后台 job，再按用户意图决定是否补跑剩余步骤；汇报时说明哪些子任务已完成、哪些被中断。
8. **国内网络**：GitHub 下载/热更新失败时，提示用户在 `cli.toml` 配置 `api_url`/`download_url` 镜像，或将资源热更新后端改为 `libgit2`（需要 git）。
9. **结果汇报**：任务结束后向用户汇报总结信息（掉落统计、刷取次数、日志路径 `maa dir log`），不要只回显退出码。**核查「名义完成」陷阱（v6.16.8 实测）**：Summary 中 Fight 子任务显示 Completed 不代表真的打了——若日志出现 `fight times reached max` 且对应 `FightTimes` 事件 `times_finished: 0`，说明作战被跳过（多半是 `times` 过小，见 5.2.1 与 FAQ）；汇报前用日志核对 `times_finished` / 掉落统计。
10. **技能内容保护（modify_skill）**：除非 `skill-config.toml` 中 `[permission] modify_skill = true` 或用户明确要求，否则**不得修改本 skill 目录内的任何文件**（SKILL.md、README.md、scripts/、references/、schemas/ 等）。该开关默认 `false`，且**只能由用户明确指示更改**——harness/agent 不得自行改动该值。

## 9. 常见问题排查

| 现象 | 处理 |
| --- | --- |
| `maa version` 报 MaaCore 未找到 | 执行 `maa install`；Windows 先装 VC++ 运行库（第 3.2 节） |
| 连接失败 / 一直停在连接 | 运行 `scripts/maa-emulator-detect.ps1 -Probe` 确认品牌/端口；检查模拟器 ADB 开关（蓝叠需开启）；用 `-a` 临时覆盖 |
| 检测脚本找不到模拟器 | 手动定位：`-Path <模拟器安装目录>`（或 `-Adb <adb路径> -Address <地址>`），脚本会输出建议配置 |
| 报 `Connection command failed to exec` | `adb_path` 未指向可执行 adb（不在 PATH 或路径错）；或沙箱禁止 MaaCore spawn adb 子进程（EPERM），需以完整权限运行 |
| **刷图停不下来 / 反复执行多次倍率作战（用户预期一次）** | **`times` 未设置，默认无限（2147483647）**：只设 `series = X` 会无限重复 X 倍率作战。必须显式设 `times`（见 5.2.1 警示框：**v6.16.8 起 `times`=总战斗次数上限，一次 X 倍率作战写 `{ series = X, times = X }`**；旧版才是 `{ series = X, times = 1 }`） |
| **刷图「名义完成、实际一次没打」（Summary 显示 Fight Completed，但日志 `fight times reached max` 且 `times_finished: 0`）** | **`times` 过小导致跳过作战（v6.16.8 实测）**：源码 `FightTimesTaskPlugin::_run()` 中 `m_fight_times + series > times` 即判定「战斗次数超过上限」并跳过本次作战。例：`times=1, series=3` → `0+3>1` → 直接跳过。修正为 `times` ≥ 计划作战总次数（一次 3 倍率作战用 `times=3`），重跑前先看 `maa version` 的 MaaCore 版本号 |
| **日志出现 `Unknown task: FightSeries-OldMethodFlag` / `Task FightSeries-OldMethodFlag not found`（ERR）** | **无害噪音（v6.16.8 实测）**：MaaCore 用 `Task.get("FightSeries-OldMethodFlag") == nullptr` 探测新旧连战列表（`is_new_series_list = true` 走新版选择逻辑），任务不存在属正常路径，不要当作故障排查；真正的故障要看 `fight times reached max` + `times_finished: 0` 组合 |
| **任务中途大量 `ScreencapFailed` / `Disconnected` / `Reconnect N times`** | 多为模拟器/设备断连（模拟器崩溃、手动结束任务、adb 服务重启、Android 重启）。先 `adb devices` 确认设备在线；离线则等 Android 启动完成（`adb devices` 从 offline → device，MuMu 可用 `MuMuManager.exe info -v <idx>` 看 `is_android_started`），游戏若不在前台需重新 `maa startup` |
| **模拟器重启后 `adb devices` 显示 offline / device not found** | Android 系统还在启动（MuMu 约 1-4 分钟）。轮询等待设备从 offline 变为 device；长时间无果用 `MuMuManager control launch -v <idx>` 重新拉起实例 |
| **skill-config 与 profiles/default.toml 的连接参数不一致** | skill-config 探测的是品牌/端口候选，`profiles/default.toml` 才是 maa-cli 实际使用的连接配置（adb_path、address）。两者不一致会导致连错设备/失败——运行前核对 profile 的 adb_path 与 address 是否与探测结果一致（本机实测：skill-config 记录 MuMu 12 端口 16384，但旧 profile 指向 MuMu 6 的 7555，需改正） |
| `maa run` 卡在输入提示 | 交互参数导致；加 `--batch` 或改配置文件提供 `default` |
| 下载/热更新失败 | 检查网络；配置镜像或 `backend = "libgit2"`（git 后端需本机 git） |
| 自定义任务静默不生效 | maa-cli 不校验参数名；对照集成文档核对 `type` 与 `params`，先 `--dry-run` |
| 基建不按计划换班 | 基建计划须为 JSON 且位于 `$MAA_CONFIG_DIR/infrast/`，用任务条件 `plan_index` 分班 |
| 日志太多/太少 | `MAA_LOG=debug` 或 `-v`/`-q`；落盘用 `--log-file` |
| winget 装的命令找不到 | 二进制名是 `maa-cli` 不是 `maa` |
| Windows 下 `--log-file` 无参数报 `os error 123` | 默认日志路径含冒号（HH:MM:SS）非法；显式指定 `--log-file="C:\path\run.log"` |
| **运行日志出现 `Resource directory ... not found, ignoring`（WARN）** | 通常无害：只是热更新/用户资源目录缺失，MaaCore 主资源（`$MAA_DATA_DIR/resource` 或 MAA 安装目录 junction 指向的资源）仍正常加载。确认 `maa version` 能读到 MaaCore 版本即可继续 |

## 10. 参考资料

`references/` 目录内置 maa-cli 官方文档副本与 MAA 官方连接/设备文档：

- `zh-CN/intro.md`、`zh-CN/install.md`、`zh-CN/usage.md`、`zh-CN/config.md`、`zh-CN/faq.md`
- `en-US/` 同名英文版
- `schemas/`：`task.schema.json`、`asst.schema.json`、`cli.schema.json`
- `maa-official/`：MAA 官方「连接设置」「Windows/Linux/macOS 模拟器设备」文档副本（模拟器品牌支持矩阵、端口表、蓝叠 Hyper-V 配置等）
- **`maa-official/integration.html`**：**MAA 集成文档（协议文档）完整副本**——全部任务类型（StartUp / CloseDown / Fight / Recruit / Infrast / Depot / Roguelike / Copilot / Reclamation 等）与全部参数说明、示例 JSON（约 6600 字）。**用户意图不明确、不确定某操作对应哪个任务/指令时，优先查这里**，再对照 `cli/commands.md` 找到对应 maa-cli 命令。
- **`cli/commands.md`**：全部命令参考——根命令与 25 个子命令的 `--help` 完整输出（约 1630 行，含各运行类命令的通用参数：`-a/--addr`、`-p/--profile`、`--dry-run`、`--batch`、`--log-file` 等）。理解用户指令、核对参数名、查看某命令支持哪些选项时优先查这里。
- **`cli/man/`**：`maa mangen` 生成的 26 个 man 手册（`maa-<命令>.1`），覆盖全部命令的完整参数说明；可用 `man -l <文件>` 或直接读取查看。
- **`scripts/maa-skill-init.ps1` / `.sh`**：初始化脚本（1.5 节），探测 MAA / maa-cli / 模拟器 / 权限并读写 skill 配置（Windows：`%USERPROFILE%\.dsh\maa-config\skill-config.toml`；Linux/macOS：`$MAA_CONFIG_DIR/skill-config.toml`）。

需要最新内容或未覆盖的细节时，先读这些本地副本；仍不够再访问官方仓库文档链接。

## 11. 打包发布

需要把本技能打包为可分发的压缩包（如发布新版本、拷贝到其它电脑）时，**直接参考本目录下的 `PACKAGING.md`**（打包方法与完整命令，含 zip 命名规则、顶层目录名 `maa-dsh-skill`、放置位置等）。打包前记得：

1. 更新 `SKILL.md` frontmatter 的 `metadata.version` 与正文首行的技能版本号（README 中的版本号同步更新）；
2. 打包目录名与 zip 文件名中的版本号保持一致（如 `0.0.1-rc5` → `MAA-dsh-skill-v0.0.1-rc5.zip`）；
3. 打包后先解压到临时目录验证结构（顶层目录应为 `maa-dsh-skill`），再分发。

## 12. 用户默认选项

用户指定的默认选项见 **`templates/default-options.md`**（选项 ↔ MAA 参数对照表）与 **`templates/default-options.toml`**（可直接复用的 maa-cli 任务模板）。要点：

- **理智作战（Fight）**：不使用药剂（`medicine = 0`）、不使用源石（`stone = 0`）。
- **基建换班（Infrast）**：队列轮换（`mode = 20000`）、不使用无人机（`drones = "_NotUse"`）、源石碎片自动补货（`replenish = true`）、会客室收取信息板信用（`reception_message_board = true`）、进行线索交流（`reception_clue_exchange = true`）、不赠送线索（`reception_send_clue = false`）、训练室专精完成后不继续尝试（`continue_training = false`）。
- **自动肉鸽（Roguelike）**：开始探索 2 次后停止任务（`starts_count = 2`）、满级后自动停止（`stop_at_max_level = true`）。

编排任务时如用户未另行指定，默认采用以上取值；运行期参数（如 Fight 的 `stage`、Roguelike 的 `theme`/`squad`/`roles`/`core_char`/`difficulty`）按具体需求补充。
