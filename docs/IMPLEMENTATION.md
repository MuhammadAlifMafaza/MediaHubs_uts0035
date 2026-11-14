# Implementation Notes

## Current structure

- `lib/main.dart`: app entry point, Material 3 theme, logo during Firebase bootstrap, and Home/Search/Library/Profile navigation.
- `lib/home/`, `lib/search/`, `lib/library/`, `lib/profile/`: separate screens; Cloud Library currently shows an explicit security/setup gate.
- `lib/media/`: metadata model/catalog, detail/form screens and an unbound `MediaRepository` contract with **no Firestore operations**.
- `lib/player/`: audio, asset/network video, and dedicated YouTube URL/player screens (iframe-backed `youtube_player_flutter` 10.0.1).
- `android/app/src/main/res/`: generated launcher icons and pre-Android-12 / Android-12+ native logo splash resources derived from the supplied logo.
- `assets/music/`: five MP3 files currently present and referenced by the demo catalogue.
- `assets/video/`: one user-provided MP4 referenced by the demo catalogue; redistribution rights and offline playback remain unverified.
- `pubspec.yaml`: Firebase, `just_audio`, `video_player`, `youtube_player_flutter`, `url_launcher`, `font_awesome_flutter` and bundled asset directories. Dependencies resolved on 14 November 2026.
- `android/app/google-services.json`: exists locally; its presence does not verify Firestore, Authentication, rules, or runtime connectivity.

## Verified choices and limitations

- Android Gradle config currently declares namespace/application ID `com.mediahubs.uts0035` and internet permission.
- Android startup attempts `Firebase.initializeApp()` using the existing native Android Google Services setup and surfaces success/failure in the UI. Runtime initialization has not been tested in this phase.
- The library accepts a direct HTTPS audio URL and uses `just_audio.setUrl`; network playback has not been verified on Android. A bundled audio asset was observed playing on the connected device (see `docs/TESTING.md`).
- Video playback uses `VideoPlayerController.asset(item.mediaUrl)`, with loading/error states and lifecycle disposal. The catalogue references an existing MP4, but video playback/offline behavior has not been verified.
- Firebase/Firestore CRUD is not implemented. Firebase Console state and safe collection rules/path must be verified and approved first. Do not infer a root `media` collection or use unrestricted rules. The unbound repository contract will receive an implementation only after the approved data path is known.
- The Add/Edit form includes metadata fields and input validation, but its save action is disabled until an approved repository is connected.
- Existing user modifications in Android/Firebase configuration, iOS project, dependency files, lockfile, and assets were present at inspection and were not reverted. No iOS target configuration was added.
- On 14 November 2026 the user requested device validation. Analyzer, widget tests and a Gradle non-incremental debug build passed; the APK was installed and the Library was seen on SM A226B. See `docs/TESTING.md` for details and remaining gaps.
- The Flutter package name is `mediahub` and the Android launcher label is `MediaHub`; the Firebase JSON package name was inspected and matches `com.mediahubs.uts0035`.
- Search currently filters the bundled demo catalogue by title, creator, and category; Firestore-backed search is not connected.
- The form now permits registered bundled asset paths containing spaces, including the existing MP4. YouTube URLs are accepted only over HTTPS on allowlisted YouTube hosts and routed through the dedicated player, never to `video_player`.
- Android split-per-ABI debug APKs compiled via direct Gradle with `-Psplit-per-abi=true -Pkotlin.incremental=false`; Flutter CLI failed on cross-drive Kotlin cache. No device install, launch, or media playback occurred in **this** implementation phase. See `docs/TESTING.md`.

## Manual Firebase gate

Verify Firebase project `mediahubs-bbf06`, registered Android app/package, Firestore Data/database location, Security Rules, and Authentication status. Approve the collection/document path and authorization strategy before code writes. Suggested (not approved/deployed): enable Anonymous Authentication and restrict access per UID under `users/{uid}/media/{mediaId}` with matching rules. If existing schema/rules differ, adapt code to the actually approved setup instead. Record console evidence and implement repository/Auth only after that decision; Firebase initialization code already exists but does not prove Firestore connectivity.

## Screenshot evidence checklist

Capture only actual Android results: Home, Firestore list/data, create, update, delete confirmation/result, audio playback, video playback offline, and test results. Library and bundled-audio screenshots were inspected in a local temporary directory during validation; no project screenshot files have been added yet.
