#!/data/data/com.termux/files/usr/bin/bash
# Termux: faqat ISHLAB CHIQISH uchun. O'yin APK'ga Termux kerak emas.
set -u
echo "== Project Apocalypse Zero: Termux sozlash =="
if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
  echo "[XATO] Bu skript Termux ichida ishga tushirilishi kerak."; exit 1
fi
pkg update -y && pkg upgrade -y
pkg install -y git wget unzip zip openjdk-17 || { echo "[XATO] Asosiy paketlar o'rnatilmadi."; exit 1; }

echo "-- Godot paketini qidirish (mavjud bo'lmasligi mumkin) --"
if pkg install -y godot 2>/dev/null; then
  echo "[OK] 'godot' paketi o'rnatildi."
else
  echo "[OGOHLANTIRISH] Termux'da 'godot' paketi topilmadi yoki o'rnatilmadi."
  echo "  Muqobil yo'llar uchun docs/ANDROID_BUILD.md ni o'qing."
fi
echo "Keyingi qadam: bash termux/termux-check.sh"
