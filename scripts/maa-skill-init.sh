#!/usr/bin/env bash
# MAA skill 初始化脚本（Linux / macOS）：探测 MAA / maa-cli / 模拟器 / 权限设置，
# 并读写 skill 下的 skill-config.toml。
#
# 用法：
#   bash .dsh/skills/maa-cli/scripts/maa-skill-init.sh                 # 读取已有配置；首次则探测并写入
#   bash .dsh/skills/maa-cli/scripts/maa-skill-init.sh --force         # 忽略已有配置，重新探测
#   bash .dsh/skills/maa-cli/scripts/maa-skill-init.sh --full-access   # 声明用户同意完整权限
#   bash .dsh/skills/maa-cli/scripts/maa-skill-init.sh --maa PATH --cli PATH --emu PATH
# 提示：若用户已知 MAA 或 maa-cli 的位置，用 --maa / --cli 直接提供，可省去自动搜索的时间与 token。
set -euo pipefail

FORCE=false
FULL_ACCESS=false
MAA_PATH=""
CLI_PATH=""
EMU_PATH=""
while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=true ;;
        --full-access) FULL_ACCESS=true ;;
        --maa) MAA_PATH="$2"; shift ;;
        --cli) CLI_PATH="$2"; shift ;;
        --emu) EMU_PATH="$2"; shift ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ---------- 1) maa-cli 二进制（确定配置目录也需要它） ----------
CLI_BIN="$CLI_PATH"
if [ -z "$CLI_BIN" ]; then
    for c in maa maa-cli; do
        if command -v "$c" >/dev/null 2>&1; then CLI_BIN="$(command -v "$c")"; break; fi
    done
fi
CLI_VERSION=""
if [ -n "$CLI_BIN" ]; then
    CLI_VERSION="$("$CLI_BIN" version 2>/dev/null | head -n1 || true)"
fi
echo "maa-cli  : ${CLI_BIN:-未找到}  ($CLI_VERSION)"

# ---------- 2) 确定配置目录与配置文件路径 ----------
# 配置存放到 MAA 配置目录（与 profiles/、tasks/ 同级），而非 skill 包目录，
# 这样 skill 更新/分发不会覆盖用户配置。定位优先级：
#   $MAA_CONFIG_DIR > `maa dir config` > 平台默认（Linux: ~/.config/maa，macOS: ~/Library/Application Support/maa）
CONFIG_DIR="${MAA_CONFIG_DIR:-}"
if [ -z "$CONFIG_DIR" ] && [ -n "$CLI_BIN" ]; then
    CONFIG_DIR="$("$CLI_BIN" dir config 2>/dev/null | head -n1 || true)"
fi
if [ -z "$CONFIG_DIR" ]; then
    case "$(uname -s)" in
        Darwin) CONFIG_DIR="$HOME/Library/Application Support/maa" ;;
        *) CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/maa" ;;
    esac
fi
mkdir -p "$CONFIG_DIR"
CONFIG_PATH="$CONFIG_DIR/skill-config.toml"

# ---------- 非首次：读取已有配置 ----------
if [ -f "$CONFIG_PATH" ] && [ "$FORCE" = false ]; then
    echo "=== 读取已有配置: $CONFIG_PATH ==="
    cat "$CONFIG_PATH"
    exit 0
fi

echo "=== MAA skill 初始化：探测环境 ==="
echo "[提示] 如果你知道 MAA 或 maa-cli 的位置（文件夹/二进制路径），"
echo "       请用 --maa / --cli 提供，可省去自动搜索的时间与 token。"

# ---------- 3) MAA（MaaCore.dll / libMaaCore 与 resource/） ----------
MAA_DIR="$MAA_PATH"
if [ -z "$MAA_DIR" ]; then
    # 常见位置：macOS /Applications 或 brew 前缀；Linux ~/.local/share/maa 等
    for d in \
        "$HOME/Applications/MAA" "/Applications/MAA" \
        "/opt/MAA" "$HOME/.local/share/maa" \
        "$HOME/maa" "$HOME/MAA"; do
        if [ -f "$d/MaaCore.dll" ] || [ -f "$d/libMaaCore.so" ] || [ -f "$d/libMaaCore.dylib" ]; then
            MAA_DIR="$d"; break
        fi
    done
fi
MAA_READY=false
if [ -n "$MAA_DIR" ]; then
    if [ -f "$MAA_DIR/MaaCore.dll" ] || [ -f "$MAA_DIR/libMaaCore.so" ] || [ -f "$MAA_DIR/libMaaCore.dylib" ]; then
        MAA_READY=true
    fi
fi
echo "MAA     : ${MAA_DIR:-未找到}  (MaaCore: $MAA_READY)"

# ---------- 4) 模拟器 ----------
EMU_BRAND=""; EMU_INSTALL="$EMU_PATH"; EMU_ADB=""
detect_emu() { # 参数：品牌、目录列表
    local brand="$1"; shift
    for d in "$@"; do
        if [ -n "$d" ] && [ -d "$d" ]; then EMU_BRAND="$brand"; EMU_INSTALL="$d"; return 0; fi
    done
    return 1
}
detect_emu "MuMu" "$HOME/Library/Application Support/MuMu" "/Applications/MuMuPlayer.app" \
    || detect_emu "LDPlayer" "$HOME/.local/share/LDPlayer" "$HOME/LDPlayer9" \
    || detect_emu "BlueStacks" "$HOME/.local/share/BlueStacks" "/opt/BlueStacks" \
    || detect_emu "Waydroid" "/var/lib/waydroid" || true
if [ -n "$EMU_INSTALL" ]; then
    EMU_ADB="$(find "$EMU_INSTALL" -maxdepth 4 -name "adb" -o -name "adb.exe" 2>/dev/null | head -n1)"
fi
echo "模拟器  : ${EMU_BRAND:-未找到} @ ${EMU_INSTALL:-无}"
echo "adb     : ${EMU_ADB:-未找到}"

# ---------- 5) 完整权限 ----------
FULL="false"
if [ "$FULL_ACCESS" = true ]; then FULL="true"; fi
if [ "$FULL" = false ] && [ -f "$CONFIG_PATH" ] && grep -q 'full_access\s*=\s*true' "$CONFIG_PATH"; then
    FULL="true"
fi
echo "Full Access: $FULL"

# ---------- 写入 skill-config.toml ----------
# 先读取旧配置中手动填写的连接地址（端口无法自动探测，避免 --force 重新生成时丢失）
OLD_ADDR=""
if [ -f "$CONFIG_PATH" ]; then
    OLD_ADDR="$(grep -E '^address = "' "$CONFIG_PATH" | head -n1 | sed -E 's/^address = "([^"]*)".*/\1/')"
fi
# 保护开关 modify_skill 原样保留：仅在新建时默认为 false，绝不覆盖已有值（该值只能由用户明确指示更改）
OLD_MODIFY=""
if [ -f "$CONFIG_PATH" ]; then
    OLD_MODIFY="$(grep -E '^modify_skill\s*=\s*(true|false)' "$CONFIG_PATH" | head -n1 | sed -E 's/^modify_skill\s*=\s*(true|false).*/\1/')"
fi
STAMP="$(date '+%Y-%m-%d %H:%M:%S')"
cat > "$CONFIG_PATH" <<EOF
# MAA skill 初始化配置（由 scripts/maa-skill-init.sh 生成/更新）
# 首次初始化时写入；非首次初始化时由技能读取本文件，无需重新探测。
[meta]
created_at = "$STAMP"

[maa]
maa_core_path = "$MAA_DIR"
maa_core_ready = $MAA_READY

[maa_cli]
binary_path = "$CLI_BIN"
version = "$CLI_VERSION"

[emulator]
brand = "$EMU_BRAND"
install_path = "$EMU_INSTALL"
adb_path = "$EMU_ADB"
# 实际连接地址/端口请用 scripts/maa-emulator-detect.sh -Probe 确认后填写，如 "127.0.0.1:5555"
address = ""

[permission]
# 用户是否同意运行真实任务时使用完整权限（Full Access）。
# true 表示用户在初始化时已明确同意；false 时运行真实任务前需向用户确认。
full_access = $FULL
# 技能内容保护：是否允许 harness/agent 更改本 skill 的内容（SKILL.md / README.md / scripts/ / references/ 等）。
# 默认 false；该值只能由用户明确指示更改，harness/agent 不得自行修改（本脚本也只会原样保留）。
modify_skill = false
EOF

# 用旧地址回填（新探测结果中端口为空时）
if [ -n "$OLD_ADDR" ]; then
    sed -i -E "s/^address = \"\"/address = \"$OLD_ADDR\"/" "$CONFIG_PATH"
fi
# 保护开关回填：绝不覆盖已有值
if [ -n "$OLD_MODIFY" ]; then
    sed -i -E "s/^modify_skill = false/modify_skill = $OLD_MODIFY/" "$CONFIG_PATH"
fi
echo "=== 已写入: $CONFIG_PATH ==="
echo "=== 已写入: $CONFIG_PATH ==="
