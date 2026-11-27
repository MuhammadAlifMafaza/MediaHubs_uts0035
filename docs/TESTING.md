# Testing Record

## Local video asset audit (27 November 2026)

| Check | Actual result | Limit |
|---|---|---|
| Physical asset and catalog path | Match | Both resolve to `assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4`; a previous widget assertion expected an obsolete ASCII name and was corrected. |
| Asset declaration | Updated | `pubspec.yaml` now declares the exact MP4 path explicitly. A fresh asset bundle has not been produced. |
| MP4 container markers | Inspected | H.264 AVC configuration reports Main Profile, Level 3.1; AAC `esds` marker exists; `moov` precedes `mdat`. This is a static file inspection, not proof of Android decoder playback. |
| Device playback | Not Run | Flutter build timed out and the Android Gradle wrapper is absent, so there is no fresh APK to test. |

The source path is no longer a mismatch with the current on-disk filename. The remaining runtime check is to rebuild so Flutter packages the explicit asset declaration, install that APK, and capture any actual Android player error if it still fails.

## Cloud CRUD implementation (27 November 2026)

| Check | Actual result | Limit |
|---|---|---|
| `dart pub get` through the SDK on temporary `M:` drive | Pass | Resolved `firebase_auth` 7.1.0 and updated `pubspec.lock`; required approval to write the Pub cache. |
| Dart formatter through the SDK on `M:` | Pass | Formatted the changed Dart source and widget test files. |
| Dart analyzer through the SDK on `M:` | Pass | `dart analyze lib test`: no issues found. |
| `flutter analyze` | Timed out without output | Flutter CLI remained unresponsive; standalone Dart analyzer completed successfully. |
| `flutter test` | Timed out without output after 60 seconds | No test result is claimed for the new CRUD flow. |
| `flutter build apk --debug` | Timed out without output after 30 seconds | No new APK was produced by this command. |
| Android Gradle debug build | Blocked | `android/gradlew.bat` is absent and no system `gradle` executable is installed; Flutter CLI build remains unverified. No new APK was produced. |
| Firebase CRUD and rules | Not run | Enable Anonymous sign-in and review/apply `docs/firestore.rules.example` in Firebase Console first. |

The source now contains Anonymous Auth, a per-UID Firestore repository, realtime cloud-list states, and create/edit/delete UI. These changes have not been verified against the live Firebase project or an Android device. The one-off network-audio form and bundled-media Library are also not device-verified.

## Environment

- Flutter 3.47.7, Dart 3.13.5
- Android SDK 36.0.0, Java 21
- SM A226B, Android 13 (API 33), device ID `R9CT4004VJE` connected on 14 November 2026.
- Current `flutter doctor -v`: Android toolchain healthy; Android device not connected in this phase. Windows Visual Studio unavailable (irrelevant to Android-only build). `flutter --version`: Flutter 3.47.7 / Dart 3.13.5.

## Automated checks

### Release split build and connected-device run (15 November 2026, late night)

| Check | Actual result | Limit |
|---|---|---|
| `adb devices -l` | SM A226B `R9CT4004VJE` detected | ADB connection works; this is not an app launch. |
| `flutter --version` | Timed out without output | Flutter CLI still unresponsive after the prior process cleanup. |
| `flutter build apk --release --split-per-abi` | Timed out without output | No release APK was generated under `build/app/outputs/`. |
| `flutter run --release -d R9CT4004VJE --no-resident` | Timed out without output | Did not install/launch the new project build. An existing older package was already installed on the device, but no app process was observed in the `pidof` check; do not treat it as this revision. |
| `./gradlew.bat :app:assembleRelease "-Psplit-per-abi=true" --max-workers=1 --no-daemon --quiet` | Timed out | Thread dump showed `BaseFlutterTaskHelper.buildBundle` waiting for a Flutter subprocess; no release APK was generated. |

Only older debug APKs (17:59) exist; none incorporates the current device-media and Unicode video-path changes. Release signing in `android/app/build.gradle.kts` currently uses the debug signing config. No video/audio runtime success is claimed. The attempted Gradle build updated the tracked generated report at `android/build/reports/problems/problems-report.html`; no source code was changed during this release test.

### Device media and video asset path (15 November 2026, night)

| Check | Result | Detail |
|---|---|---|
| Git state at start | Clean | Original Unicode MP4 existed; catalogue incorrectly referenced a missing ASCII path. |
| `photo_manager` dependency | Resolved | 3.12.0 installed in Pub cache, `pubspec.lock` and `.dart_tool/package_config.json`; `dart pub get` timed out before returning a success exit code. |
| Standalone Dart formatter and analyzer | Pass | 22 Dart files analyzed; 0 diagnostics after changes, formatter applied. CLI `dart format` itself timed out. |
| `flutter test` via temporary `subst M:` | Timeout | No new test pass for this phase. Earlier 8/8 result is historical. |
| Gradle `:app:assembleDebug -Psplit-per-abi=true --max-workers=1 --no-daemon --quiet` | Timeout | Java thread dump showed Gradle waiting in `BaseFlutterTaskHelper.buildBundle` for the Flutter process; three APK timestamps remain 17:59 (previous revision). |
| `flutter --version` / `flutter devices` | Timeout | Flutter CLI unresponsive in this phase. `adb devices -l` independently detected SM A226B (`R9CT4004VJE`). Even after the user authorized stopping all Dart/Flutter processes and they were stopped, Flutter CLI still timed out. |
| `flutter run -d R9CT4004VJE --debug --no-resident` | Timeout | User explicitly authorized running the project in this phase, but Flutter returned no output before timeout. No new APK was installed/launched by this command. |
| New APK install / video and device audio playback | Not Run | No freshly built APK exists for these code changes. Do not treat previous APKs as proof of video/MediaStore playback. |

Firebase Console Data/Rules/Storage and permission for no-login cloud access have not been verified. Cloud repository and remote writes remain gated; no URL to an actual Storage audio file has been supplied.

### Build repair (15 November 2026, evening; no app run)

| Check | Result | Detail |
|---|---|---|
| `flutter pub get` | Pass | Dependencies resolved after `flutter clean`. |
| `dart format lib test` | Pass | Formatted the updated test and one library file; final format check later timed out under system load. |
| `flutter analyze` | Pass | No issues found. |
| `flutter test` (temporary `subst M:` drive) | Pass | 8/8 tests after updating two UI assertions; `M:` avoids the apostrophe in the project path. |
| `flutter build apk --debug --split-per-abi` | Fail | Kotlin incremental cache cannot relativize Pub cache paths on `C:` against project paths on `D:`. After applying build settings, a retry timed out without output; APK timestamps did not change. |
| Gradle `:app:assembleDebug -Pkotlin.incremental=false -Psplit-per-abi=true` | Pass on third attempt | First retry crashed with 8 GB heap; second crashed signing APK with 2 GB heap due to insufficient system commit. Third run with 1200 MB heap, 512 MB metaspace, one worker, and ForkJoinPool parallelism 1 exited successfully and produced all three APKs on 15 November at 17:59. The successful flags are now in `android/gradle.properties`, except `-Psplit-per-abi=true`. |
| Android install/launch/playback | Not Run | Explicitly out of scope. APK build does not prove video or network playback. |

APK outputs in `build/app/outputs/flutter-apk/`: `app-arm64-v8a-debug.apk` (158,258,657 bytes), `app-armeabi-v7a-debug.apk` (137,293,903 bytes), `app-x86_64-debug.apk` (144,276,012 bytes). The Gradle invocation was from `android/`: `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" "-Psplit-per-abi=true" "-Dorg.gradle.jvmargs=-Xmx1200m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=192m -Djava.util.concurrent.ForkJoinPool.common.parallelism=1" --max-workers=1 --no-daemon --quiet`.

### Current changes (15 November 2026; build only, no app run)

| Check | Result | Detail |
|---|---|---|
| Existing source/assets | Inspected | User reports bundled video displays “Video unavailable”; old player hid the original exception. MP4 existed in release APK and file signatures contain `avc1` and `mp4a`. Neither observation proves device compatibility. |
| Asset path | Changed, unverified | Tracked MP4 moved to `assets/video/rude_mv.mp4`, catalogue updated; new APK not produced yet. |
| `dart format lib test` | Timeout | No output/completion; repeated single-file and mapped-drive attempts also timed out. Alternative standalone formatter succeeded (next row). |
| Standalone `dart_style` formatter via SDK `dart.exe` | Pass | Formatted 7 files; subsequent run: 0 changes. Used SDK package config because the normal `dart format` command remains blocked. |
| Standalone analyzer via SDK `dart.exe` | Pass | Resolved 20 Dart source/test files, 0 diagnostics after fixing an unused import. This is not a substitute for a successful `flutter analyze` invocation. |
| `flutter --version` | Timeout | No output during this attempt; Flutter CLI appears blocked by the environment. |
| Gradle `:app:assembleDebug -Pkotlin.incremental=false -Psplit-per-abi=true` | Timeout | No new APK after 300s; do not mark build as passed. |
| `flutter analyze`, `flutter test` | Not Run | Flutter CLI remained unresponsive; previous 7/7 is historical. |
| Android install/launch/playback | Not Run | Explicit instruction: build only; no app run. Video offline and YouTube remain unverified. |


### Latest release-device check (14 November 2026)

| Check | Outcome | Evidence / limit |
|---|---|---|
| Git worktree | Clean before run | No source files changed for this check. |
| Debug build output | Not present | No debug APK under current `build/app/outputs/`; do not infer the debug build passed. |
| Existing release APK | Present | `build/app/outputs/flutter-apk/app-release.apk` (130,305,341 bytes), timestamp after source modifications; ZIP contains `lib/arm64-v8a/libapp.so`, both logos and profile JPEG. This session did not rebuild it. |
| `flutter --version`, `flutter run --release -d R9CT4004VJE --no-resident` | Timeout | Flutter CLI produced no output and did not complete. Its timed-out child process was stopped; no Flutter CLI run success is claimed. |
| `adb install -r` of existing release APK | Pass | Android returned `Success`. |
| `adb shell am start` | Pass (basic launch) | `MainActivity` started; `pidof` returned process ID and activity was `topResumedActivity`. |
| Release UI inspection | Pass (Library only) | Screenshot in approved local temp directory showed Library with Cloud Library, YouTube entry and Profile navigation; no visible Flutter error. |
| Home, Profile, player, splash, Firestore | Not Run | Device switched to another app during further inspection; interaction stopped. |

No new `flutter test`, `flutter analyze` or release build completed in this check. The existing APK is signed via the project's debug signing config, despite being built in release mode.

### Earlier failed run attempt (14 November 2026)

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
