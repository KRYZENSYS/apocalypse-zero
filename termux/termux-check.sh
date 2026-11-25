#!/data/data/com.termux/files/usr/bin/bash
# Android APK yig'ish imkoniyatini tekshiradi. Hech narsani o'zgartirmaydi.
ok=1
chk() { if command -v "$1" >/dev/null 2>&1; then echo "[OK]   $1: $(command -v "$1")"; else echo "[YO'Q] $1 — $2"; ok=0; fi; }
echo "Arxitektura: $(uname -m)"
chk java "pkg install openjdk-17"
chk godot "Termux'da mavjud bo'lmasligi mumkin"
chk git "pkg install git"
if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then echo "[OK]   ANDROID_HOME=$ANDROID_HOME"; else echo "[YO'Q] ANDROID_HOME (Android SDK) sozlanmagan"; ok=0; fi
if ls "$HOME"/.local/share/godot/export_templates/*/android_debug.apk >/dev/null 2>&1 \
   || ls "$HOME"/.local/share/godot/export_templates/*/android_source.zip >/dev/null 2>&1; then
  echo "[OK]   Godot export shablonlari topildi"
else
  echo "[YO'Q] Godot Android export shablonlari topilmadi"; ok=0
fi
[ -f "$(dirname "$0")/../export_presets.cfg" ] && echo "[OK]   export_presets.cfg bor" || { echo "[YO'Q] export_presets.cfg"; ok=0; }
echo
if [ "$ok" = 1 ]; then echo "Natija: APK yig'ishga urinish mumkin (kafolat yo'q)."; else echo "Natija: Termux'da APK yig'ish HOZIR MUMKIN EMAS. docs/ANDROID_BUILD.md dagi muqobil yo'lni ishlating."; fi
