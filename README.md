# My Path to Fajr - طريقي للفجر

Offline-first Flutter app: Fajr tracker, motivational reminders, alarms. Arabic (default, RTL) / English / French.

## Architecture
- `lib/core` - theme, constants (`fajr_quotes.dart`), security (AES-encrypted Hive + sanitizer)
- `lib/domain` - models
- `lib/services` - notification scheduler, alarm service
- `lib/presentation` - Riverpod providers, screens, widgets
- `lib/l10n` - ar/en/fr strings

## Setup
```bash
cd my_path_to_fajr
flutter create --org com.mypathtofajr --project-name my_path_to_fajr .
cp _platform_overrides/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
cp _platform_overrides/proguard-rules.pro android/app/proguard-rules.pro
# merge _platform_overrides/build.gradle.snippet.md into android/app/build.gradle
# add the audio files and icon (see below)
flutter pub get
dart run flutter_launcher_icons
flutter run
```

## Audio files (required)
Put three MP3 files (names must match) in BOTH folders:
- `assets/audio/fajr_adhan.mp3`, `makkah_adhan.mp3`, `madinah_adhan.mp3`  (used by alarms + preview)
- `android/app/src/main/res/raw/fajr_adhan.mp3` (notification sound; lowercase, no spaces)

## Icon
`assets/icon/app_icon.png` (1024x1024) then `dart run flutter_launcher_icons`.

## Secure release build
```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```
Keep `build/symbols` private (needed to de-obfuscate crash traces).

Signing: create `android/key.properties` (storePassword, keyPassword, keyAlias, storeFile) and never commit it.

## Notes
- Quotes: `fajr_quotes.dart` ships with 60 authentic entries (Quran / Sahih Hadith / motivational). The scheduler cycles through the list; append more entries to extend it.
- Repeating alarms are one-shot under the hood and re-armed on app launch / after ringing.
- Verify `alarm: ^4.1.1` API if you upgrade major versions.
