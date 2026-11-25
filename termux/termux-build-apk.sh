#!/data/data/com.termux/files/usr/bin/bash
# Debug APK yig'ishga urinadi. Avval termux-check.sh o'tishi kerak.
set -u
cd "$(dirname "$0")/.." || exit 1
bash termux/termux-check.sh | grep -q "urinish mumkin" || { echo "[TO'XTADI] Tekshiruv o'tmadi. docs/ANDROID_BUILD.md ni o'qing."; exit 1; }
mkdir -p build/apk
godot --headless --path . --export-debug "Android" build/apk/apocalypse_zero_debug.apk
rc=$?
if [ $rc -eq 0 ] && [ -f build/apk/apocalypse_zero_debug.apk ]; then
  echo "[OK] APK: build/apk/apocalypse_zero_debug.apk"
else
  echo "[XATO] Export muvaffaqiyatsiz (kod $rc). APK yaratilmadi."; exit 1
fi
