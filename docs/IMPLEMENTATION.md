# Implementation Notes

## Current structure

- `lib/main.dart`: app entry point, Material 3 theme, Firebase startup status, and Home/Search/Library navigation.
- `lib/home/`, `lib/search/`, `lib/library/`: separate main menu screens.
- `lib/media/`: metadata model/catalog (including its reusable media card), and detail/form screens.
- `lib/player/`: audio and video player screens.
- `assets/music/`: five MP3 files currently present and referenced by the demo catalogue.
- `assets/video/`: one user-provided MP4 referenced by the demo catalogue; redistribution rights and offline playback remain unverified.
- `pubspec.yaml`: `firebase_core`, `cloud_firestore`, `just_audio`, and `video_player` declarations plus asset directories. Dependency resolution passed on 14 November 2026.
- `android/app/google-services.json`: exists locally; its presence does not verify Firestore, Authentication, rules, or runtime connectivity.

## Verified choices and limitations

- Android Gradle config currently declares namespace/application ID `com.mediahubs.uts0035` and internet permission.
- Android startup attempts `Firebase.initializeApp()` using the existing native Android Google Services setup and surfaces success/failure in the UI. Runtime initialization has not been tested in this phase.
- The library accepts a direct HTTPS audio URL and uses `just_audio.setUrl`; network playback has not been verified on Android. A bundled audio asset was observed playing on the connected device (see `docs/TESTING.md`).
- Video playback uses `VideoPlayerController.asset(item.mediaUrl)`, with loading/error states and lifecycle disposal. The catalogue references an existing MP4, but video playback/offline behavior has not been verified.
- Firebase/Firestore CRUD is not implemented. Firebase Console state and safe collection rules/path must be verified and approved first. Do not infer a root `media` collection or use unrestricted rules. A repository will be added when the approved data path is known.
- The Add/Edit form includes metadata fields and input validation, but its save action is disabled until an approved repository is connected.
- Existing user modifications in Android/Firebase configuration, iOS project, dependency files, lockfile, and assets were present at inspection and were not reverted. No iOS target configuration was added.
- On 14 November 2026 the user requested device validation. Analyzer, widget tests and a Gradle non-incremental debug build passed; the APK was installed and the Library was seen on SM A226B. See `docs/TESTING.md` for details and remaining gaps.
- The Flutter package name is `mediahub` and the Android launcher label is `MediaHub`; the Firebase JSON package name was inspected and matches `com.mediahubs.uts0035`.
- Search currently filters the bundled demo catalogue by title, creator, and category; Firestore-backed search is not connected.

## Manual Firebase gate

Verify Firebase project `mediahubs-bbf06`, registered Android app/package, Firestore Data/database location, Security Rules, and Authentication status. Approve the collection/document path and authorization strategy before code writes. Prefer authenticated user-scoped paths and rules consistent with those paths. Record console evidence and proceed with FlutterFire initialization/repository only after that decision.

## Screenshot evidence checklist

Capture only actual Android results: Home, Firestore list/data, create, update, delete confirmation/result, audio playback, video playback offline, and test results. Library and bundled-audio screenshots were inspected in a local temporary directory during validation; no project screenshot files have been added yet.
