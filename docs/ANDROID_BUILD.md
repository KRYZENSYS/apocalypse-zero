# Android APK yig'ish

Termux — faqat ishlab chiqish uchun. APK o'rnatilgach Termuxsiz ishlaydi.

## Muhim ogohlantirish
Godot 4 Android export uchun kerak: Godot muharriri/CLI, **export shablonlari**, JDK 17, **Android SDK** (build-tools, platform-tools) va debug keystore. Telefon/Termux (ARM) da bularning hammasini yig'ish ko'pincha **ishlamaydi** (Android SDK vositalari odatda x86 Linux uchun). Buni `termux/termux-check.sh` bilan tekshiring; natijasiga ishoning.

## Muqobil yo'llar
1. **Kompyuterda** Godot 4.3+ bilan: Project > Export > Android > Export Project (debug).
2. **GitHub Actions** (Godot CI konteyneri bilan) — kod Termuxda yoziladi, APK bulutda yig'iladi.
3. Termux'da faqat kod yozib, `git push` qilish.

## Imzolash
Debug keystore Godot Editor Settings (Export > Android) orqali sozlanadi. Release keystore va parollarni **hech qachon** repoga qo'shmang.
