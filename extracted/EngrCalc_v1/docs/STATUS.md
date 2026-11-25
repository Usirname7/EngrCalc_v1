# Build and recovery status

The original Flutter application logic was compiled into `libapp.so`; the recovered materials do not include original editable Dart source, pubspec, or lockfile. This is a new implementation, not guaranteed feature parity.

Current implemented code: fraction-aware arithmetic, length conversion, concrete volume, board feet, cylinder volume, Ohm's law, electrical power, slope percentage, and a local material-data loader.

Recovered local data is bundled where located: material weights, AISC beam table archive, HSS A1085 table, and display overrides. The actual JSON schemas still need to be inspected and mapped into dedicated searchable screens.

Privacy baseline: no INTERNET, AD_ID, billing, camera, microphone, SMS, or external-storage permissions; no ad/analytics SDK dependencies.

Still required for a production release: complete the remaining calculators and searchable reference UI; validate formulas/data licensing; run Flutter analyzer and tests; generate Android Gradle wrapper/platform files using `flutter create`; test on real devices; sign release APK. This runtime has no Flutter executable, so it cannot produce a compiled APK here.

Build on a machine with Flutter stable + Android SDK:
`flutter create --platforms=android .`
`flutter pub get`
`flutter analyze`
`flutter test`
`flutter build apk --release`

Expected APK: `build/app/outputs/flutter-apk/app-release.apk`.
