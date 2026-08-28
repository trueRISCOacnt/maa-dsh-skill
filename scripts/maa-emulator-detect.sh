#!/usr/bin/env bash
# maa-emulator-detect.sh - Detect installed emulators / Android environments for MAA / maa-cli.
# Emulator brands follow MAA official docs (docs.maa.plus/manual/connection + device/linux + device/macos):
#   Linux:  AVD (Android Studio), Waydroid, redroid (5555), Genymotion (partial)
#   macOS:  PlayCover (MaaTools, no adb), MuMu Pro, BlueStacks air (5555), Nox, AVD
# POSIX bash; ASCII output.
#
# Usage:
#   bash maa-emulator-detect.sh                          # auto detect
#   bash maa-emulator-detect.sh -p /path/to/emulator     # manual: locate by install dir
#   bash maa-emulator-detect.sh -a /path/to/adb -A 127.0.0.1:5555   # manual: explicit adb + address
#
# Exit code: 0 = something found; 1 = nothing found.

ADB_BIN=""
ADDR=""
MANUAL_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -p|--path) MANUAL_DIR="$2"; shift 2 ;;
    -a|--adb) ADB_BIN="$2"; shift 2 ;;
    -A|--address) ADDR="$2"; shift 2 ;;
    *) echo "ERROR: unknown option: $1"; exit 2 ;;
  esac
done

find_adb_in() { # $1=dir, $2..=names
  local dir="$1"; shift
  for n in "$@"; do
    local p="$dir/$n"
    [ -x "$p" ] && { echo "$p"; return 0; }
  done
  # shallow search
  local hit
  hit="$(find "$dir" -maxdepth 3 -type f \( -name adb -o -name adb.exe -o -name nox_adb \) -perm -u+x 2>/dev/null | head -n1)"
  [ -n "$hit" ] && { echo "$hit"; return 0; }
  return 1
}

print_profile() { # $1=adb path, $2=address (may be empty)
  echo ""
  echo "Suggested profile (profiles/default.toml):"
  echo "[connection]"
  [ -n "$1" ] && echo "adb_path = \"$1\""
  [ -n "$2" ] && echo "address = \"$2\""
  echo "config = \"General\""
}

# ---------- manual mode ----------
if [ -n "$ADB_BIN" ]; then
  [ -x "$ADB_BIN" ] || { echo "ERROR: adb not found or not executable: $ADB_BIN"; exit 1; }
  echo "[manual] adb: $ADB_BIN"
  [ -n "$ADDR" ] && echo "[manual] address: $ADDR"
  print_profile "$ADB_BIN" "$ADDR"
  exit 0
fi

if [ -n "$MANUAL_DIR" ]; then
  [ -d "$MANUAL_DIR" ] || { echo "ERROR: directory not found: $MANUAL_DIR"; exit 1; }
  local_adb="$(find_adb_in "$MANUAL_DIR" adb adb.exe nox_adb HD-Adb)"
  if [ -z "$local_adb" ]; then
    echo "ERROR: no adb found under $MANUAL_DIR"
    echo "Hint: emulator adb names per MAA docs: adb / adb.exe / nox_adb / HD-Adb"
    exit 1
  fi
  echo "[manual] install dir: $MANUAL_DIR"
  echo "[manual] adb: $local_adb"
  [ -n "$ADDR" ] && echo "[manual] address: $ADDR"
  print_profile "$local_adb" "$ADDR"
  exit 0
fi

# ---------- auto detect ----------
echo "=== Emulator Detection (MAA official: AVD / Waydroid / redroid / PlayCover / MuMu Pro / BlueStacks / Nox) ==="
found=0

OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
  # --- macOS ---
  for app in \
    "/Applications/PlayCover.app" \
    "/Applications/MuMuPlayerPro.app" \
    "/Applications/BlueStacks.app" \
    "/Applications/NoxAppPlayer.app"; do
    if [ -d "$app" ]; then
      found=1
      echo ""
      echo "Brand: $(basename "$app" .app)"
      case "$app" in
        *PlayCover*)
          echo "    MaaTools (no adb). Enable MaaTools in PlayCover per-game settings;"
          echo "    connection address = the [localhost:PORT] shown in the game window title."
          echo "    touch_mode = MacPlayTools"
          ;;
        *Nox*)
          nox_adb="/Applications/NoxAppPlayer.app/Contents/MacOS/adb"
          echo "    adb: $nox_adb"
          [ -x "$nox_adb" ] && { echo "    run 'adb devices' in the MacOS dir to get the port."; print_profile "$nox_adb" ""; }
          ;;
        *BlueStacks*)
          echo "    enable 'Android debugging (ADB)' in emulator settings; port 127.0.0.1:5555"
          print_profile "" "127.0.0.1:5555"
          ;;
        *MuMu*)
          echo "    use a touch mode other than MacPlayTools (see MAA docs); check its ADB port."
          ;;
      esac
    fi
  done
else
  # --- Linux ---
  if command -v waydroid >/dev/null 2>&1; then
    found=1
    echo ""
    echo "Brand: Waydroid"
    ws="$(waydroid status 2>/dev/null | tr -d ' ' | grep -i 'Session:' || true)"
    echo "    status: ${ws:-unknown}"
    echo "    get the emulator IP from Waydroid settings -> About -> IP address, then use <IP>:5555"
    print_profile "" ""
  fi
  if command -v redroid >/dev/null 2>&1 || docker ps 2>/dev/null | grep -qi redroid; then
    found=1
    echo ""
    echo "Brand: redroid (container)"
    echo "    ADB port 5555 (must be exposed); touch mode may need adjustment."
    print_profile "" "127.0.0.1:5555"
  fi
  if pgrep -f "qemu-system.*avd|emulator.*-avd" >/dev/null 2>&1; then
    found=1
    echo ""
    echo "Brand: AVD (running)"
    echo "    address: emulator-5554 (check 'adb devices')"
  fi
fi

# --- Android SDK / AVD ---
SDK=""
for cand in "$ANDROID_HOME" "$HOME/Android/Sdk" "$HOME/Library/Android/sdk"; do
  [ -n "$cand" ] && [ -d "$cand" ] && SDK="$cand" && break
done
if [ -n "$SDK" ]; then
  emu_dir="$SDK/emulator"
  adb_plat="$SDK/platform-tools/adb"
  if [ -x "$adb_plat" ]; then
    found=1
    echo ""
    echo "Brand: Android SDK / AVD"
    echo "    adb: $adb_plat"
    if [ -x "$emu_dir/emulator" ]; then
      avds="$("$emu_dir/emulator" -list-avds 2>/dev/null)"
      echo "    AVDs: ${avds:-none}"
    fi
    print_profile "$adb_plat" "emulator-5554"
  fi
fi

# --- generic adb devices ---
GADB="$(command -v adb 2>/dev/null)"
if [ -n "$GADB" ]; then
  devs="$("$GADB" devices 2>/dev/null | sed -n '2,$p' | grep -v '^$' || true)"
  if [ -n "$devs" ]; then
    found=1
    echo ""
    echo "Brand: adb devices (generic)"
    echo "    adb: $GADB"
    echo "$devs" | while read -r line; do echo "    device: $line"; done
    first="$(echo "$devs" | head -n1 | awk '{print $1}')"
    print_profile "$GADB" "$first"
  fi
fi

if [ "$found" -eq 0 ]; then
  echo "No emulator detected."
  echo "Hint: run with -p <emulator install dir> or -a <adb path> to locate manually."
  exit 1
fi
echo ""
echo "Notes:"
echo "  - AVD: use 16:9 resolution > 720p; Android 10+ may need non-Minitouch touch mode."
echo "  - Waydroid: set resolution 1280x720+; check amdgpu screencap issue in MAA docs."
exit 0
