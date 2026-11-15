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

The app has Home, Audio, Video, Library and Profile navigation; Search is available from the Home/Audio/Video app bars. Tap a local media item to open its player directly; the `⋯` menu opens Details. Audio contains the bundled tracks and a direct HTTPS audio entry; Video contains the offline MP4 and a YouTube entry with an editable URL initially set to `https://youtu.be/chl0R8C4NJ8`. Library is reserved for cloud metadata/setup and the gated Add/Edit form. Profile shows the supplied photo and social links. The MP4 is now named `assets/video/rude_mv.mp4` to avoid special characters in the bundled asset key; error and retry controls help diagnose playback. **Debug APKs have been built, but none has been installed or tested on a device in this phase.** Confirm MP3/MP4 redistribution rights before sharing an APK.

For a network audio example, enter the title `Hearts2Hearts - Moonride` and supply a licensed direct HTTPS MP3/stream URL yourself. A YouTube or music-page URL is **not** a playable direct audio URL; no working Moonride MP3 URL has been verified or prefilled.

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
