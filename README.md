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

The app has Home, Audio, Video, Library and Profile navigation; Search is available from the Home/Audio/Video app bars. Home also opens a separate classroom CRUD screen for the root Firestore `users` collection (`nama`, `email`, `kelas`); this is not the media Library or Firebase account management. The Video tab puts the dedicated YouTube player above bundled offline and device videos. The bundled MP4 path is `assets/video/rude_mv.mp4`. **Local video playback has not yet been verified on a rebuilt APK.** See `LICENSES.md` for the asset rights register before redistribution.

Device media scanning uses `photo_manager` 3.12.0 and Android read permissions only (`READ_MEDIA_AUDIO`, `READ_MEDIA_VIDEO`, and API-specific legacy/limited permissions); it does not copy, delete, or upload the original device files. Android permission is requested when the Audio or Video tab is opened. Search currently covers bundled items only. Firebase Storage audio is deferred pending approved read rules, Firestore schema, and a real authorized audio file; no stream URL is invented.

## Firebase setup gate

`android/app/google-services.json` matches project `mediahubs-bbf06`, App ID `1:244687132106:android:bcf329d5b370d5286a2b33`, and package `com.mediahubs.uts0035`. If Auth reports `CONFIGURATION_NOT_FOUND`, open this project in Firebase Console, select **Authentication > Get started > Sign-in method**, enable **Anonymous**, and save. Create the Firestore database if it does not exist, then review and publish `docs/firestore.rules.example`. The media Library uses `users/{uid}/media/{mediaId}`. Classroom CRUD uses the separate root collection `users`, with records scoped by `ownerUid`. Firebase Storage is not connected; audio and video files are not uploaded.

## UTS demo checklist

- [ ] Enable Anonymous Authentication and apply reviewed per-user rules from `docs/firestore.rules.example` before Firestore CRUD.
- [ ] Verify classroom CRUD against the root `users` collection separately from the media Library.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Confirm rights for the supplied MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.
- [ ] Validate YouTube playback, external Profile links, splash and new menu screens on Android after permission to run the app is granted.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.

Validation results and remaining device tests are recorded in `docs/TESTING.md`.

The Indonesian project report is available as [PDF](docs/Dokumentasi_Proyek_MediaHub.pdf), with its editable HTML source at [docs/Dokumentasi_Proyek_MediaHub.html](docs/Dokumentasi_Proyek_MediaHub.html). Third-party and bundled asset rights are tracked separately in [LICENSES.md](LICENSES.md).
