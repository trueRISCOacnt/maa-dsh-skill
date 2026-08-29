# MAA-dsh-skill — 完整指引

> 📦 **技能版本：0.0.1-rc6**，适用于 **maa-cli v0.7.5**（对应 **MAA v6.11.0 及以后**）。
>
> 📄 本文档是**完整指引**（原 README，随版本保留为详细说明）；简版项目 README（含部署方式）见 [`README.md`](./README.md)。

基于 [MaaAssistantArknights (MAA)](https://github.com/MaaAssistantArknights/MaaAssistantArknights) 官方命令行工具 [maa-cli](https://github.com/MaaAssistantArknights/maa-cli) 构建的 DeepSeek Harness Skill，用于通过 MaaCore 自动化完成《明日方舟》游戏任务。跨平台支持 Windows / Linux / macOS。

> MAA 主仓库 README「CLI 支持」一节指向的官方使用指南：<https://docs.maa.plus/zh-cn/manual/cli/>

本目录（解压后顶层目录名为 `maa-dsh-skill`）是**可分发的完整 Skill 包**：内含技能本体（SKILL.md、官方文档、JSON Schema、跨平台脚本）与打包发布说明。将整个文件夹拷贝到其它电脑即可安装使用（见下文「在其它电脑上使用」）。

> 💡 **平台说明**：目前该 skill 适用于 **Windows**。理论上该 skill 适用于其它操作系统（Linux/macOS 脚本与路径逻辑已内置），但**尚未验证**。

## 结构

```
maa-dsh-skill/                          # 解压后顶层目录（= 安装到 .dsh/skills/ 下的 maa-dsh-skill 目录）
├── README.md                     # 项目 README（简短，含部署方式占位）
├── README-full.md                # 完整指引（本文件）
├── SKILL.md                      # 技能主文件（frontmatter + 使用说明）
├── PACKAGING.md                  # 打包发布方法（后续打包时参考）
├── references/                   # 官方文档副本 + JSON Schema
│   ├── zh-CN/                    # maa-dsh-skill 文档：intro / install / usage / config / faq
│   ├── en-US/                    # 同名英文版
│   ├── maa-official/             # MAA 官方连接/设备文档（模拟器支持矩阵、端口表、蓝叠 Hyper-V 配置）+ 集成文档 integration.html（全部任务类型与参数，意图↔指令查表用）
│   └── schemas/                  # task / asst / cli 三个 JSON Schema
└── scripts/
    ├── maa-probe.ps1 / .sh              # 环境探测（maa-cli / MaaCore 是否就绪）
    ├── maa-emulator-detect.ps1 / .sh    # 模拟器检测（自动 + 手动定位 + -Probe 实时端口）
    └── maa-skill-init.ps1 / .sh         # 初始化：探测 MAA/maa-cli/模拟器/权限，读写 skill-config.toml
```

## 安装到 DSH（本机）

Skill 的发现根目录（按优先级）：

| 优先级 | 位置 |
| --- | --- |
| 项目级 | `<项目根>/.dsh/skills/`（本目录即项目根，已生效） |
| 用户级 | `$DSH_HOME/skills/`（默认 `~/.dsh/skills/`，全会话可用） |

当前工作区下的 `.dsh/skills/` 已直接被当前 DSH 会话发现（技能目录中可见 `maa-dsh-skill`）。如需全局使用，将 `maa-dsh-skill/` 整个目录复制到 `~/.dsh/skills/` 即可。

## 部署方式（在其它电脑上使用）

### 方式一：使用 npm 安装（DSH 插件 Bundle）

把本技能作为 **DSH 插件 Bundle** 装入 DSH profile：安装后插件会在 profile 启动时把包内 `SKILL.md` 注册为「运行时技能」，AI 助手即可在会话中直接加载该技能。

**前置条件**：目标电脑已安装 DSH 与 [pnpm](https://pnpm.io/)（`dsh plugin` 通过 pnpm 安装插件）。

**第一步：获取包**  

任选其一：

- 从 Github 上下载[最新的 Releases](https://github.com/EricsonXu114514/maa-dsh-skill/releases/latest)
- 本地目录 / tarball：解压 `MAA-dsh-skill-v<版本>.zip` 得到的 `maa-dsh-skill/` 目录，或 `npm pack` 生成的 `maa-dsh-skill-<版本>.tgz`；
- ~~从 npm registry（若已发布）：包名 `maa-dsh-skill`~~ 以后会有的（

**第二步：安装到 profile**

```bash
dsh plugin --profile web add ./maa-dsh-skill                    # 本地目录
dsh plugin --profile web add ./maa-dsh-skill-0.0.1-rc6.tgz      # npm tarball
```

~~若使用 npm registry：~~

```bash
dsh plugin --profile web add maa-dsh-skill                     # registry 包名，现在还无法使用
```

（`web` 为默认 profile 名，首次使用会自动初始化；安装成功且包声明了 `dsh.bundle` 时，`dsh plugin` 会自动把包加入 profile 的 `dsh.profile.bundles` 层列表。）

**第三步：验证**

```bash
dsh --profile web --dump-config     # 组合树中应出现 `# == maa-dsh-skill` 层
```

启动 profile 后，日志出现 `[maa-dsh-skill] Skill loaded!` 与 `[maa-dsh-skill] skill "maa-dsh-skill" registered ...` 即注册成功（插件从包内读取 `SKILL.md` 注册为运行时技能）。

**更新与卸载**

```bash
dsh plugin --profile web update maa-dsh-skill   #更新
dsh plugin --profile web remove maa-dsh-skill   #卸载
```

> 💡 npm 方式与复制文件方式（方式二）可并存：若同一技能同时存在于 skill 发现根，文件系统技能优先，插件注册的同名技能会被注册表自动忽略，互不冲突。

### 方式二：直接复制文件（[从 GitHub Releases 下载](https://github.com/EricsonXu114514/maa-dsh-skill/releases/latest)）

**第一步：下载。** 从本技能项目的 **GitHub Releases** 页面[下载最新版 `MAA-dsh-skill-<版本>.zip`](https://github.com/EricsonXu114514/maa-dsh-skill/releases/latest)，解压后得到顶层目录 `maa-dsh-skill/`。

**第二步：安装 Skill。** 在目标电脑上把 `maa-dsh-skill` 文件夹放到 DSH 的 skill 发现根目录之一：

```bash
# 方式 A（推荐）：用户级，所有 DSH 会话可用
#   Windows: 复制到  C:\Users\<用户名>\.dsh\skills\maa-dsh-skill
#   Linux/macOS: 复制到  ~/.dsh/skills/maa-dsh-skill
cp -r maa-dsh-skill ~/.dsh/skills/maa-dsh-skill

# 方式 B：项目级，仅该项目可用
#   复制到  <项目根>/.dsh/skills/maa-dsh-skill
```

> 目标电脑若配置了 `DSH_HOME`（如 `/opt/dsh`），用户级目录为 `$DSH_HOME/skills/maa-dsh-skill`。`.agents/skills/` 根目录同样兼容（技能发现会扫描 `.dsh/skills` 与 `.agents/skills`）。

在这之后，文件夹的结构应该长这样：
```
%userprofile%/
└──.dsh/
    └──skills/
        └──maa-dsh-skill/
            ├── references/
            ├── scripts/
            ├── PACKAGING.md
            ├── README.md
            ├── README-full.md
            └── SKILL.md
```

**第三步：验证。** 在 DSH 对话中发送「列出可用技能」或直接说「加载技能 maa-dsh-skill」；也可让模型运行 `scripts/maa-probe.ps1`（Windows）或 `scripts/maa-probe.sh`（Linux/macOS）探测环境。技能目录更新由 DSH 实时监测，无需重启。

**第四步：准备运行环境（目标电脑）。** 技能本身只是指令集，真正执行需要**两个组件同时就位，缺一不可**：

| 组件 | 作用 | 来源 |
| --- | --- | --- |
| **MAA（MaaCore）** | 核心引擎，提供 `MaaCore.dll` 与 `resource/` 识别资源 | MAA GUI 安装包 / 便携版，或 `maa install` |
| **maa-cli** | 命令行前端，负责解释命令、加载 MaaCore 并执行任务 | `winget install maa-cli`、官方 install.ps1/install.sh、brew、AUR 等 |

> ⚠️ **重要**：只装 MAA GUI 或只装 maa-cli 都无法工作——**两者必须同时下载安装**。MAA 提供引擎与资源，maa-cli 提供命令行入口；没有 maa-cli 就无法以命令行方式驱动自动化，没有 MAA（MaaCore）maa-cli 也只是空壳（`maa version` 会报 MaaCore 未找到）。

安装后运行初始化（`scripts/maa-skill-init.ps1` / `.sh`）——**初始化会同时搜索 MAA 与 maa-cli**（还探测模拟器与权限设置），并把结果保存到 skill 配置文件（Windows：`%USERPROFILE%\.dsh\maa-config\skill-config.toml`；Linux/macOS：`$MAA_CONFIG_DIR/skill-config.toml`）；首次会写入，之后每次初始化直接读取，无需重复探测：

> 💡 **省时建议**：首次初始化时，如果你**知道 MAA 或 maa-cli 所在的位置**（文件夹或二进制路径），直接告诉模型或传给脚本（Windows `-MaaPath` / `-CliPath`，Linux/macOS `--maa` / `--cli`），可**省去自动搜索的时间与 token**；不知道时才由脚本自动搜索常见路径。

1. **MAA（MaaCore）**：未装时运行 `maa install`（Windows 需先装 VC++ 运行库）；已装 MAA GUI/便携版可直接复用其 MaaCore（技能 4.6 节，免下载）。
2. **maa-cli 二进制**：Windows `winget install maa-cli` 或官方 install.ps1；macOS `brew install MaaAssistantArknights/tap/maa-cli`；Linux 包管理器或 install.sh（详见技能第 3 节）。
3. **模拟器 + 游戏**：MuMu / 雷电 / 蓝叠 / 夜神 / 逍遥 等官方支持品牌（技能 4.5 节可用 `maa-emulator-detect` 自动检测与手动定位）。
4. **DSH 权限（Full Access）**：见下文专节。

**跨平台注意**：脚本均为双平台版本（`.ps1` 用于 Windows PowerShell，`.sh` 用于 Linux/macOS bash）；二进制名差异（winget 安装为 `maa-cli`，其余为 `maa`）技能已内置探测逻辑。

## DSH 权限（Full Access）—— 必读

MAA 自动化需要**通过 ADB 控制模拟器**（截图、点击、启动游戏），这要求 DSH 具备完整权限；受限沙箱下这些操作必然失败（MaaCore 无法 spawn adb 子进程，EPERM；沙箱内启动模拟器会崩溃）。

**请提前在 DSH 中开启完整权限：设置 → 通用设置 → 权限改为 "Full Access"**。

技能会在每次开始运行真实任务前**检测完整权限**：

- 有完整权限 → 直接运行；
- **无完整权限 → 会先提示你**需要 Full Access（说明原因），征得同意后才提权运行；
- 以下两种情况**不再提示**，直接使用完整权限运行：
  1. 你在对话中明确告知可以使用完整权限；
  2. 初始化时在 skill 配置文件（Windows：`%USERPROFILE%\.dsh\maa-config\skill-config.toml`；Linux/macOS：`$MAA_CONFIG_DIR/skill-config.toml`）中写明 `[permission] full_access = true`（运行 `scripts/maa-skill-init.ps1 -FullAccess` 即可写入）。

`maa version`、`maa dir`、`maa list`、`maa run --dry-run` 等纯本地/只读命令不需要完整权限。

## 技能内容保护开关（modify_skill）

`skill-config.toml` 中的 `[permission] modify_skill` 控制 **harness / agent 是否可以更改本 skill 的内容**（SKILL.md、README.md、scripts/、references/、schemas/ 等）。

- **默认 `false`**：除非用户明确要求，harness/agent 不得修改 skill 内的任何文件；
- **该值只能由用户明确指示更改**，harness/agent 不得自行修改（初始化脚本 `maa-skill-init.ps1` / `.sh` 只会原样保留该值，不会覆盖）；
- 用户开启方式：在对话中明确指示，或直接编辑 `%USERPROFILE%\.dsh\maa-config\skill-config.toml`（Windows）/ `$MAA_CONFIG_DIR/skill-config.toml`（Linux/macOS），将 `modify_skill` 改为 `true`。

## ⚠️ 重要：使用前请先运行一次 MAA

**如果目标电脑上还没有事先运行过 MAA（GUI 或便携版），本技能将以 MAA 的默认配置来执行任务**，可能出现意想不到的事故。目前已知：

- **基建人员被打乱**：默认配置下基建任务按 MAA 内置默认逻辑自动入驻（不是基建换班），可能调动你不希望调整的干员。
- ……

**首次使用本技能前，请先手动打开一次 MAA（GUI）并确认、保存好你的设置**（尤其是基建排班方案、常刷关卡、理智药策略）；每次运行真实任务前，也可先执行 `maa run <任务> --dry-run` 校验配置是否符合预期。

## 使用

模型在对话中提及「用 MAA 自动化明日方舟 / 安装配置 MAA / 编写自定义任务」等请求时会自动加载该技能。也可手动触发：

```text
加载技能 maa-dsh-skill
```

技能内含：跨平台安装（winget / brew / AUR / nix / 安装脚本 / cargo）、MaaCore 安装与更新、profiles 与 cli.toml 配置、**模拟器检测与手动定位**（`maa-emulator-detect`，官方优先品牌 MuMu/雷电/蓝叠/夜神/逍遥 + macOS/Linux 设备）、预定义任务（fight / roguelike / copilot / reclamation / startup / closedown 等）、自定义任务与条件编排、复用已安装 MAA、环境变量、日志与排查、以及 DSH 环境下的执行要点（二进制名 `maa` vs `maa-cli` 差异、**一开始就提权**、`--batch` 非交互、后台长任务、`--dry-run` 校验等）。

每次会话开始（初始化）时，模型会运行 `scripts/maa-skill-init.ps1` / `.sh`：**同时搜索 MAA 与 maa-cli**（以及模拟器、权限设置），首次探测结果写入 skill 配置文件（Windows：`%USERPROFILE%\.dsh\maa-config\skill-config.toml`；Linux/macOS：`$MAA_CONFIG_DIR/skill-config.toml`），之后直接读取，无需重复探测。

## 用户默认选项

> 用户指定的默认选项（写入时间：2026-08-28）。运行 MAA 任务时默认采用以下设置；具体任务可在此基础上覆盖。可直接使用的 maa-cli 任务模板见同目录 `templates/default-options.toml`（选项 ↔ 参数对照见 `templates/default-options.md`）。

**理智作战（Fight）**

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 使用药剂 | 0 | `medicine = 0` |
| 使用源石 | 0 | `stone = 0` |

**基建换班（Infrast）**

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 基建模式 | 队列轮换（Rotation） | `mode = 20000` |
| 无人机 | 不使用 | `drones = "_NotUse"` |
| 源石碎片自动补货 | true | `replenish = true` |
| 会客室信息板收取信用 | true | `reception_message_board = true` |
| 进行线索交流 | true | `reception_clue_exchange = true` |
| 赠送线索 | false | `reception_send_clue = false` |
| 训练完成后继续尝试专精当前技能 | false | `continue_training = false` |

> 注：`continue_training` 对应 MAA GUI「基建-训练室是否尝试连续专精」（MaaCore Infrast 任务参数，见 MaaWpfGui `AsstInfrastTask.cs` 序列化的 `continue_training` 键）。队列轮换模式下会跳过控制中枢/发电站/宿舍/办公室，`facility` 建议在 Mfg/Trade/Reception/Processing/Training 中选取。

**自动肉鸽（Roguelike）**

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 开始探索 N 次后停止任务 | 2 | `starts_count = 2` |
| 满级后自动停止 | true | `stop_at_max_level = true` |

## 验证

- frontmatter：`name`（kebab-case）与 `description` 必填，YAML 解析通过
- 发现：DSH watcher 实时监测，`SKILL.md` 写入后目录即时更新
- 脚本：`maa-probe.ps1` 已在 Windows PowerShell 5.1 下实测通过
- 端到端实测（2026-08-16，Windows 11 + MuMu 12 模拟器 + MAA v6.10.5）：

| 项目 | 结果 |
| --- | --- |
| `maa version`（复用已装 MAA 6.10.5 的 MaaCore.dll，v6.16.8） | ✅ |
| `maa dir config` / `maa list` / `maa remainder` / `maa convert` | ✅ |
| `maa activity`（联网拉取当前活动数据） | ✅ |
| 自定义任务 `maa run daily --dry-run`（配置校验） | ✅ |
| `maa startup Official`（连接模拟器→拉起游戏→识别主界面，1m12s） | ✅ |
| `maa fight TO-5 --times 1`（真实战斗+掉落结算：装置×1、酮凝集×1 等，3m21s） | ✅ |

实测发现并回写进 SKILL.md 的要点：`adb_path` 需指向实际 adb（MuMu 12 自带 adb 路径）、实际端口以 `MuMuManager info -v all` 为准（本机为 16416 而非 16384）、沙箱中真实游戏任务需完整权限（MaaCore spawn adb 管道子进程会 EPERM）、模拟器主程序在沙箱内启动会崩溃（0xC0000409，需完整权限）、**涉及模拟器/游戏的操作应一开始就提权而非等报错**、复用已安装 MAA 的 junction + 环境变量方案（SKILL.md 4.6 节）。

### 模拟器检测功能实测（新增）

| 场景 | 结果 |
| --- | --- |
| `maa-emulator-detect.ps1` 自动检测（本机 MuMu 12） | ✅ 识别品牌/安装路径/adb/官方端口表 |
| `-Path` 手动定位（MuMu 安装目录） | ✅ 输出品牌/adb/建议配置；无效路径正确报错 exit 1 |
| `-Probe`（实例未运行时） | ✅ 快速跳过端口探测，不挂起 |
| `-Probe`（实例运行时，完整权限） | ✅ MuMuManager 读到实例 `0-1` 端口 16416 → adb 连接成功 → 建议配置自动带 `address = "127.0.0.1:16416"` |
| 沙箱内启动 MuMu 主程序 | ❌ fail-fast 崩溃（0xC0000409）→ 完整权限下正常启动（已写入技能 8.6 节） |

## 打包发布

需要把本技能打包为可分发的 zip 时，参考 [`PACKAGING.md`](./PACKAGING.md)（含 zip 命名规则、顶层目录名 `maa-dsh-skill`、放置位置与完整命令）。

### 更改版本号时需修改的文件与位置

当前版本为 **0.0.1-rc6**。升级 / 发布新版本时，需把下表所有位置的版本号**同步更新**（行号为当前版本的行号，文档变动后请按「位置」描述定位）：

| 文件 | 位置 |
| --- | --- |
| `package.json` | `version` 字段（第 3 行） |
| `SKILL.md` | frontmatter `metadata.version`（第 6 行） |
| `SKILL.md` | 正文首行「技能版本：…」徽标（第 15 行） |
| `SKILL.md` | 第 11 节「打包发布」示例 `0.0.1-rc6` → `MAA-dsh-skill-v0.0.1-rc6.zip`（第 538 行） |
| `README.md` | 首行版本徽标 `v0.0.1-rc6`（第 3 行） |
| `README-full.md`（本文件） | 首行「技能版本：…」徽标（第 3 行） |
| `README-full.md`（本文件） | 「部署方式」中 tarball 安装示例 `maa-dsh-skill-0.0.1-rc6.tgz`（第 65 行） |
| `PACKAGING.md` | 第 1 节 zip 命名示例 `MAA-dsh-skill-v0.0.1-rc6.zip`（第 9 行） |
| `PACKAGING.md` | 第 3 节 PowerShell 示例 `$version = "0.0.1-rc6"`（第 33 行） |
| `PACKAGING.md` | 第 4 节 bash 示例 `version="0.0.1-rc6"`（第 71 行） |

> ⚠️ 注意：`PACKAGING.md` 第 2 节的「版本号快速检查」命令只扫描 `SKILL.md`、`README.md`、`README-full.md` 三个 Markdown 文件，**不覆盖 `package.json` 及 `PACKAGING.md` 中的示例**，改完后请自行核对上表所有位置。
>
> 打包发布时，GitHub Releases 的 tag 与 zip 文件名（`MAA-dsh-skill-v<版本>.zip`）也应使用同一版本号。

## 参考

- maa-cli 仓库与文档：<https://github.com/MaaAssistantArknights/maa-cli>
- MAA CLI 使用指南：<https://docs.maa.plus/zh-cn/manual/cli/>
- MAA 集成文档（任务类型与参数）：<https://docs.maa.plus/zh-cn/protocol/integration.html>（skill 内已内置本地副本：`maa-cli/references/maa-official/integration.html`，用于意图 ↔ 指令查表）
