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

Build a debug APK with `flutter build apk --debug`. On this Windows setup, Gradle's incremental Kotlin cache can fail across the `C:` dependency cache and `D:` project drives. The verified local workaround is `cd android` then `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" --no-daemon`. The APK is written to `build/app/outputs/flutter-apk/app-debug.apk` from the project root. The app identity is `com.mediahubs.uts0035`; Android Firebase configuration is expected at `android/app/google-services.json`.

## Current demo

The app has separate Home, Search, and Library menu screens. Search filters the bundled catalogue; each item opens a detail screen and asset player. The Add/Edit form validates metadata but keeps saving disabled until Firestore is approved. The library also accepts a direct HTTPS audio URL for network playback. Firebase initialization is attempted at app startup and its result is displayed. The catalogue references the MP3 and MP4 files currently present in `assets/`; confirm you have permission to redistribute them. The video is not yet device-tested.

## Firebase setup gate

In Firebase Console, verify the `mediahubs-bbf06` Android app, Firestore database and location, Authentication providers, current rules, and any existing data. Approve a safe schema/path (prefer user-scoped documents with authenticated access) before implementing CRUD. Do not use unrestricted test rules as a final configuration. Then adapt repository paths and document the approved rules; do not put admin credentials in the app.

## UTS demo checklist

- [ ] Verify Firebase and safely enable Firestore CRUD.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Confirm rights for the supplied MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.

Validation results and remaining device tests are recorded in `docs/TESTING.md`.
