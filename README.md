# MediaHub

Android-first Flutter multimedia library prototype for the UTS project.

## Requirements

- Flutter 3.47.7 / Dart 3.13.5 (or compatible)
- Android SDK and an Android emulator or device
- For Firestore features: Firebase Console access to verify Firestore, Authentication, rules, and the approved collection structure
- For offline video playback: a legally usable MP4 video at `assets/video/sample.mp4`

## Setup and run

```sh
flutter pub get
flutter run -d <android-device-id>
```

Build a debug APK with `flutter build apk --debug`. The current app identity is `com.mediahubs.uts0035`; Android Firebase configuration is expected at `android/app/google-services.json`.

## Current demo

Home opens a local library of bundled audio tracks under `assets/music/`. The library also accepts a direct HTTPS audio URL for network playback (actual playback still needs device verification). Firestore CRUD is intentionally not enabled until the project’s database, Authentication, rules, and safe data path are verified. The asset video screen expects `assets/video/sample.mp4`; no video file is currently supplied.

## Firebase setup gate

In Firebase Console, verify the `mediahubs-bbf06` Android app, Firestore database and location, Authentication providers, current rules, and any existing data. Approve a safe schema/path (prefer user-scoped documents with authenticated access) before implementing CRUD. Do not use unrestricted test rules as a final configuration. Then adapt repository paths and document the approved rules; do not put admin credentials in the app.

## UTS demo checklist

- [ ] Verify Firebase and safely enable Firestore CRUD.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Supply a compatible, reusable MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.
