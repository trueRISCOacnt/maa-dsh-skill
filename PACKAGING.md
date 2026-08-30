# 打包发布方法（PACKAGING.md）

> 本文件说明如何把本 skill（`maa-dsh-skill`）打包为可分发的压缩包。**以后需要发布新版本或拷贝到其它电脑时，直接按本文件操作即可。**

## 1. 打包约定

| 项 | 规则 |
| --- | --- |
| zip 文件名 | `MAA-dsh-skill-v<版本>.zip`，如 `MAA-dsh-skill-v0.0.1.zip` |
| 解压后顶层目录名 | **`maa-dsh-skill`**（zip 内所有文件位于 `maa-dsh-skill/` 下） |
| 放置位置 | 由发布者指定；本机惯例为桌面新建的发布文件夹（如 `Desktop\MAA-dsh-skill-release\`） |

## 2. 打包前检查清单

1. **版本号一致**：以下位置的版本号必须与将要发布的版本一致：
   - `SKILL.md` frontmatter：`metadata.version`
   - `SKILL.md` 正文首行「技能版本：…」
   - `README.md` 与 `README-full.md` 首行「技能版本：…」
   - 打包目录名 / zip 文件名
2. **内容完整**：确认包含 `SKILL.md`、`README.md`、`README-full.md`、`PACKAGING.md`、`references/`、`scripts/`。
3. **无临时文件**：排除 `*.log`、`.git/`、`__pycache__/` 等不需要分发的内容。

版本号快速检查（PowerShell，在 skill 目录内执行）：

```powershell
Select-String -Path SKILL.md,README.md,README-full.md -Pattern "0\.0\.1-rc" | ForEach-Object { "$($_.Filename): $($_.Line.Trim())" }
```

## 3. 打包步骤（Windows PowerShell 示例）

以发布 `v0.0.1` 为例（把 `$version` 换成实际版本号即可复用）：

```powershell
$version = "vv0.0.1"
$skillSrc = "C:\Users\test\.dsh\skills\maa-dsh-skill"                      # 技能源目录
$desktop  = [Environment]::GetFolderPath('Desktop')
$release  = Join-Path $desktop "MAA-dsh-skill-release"                    # 桌面发布文件夹（可自定义）
$stage    = Join-Path $env:TEMP "maa-skill-stage"                         # 临时暂存目录
$zipPath  = Join-Path $release "MAA-dsh-skill-v$version.zip"              # 最终 zip

# 1) 准备发布文件夹与暂存目录
New-Item -ItemType Directory -Force -Path $release | Out-Null
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# 2) 复制技能内容到暂存目录下的 maa-dsh-skill/（保证解压后顶层目录名为 maa-dsh-skill）
Copy-Item $skillSrc (Join-Path $stage "maa-dsh-skill") -Recurse

# 3) 清理临时文件（如有）
Get-ChildItem (Join-Path $stage "maa-dsh-skill") -Recurse -Include "*.log" -File | Remove-Item -Force -ErrorAction SilentlyContinue

# 4) 打包
Compress-Archive -Path (Join-Path $stage "maa-dsh-skill") -DestinationPath $zipPath -Force

# 5) 验证：解压后顶层目录应为 maa-dsh-skill
$verify = Join-Path $env:TEMP "maa-skill-verify"
if (Test-Path $verify) { Remove-Item $verify -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $verify
"zip 顶层内容: " + ((Get-ChildItem $verify | Select-Object -ExpandProperty Name) -join ", ")
"zip 位置: $zipPath"

# 6) 清理暂存/验证目录
Remove-Item $stage -Recurse -Force
Remove-Item $verify -Recurse -Force
```

> 💡 若本机没有 PowerShell 之外的工具，`Compress-Archive` / `Expand-Archive` 为 Windows 内置 cmdlet，无需额外安装。

## 4. Linux / macOS（bash 示例）

```bash
version="v0.0.1"
skill_src="$HOME/.dsh/skills/maa-dsh-skill"
release="$HOME/Desktop/MAA-dsh-skill-release"
stage="$(mktemp -d)"

mkdir -p "$release"
cp -r "$skill_src" "$stage/maa-dsh-skill"
cd "$stage"
zip -r "$release/MAA-dsh-skill-v${version}.zip" maa-dsh-skill
unzip -l "$release/MAA-dsh-skill-v${version}.zip" | head -5   # 验证顶层为 maa-dsh-skill/
rm -rf "$stage"
```

## 5. 发布后验证

1. 解压 zip 到临时目录，确认顶层文件夹名为 `maa-dsh-skill`；
2. 将 `maa-dsh-skill/` 放入 DSH skill 发现目录（如 `~/.dsh/skills/`），确认 DSH 能发现技能 `maa-dsh-skill`；
3. 在 DSH 中「加载技能 maa-dsh-skill」并执行 `maa version`（只读，无需权限）确认环境正常。
