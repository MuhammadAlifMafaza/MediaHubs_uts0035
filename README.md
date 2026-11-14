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

Build per-ABI debug APKs with `flutter build apk --debug --split-per-abi`. On this Windows setup, Flutter's invocation fails in the Kotlin incremental cache across `C:` and `D:` drives. Verified workaround from `android/`: `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" "-Psplit-per-abi=true" --no-daemon --quiet`. Outputs from project root: `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, `app-armeabi-v7a-debug.apk`, and `app-x86_64-debug.apk`. The app ID is `com.mediahubs.uts0035`.

## Current demo

The app has Home, Search, Library, and Profile menus. Profile shows the supplied photo and creator information with GitHub, Instagram and LinkedIn links. Launcher icon, Android launch splash and Firebase-loading screen use the MediaHub logo. Library contains bundled media, direct HTTPS audio entry, a dedicated YouTube URL/player route and a Cloud Library setup screen. Search filters bundled items. Add/Edit metadata validation exists but saving is disabled until Firestore is approved. YouTube playback and the new UI have **not** been tested on a device. Confirm rights to redistribute the bundled MP3/MP4 files before distributing any APK.

## Firebase setup gate

`android/app/google-services.json` exists and its project ID/package match `mediahubs-bbf06` / `com.mediahubs.uts0035`; the Google Services Gradle plugin and `Firebase.initializeApp()` are present. This does **not** verify cloud database access. In Firebase Console for that project, inspect Firestore **Data** (database/location and existing collections), **Rules** (current published rules), and **Authentication** (enabled sign-in providers). Send those three statuses/screenshots and approve an access strategy and exact collection path. A proposed strategy is Anonymous Authentication + `users/{uid}/media/{mediaId}` with rules restricting each user to their own UID; this is **not** enabled or deployed. Only then implement matching repository, authentication, Firestore read/write and CRUD UI. Never use open test rules as final security; never add admin credentials to the app.

## UTS demo checklist

- [ ] Verify Firebase and safely enable Firestore CRUD.
- [ ] Test network audio using a direct, accessible audio URL.
- [ ] Confirm rights for the supplied MP4 and test playback offline on Android.
- [ ] Run the black-box cases listed in `docs/TESTING.md` on a real Android device/emulator and record evidence.
- [ ] Validate YouTube playback, external Profile links, splash and new menu screens on Android after permission to run the app is granted.

See `docs/IMPLEMENTATION.md` and `PROGRESS.md` for verified scope and blockers.

Validation results and remaining device tests are recorded in `docs/TESTING.md`.
