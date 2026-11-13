# Testing Record

## Environment

- Flutter 3.47.7, Dart 3.13.5
- Android SDK 36.0.0, Java 21
- SM A226B, Android 13 (API 33), device ID `R9CT4004VJE` connected on 14 November 2026.

## Automated checks

On 14 November 2026, after explicit user request:

- `flutter pub get`: Pass.
- `dart format --output=none --set-exit-if-changed lib test`: Pass (after formatting test source).
- `flutter analyze`: Pass, no issues.
- `flutter test`: Pass, 2/2 widget tests. Run through temporary `subst M:` drive mapping because the apostrophe in `D:\Project K'\...` breaks Flutter's generated test listener.
- `flutter build apk --debug`: Fail, Kotlin incremental cache errors because Pub cache is on `C:` and project is on `D:`.
- `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" --no-daemon --quiet` from `android/`: Pass. APK: `build/app/outputs/flutter-apk/app-debug.apk` (project root).
- `adb install -r` and `am start` on SM A226B: Pass; `pidof` and resumed Activity confirmed. Screenshot showed the Library. A later device screenshot showed asset audio “The Chase” with progress `0:07 / 2:58` and Pause control. No listening/audio-output measurement was recorded.
- Network audio, video playback and Firestore have **not** been validated; do not extrapolate from the APK build.

## PRD black-box cases

| ID | Outcome | Notes |
|---|---|---|
| TC-01 | Not Run (full case) | APK installed and app displayed Library on SM A226B; Home screen was not independently checked. Basic app launch succeeded. |
| TC-02 | Blocked | Firestore data/schema/security not verified. |
| TC-03 | Blocked | CRUD withheld pending Firebase security/schema approval. |
| TC-04 | Not Run | Required-title validation is implemented in the gated form; not tested. |
| TC-05 | Blocked | CRUD withheld pending Firebase security/schema approval. |
| TC-06 | Blocked | Delete confirmation UI not implemented. |
| TC-07 | Blocked | CRUD withheld pending Firebase security/schema approval. |
| TC-08 | Not Run | Direct HTTPS network-audio player is implemented; playback has not been tested. |
| TC-09 | Not Run | Network URL validation and playback error UI are implemented; not tested. |
| TC-10 | Not Run | One existing MP4 is referenced by the catalogue; device playback not observed. Redistribution rights unverified. |
| TC-11 | Blocked | Firestore connectivity/error state not implemented. |
| TC-12 | Not Run | Existing video asset has not been tested offline. |

Other observations: bundled asset audio was displayed playing on-device, but TC-08 is specifically **network** audio and remains Not Run. Screenshot evidence was inspected in the approved local temporary directory; no screenshot was fabricated or added to the repository.
