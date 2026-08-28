# MAA-dsh-skill

> 📦 **v0.0.1-rc5** ｜ 适用于 **maa-cli v0.7.5**（对应 **MAA v6.11.0 及以后**）｜ Windows / Linux / macOS

基于 [MaaAssistantArknights (MAA)](https://github.com/MaaAssistantArknights/MaaAssistantArknights) 官方命令行工具 [maa-cli](https://github.com/MaaAssistantArknights/maa-cli) 构建的 **DeepSeek Harness Skill**：让 AI 助手直接驱动 MaaCore，自动化完成《明日方舟》日常任务。

## 特性

- 🎮 刷关卡（含连战）、集成战略、生息演算、自动抄作业
- 🏗️ 基建收取与换班、公开招募、仓库识别
- 🔌 自定义任务编排（多任务流水线 + 条件变体）
- 🖥️ 模拟器自动检测与连接（MuMu / 雷电 / 蓝叠 / 夜神 / 逍遥）
- 📚 内置 maa-cli 官方文档本地副本（中英）、MAA 集成文档、JSON Schema
- 🧩 跨平台初始化与模拟器检测脚本（`.ps1` / `.sh`）

## 部署方式

以下两种部署方式的具体步骤将在后续版本中补充：

### 方式一：使用 npm 安装

<!-- TODO: 待填写 `dsh plugin add` 方式的具体步骤 -->

### 方式二：直接复制文件

<!-- TODO: 待填写直接复制文件方式的具体步骤 -->

> 💡 在此之前，可先按[完整指引](./README-full.md)中的「安装到 DSH」/「在其它电脑上使用」章节手动部署。

## 快速开始

1. 解压本包，得到顶层目录 `maa-dsh-skill/`；
2. 将 `maa-dsh-skill/` 复制到 DSH 的 skill 发现根目录（如 `~/.dsh/skills/maa-dsh-skill`）；
3. 在 DSH 中加载技能：`加载技能 maa-dsh-skill`；
4. 运行 `scripts/maa-skill-init.ps1`（Windows）或 `scripts/maa-skill-init.sh`（Linux/macOS）初始化环境；
5. 在 DSH 中开启 **Full Access** 权限（MAA 需要通过 ADB 控制模拟器）。

> ⚠️ 真正执行任务前，还需安装 **MAA（MaaCore）** 与 **maa-cli** 二进制，并准备模拟器与游戏客户端——详细步骤见[完整指引](./README-full.md)。

## 文档

| 文档 | 说明 |
| --- | --- |
| [README-full.md](./README-full.md) | **完整指引**：安装、分发、Full Access 权限、使用、验证 |
| [PACKAGING.md](./PACKAGING.md) | 打包发布方法 |
| [SKILL.md](./SKILL.md) | 技能使用说明（面向 AI 助手的完整流程与命令参考） |

## 致谢

- 本skill几乎完全由[DeepSeek Harness](https://www.deepseek.com/harness/)使用**deepseek-v4-flash**编写
- [MaaAssistantArknights / MAA](https://github.com/MaaAssistantArknights/MaaAssistantArknights)
- [MaaAssistantArknights / maa-cli](https://github.com/MaaAssistantArknights/maa-cli)
- 官方使用指南：<https://docs.maa.plus/zh-cn/manual/cli/>
