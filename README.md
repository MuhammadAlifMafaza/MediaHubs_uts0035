# MediaHub

Android-first Flutter multimedia library prototype for the UTS project.

## Requirements

- Flutter 3.47.7 / Dart 3.13.5 (or compatible)
- Android SDK and an Android emulator or device
- For Firestore features: Firebase Console access to verify Firestore, Authentication, rules, and the approved collection structure
- For offline video playback: confirm redistribution rights for the existing MP4 under `assets/video/` before submitting the project

## Setup and run

```sh
flutter pub get
flutter run -d <android-device-id>
```

Build per-ABI debug APKs with `flutter build apk --debug --split-per-abi` when the CLI is responsive. On this Windows setup, the original Flutter invocation failed in the Kotlin incremental cache across `C:` and `D:` drives; a later retry timed out. Verified workaround from `android/`: `./gradlew.bat :app:assembleDebug "-Psplit-per-abi=true" --max-workers=1 --no-daemon --quiet`. The required non-incremental Kotlin, low-memory JVM and one-worker settings are recorded in `android/gradle.properties`. The successful build used the same settings explicitly on its command line; see `docs/TESTING.md`. Outputs from project root: `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, `app-armeabi-v7a-debug.apk`, and `app-x86_64-debug.apk`. The app ID is `com.mediahubs.uts0035`.

## Current demo

The app has Home, Audio, Video, Library and Profile navigation; Search is available from the Home/Audio/Video app bars. Tap a media item to open its player directly; the `⋯` menu opens Details. Audio/Video include bundled assets and automatically scanned device media when Android read permission is granted. The Video tab also offers a dedicated YouTube player initially set to `https://youtu.be/chl0R8C4NJ8`. Library retains the Firestore setup gate and disabled Add/Edit form. The bundled MP4 has its original Unicode filename again: `assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4`; the catalogue now matches it. The manual network audio URL form was removed; online audio playback support remains in the player but no cloud catalogue is connected yet. **The existing APKs predate the current device-scan and video-path changes; a new APK and device playback are not verified yet.** Confirm media redistribution rights before sharing an APK.

Device media scanning uses `photo_manager` 3.12.0 and Android read permissions only (`READ_MEDIA_AUDIO`, `READ_MEDIA_VIDEO`, and API-specific legacy/limited permissions); it does not copy, delete, or upload the original device files. Android permission is requested when the Audio or Video tab is opened. Search currently covers bundled items only. Firebase Storage audio is deferred pending approved read rules, Firestore schema, and a real authorized audio file; no stream URL is invented.

## Firebase setup gate

`android/app/google-services.json` exists and its project ID/package match `mediahubs-bbf06` / `com.mediahubs.uts0035`; the Google Services Gradle plugin and `Firebase.initializeApp()` are present. This does **not** verify cloud database or Storage access. No login is planned. In Firebase Console, verify Firestore **Data/Rules** and Storage **files/rules**, then approve what can be read without login and how app-submitted changes are reviewed. Public client writes cannot safely distinguish a trusted editor without an authorization mechanism. No unrestricted rules, remote writes, or Firebase Storage access have been implemented.

## UTS demo checklist

- [ ] Verify Firebase and safely enable Firestore CRUD.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Confirm rights for the supplied MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.
- [ ] Validate YouTube playback, external Profile links, splash and new menu screens on Android after permission to run the app is granted.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.

Validation results and remaining device tests are recorded in `docs/TESTING.md`.
