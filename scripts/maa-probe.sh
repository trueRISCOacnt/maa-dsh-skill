#!/usr/bin/env bash
# maa-probe.sh — 探测 maa-cli / MaaCore 安装状态（Linux / macOS，POSIX bash）
# 用法: bash maa-probe.sh
# 退出码: 0 = 找到可用的 maa 二进制; 1 = 未找到
set -u

# 1) 定位二进制（winget 安装的是 maa-cli，其余通常是 maa）
bin=""
for name in maa maa-cli; do
  if command -v "$name" >/dev/null 2>&1; then
    bin="$(command -v "$name")"
    break
  fi
done

if [ -z "$bin" ]; then
  echo "[probe] maa-cli 未安装。安装方式见 SKILL.md 第 3 节："
  echo "  macOS:   brew install MaaAssistantArknights/tap/maa-cli"
  echo "  Linux:   yay -S maa-cli  或  nix run nixpkgs#maa-cli"
  echo "  或安装脚本: curl -fsSL https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/main/install.sh | bash"
  exit 1
fi

exe="$(basename "$bin")"
echo "[probe] 二进制: $bin"

# 2) 版本（MaaCore 未安装时会报错）
echo "--- version ---"
"$exe" version 2>&1 | sed 's/^/  /'
if [ "${PIPESTATUS[0]}" -ne 0 ]; then
  echo "[probe] 提示: MaaCore 可能未安装，请先运行: $exe install"
fi

# 3) 目录
echo "--- directories ---"
for d in config log data; do
  out="$("$exe" dir "$d" 2>/dev/null)" && echo "  $d -> $out"
done

# 4) 可用任务列表
echo "--- tasks (maa list) ---"
"$exe" list 2>&1 | sed 's/^/  /'

# 5) 相关环境变量
echo "--- env ---"
for v in MAA_CONFIG_DIR MAA_LOG MAA_LOG_PREFIX; do
  val="$(printenv "$v" 2>/dev/null)" && [ -n "$val" ] && echo "  $v=$val"
done

echo "[probe] 完成。常见问题见 SKILL.md 第 9 节。"
exit 0
