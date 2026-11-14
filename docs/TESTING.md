# Testing Record

## Environment

- Flutter 3.47.7, Dart 3.13.5
- Android SDK 36.0.0, Java 21
- SM A226B, Android 13 (API 33), device ID `R9CT4004VJE` connected on 14 November 2026.
- Current `flutter doctor -v`: Android toolchain healthy; Android device not connected in this phase. Windows Visual Studio unavailable (irrelevant to Android-only build). `flutter --version`: Flutter 3.47.7 / Dart 3.13.5.

## Automated checks

### Latest run attempt (14 November 2026)

- `pubspec.yaml` currently says `sdk: flutter`; previous `flutter+` error is not present in the inspected file.
- `flutter run --release -d R9CT4004VJE --no-resident`: **Fail before install**, Kotlin incremental cache error due to `C:` Pub cache vs `D:` project.
- Release Gradle retry with `-Pkotlin.incremental=false`: **Fail**, Java daemon crashed from insufficient native memory (`android/hs_err_pid21228.log`, `-Xmx8G`). Retry with 2 GB heap / 2 workers: same insufficient-memory crash (`android/hs_err_pid22236.log`). The later `-Pshrink=false` retry was interrupted, so it has no result.
- `flutter test` through `subst M:`: **Timeout after 180 seconds with no test output**. Subsequent `flutter devices` and `flutter --version` also timed out; `adb devices -l` still detected SM A226B. No new test result should be inferred from the previous 7/7 run.
- Both logo PNGs briefly appeared deleted during inspection, then reappeared in the working tree without being restored by this agent. No APK was installed or launched in this attempt.

### Current implementation (14 November 2026; no device run)

- `flutter pub get`: Pass, including `font_awesome_flutter` 11.0.0 and `url_launcher` 6.3.x; `youtube_player_flutter` 10.0.1 was already present.
- `dart format lib test` followed by `dart format --output=none --set-exit-if-changed lib test`: Pass; 0 changes in the final check.
- `flutter analyze`: Pass, no issues after code changes.
- `flutter test` through temporary `subst M:` path (apostrophe workaround): Pass, 7/7 tests (Home, Library, Profile, Cloud gate, invalid YouTube URL, URL parsing cases).
- `flutter build apk --debug --split-per-abi` with environment attempt to disable incremental Kotlin: Fail, cross-drive Kotlin incremental cache errors.
- `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" "-Psplit-per-abi=true" --no-daemon --quiet` from `android/`: Pass after the Profile brand icon change. Three APKs under `build/app/outputs/flutter-apk/`: `app-arm64-v8a-debug.apk`, `app-armeabi-v7a-debug.apk`, `app-x86_64-debug.apk`. APK contents inspection confirmed arm64 native library, profile JPEG, logo assets and launcher PNGs in the arm64 APK.
- **No app installation, launch, screenshots or device media tests were performed in this phase**, per user instruction. Build success alone is not a runtime pass.

### Previous device-validation session (historical; not the current build)

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
