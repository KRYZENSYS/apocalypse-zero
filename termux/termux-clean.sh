#!/data/data/com.termux/files/usr/bin/bash
# Build natijalari va keshni tozalaydi (kod va assetlarga tegmaydi).
cd "$(dirname "$0")/.." || exit 1
rm -rf build/apk .godot
echo "Tozalandi: build/apk, .godot"
