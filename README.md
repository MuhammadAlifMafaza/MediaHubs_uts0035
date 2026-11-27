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

The app has Home, Audio, Video, Library and Profile navigation; Search is available from the Home/Audio/Video app bars. Tap a media item to open its player directly; the more-options menu opens Details. Audio/Video include bundled assets and automatically scanned device media when Android read permission is granted. Audio also accepts a direct HTTPS audio URL for immediate playback. The Video tab offers a dedicated YouTube player initially set to `https://youtu.be/chl0R8C4NJ8`. Library lists bundled media and provides a per-user Firestore CRUD flow after Anonymous Authentication and Rules are enabled in Firebase Console. The bundled MP4 is `assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4`. The asset path in `pubspec.yaml`, media catalog, and test now uses the same Unicode filename. **Android playback has not yet been verified on a rebuilt APK.** See `LICENSES.md` for the asset rights register before redistribution.

Device media scanning uses `photo_manager` 3.12.0 and Android read permissions only (`READ_MEDIA_AUDIO`, `READ_MEDIA_VIDEO`, and API-specific legacy/limited permissions); it does not copy, delete, or upload the original device files. Android permission is requested when the Audio or Video tab is opened. Search currently covers bundled items only. Firebase Storage audio is deferred pending approved read rules, Firestore schema, and a real authorized audio file; no stream URL is invented.

## Firebase setup gate

`android/app/google-services.json` exists and its project ID/package match `mediahubs-bbf06` / `com.mediahubs.uts0035`; the Google Services Gradle plugin and `Firebase.initializeApp()` are present. This does **not** verify cloud database access. The app uses invisible Anonymous Authentication and stores metadata under `users/{uid}/media/{mediaId}`. Enable Anonymous sign-in and review/apply the example in `docs/firestore.rules.example` in Firebase Console before cloud CRUD can succeed. The app does not upload audio or video files.

## UTS demo checklist

- [ ] Enable Anonymous Authentication and apply reviewed per-user rules from `docs/firestore.rules.example` before Firestore CRUD.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Confirm rights for the supplied MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.
- [ ] Validate YouTube playback, external Profile links, splash and new menu screens on Android after permission to run the app is granted.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.

Validation results and remaining device tests are recorded in `docs/TESTING.md`.

The Indonesian project report is available as [PDF](docs/Dokumentasi_Proyek_MediaHub.pdf), with its editable HTML source at [docs/Dokumentasi_Proyek_MediaHub.html](docs/Dokumentasi_Proyek_MediaHub.html). Third-party and bundled asset rights are tracked separately in [LICENSES.md](LICENSES.md).
