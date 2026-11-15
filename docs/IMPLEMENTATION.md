# Implementation Notes

## Current structure

- Current unverified phase: `photo_manager` 3.12.0 scans Android MediaStore for audio/video after per-type permission; device IDs are resolved to `content://` URIs only when tapped. `video_player` 2.14.1 uses `VideoPlayerController.contentUri` for device videos; `just_audio` uses device URI for audio. The original Unicode MP4 filename is present in the repository and referenced by the catalogue. The manual network audio URL form is removed but the network playback branch remains. **No new APK/device playback has been validated for this phase** because Flutter CLI and Gradle's Flutter bundling task timed out; details in `docs/TESTING.md`.

- `lib/main.dart`: app entry point, dark blue/green Material 3 theme, logo during Firebase bootstrap, and Home/Audio/Video/Library/Profile navigation.
- `lib/home/`, `lib/audio/`, `lib/video/`, `lib/search/`, `lib/library/`, `lib/profile/`: separate screens; Search opens from app bars; Library shows the cloud security/setup gate and Add/Edit form, not the combined bundled media list.
- `lib/media/`: metadata model/catalog, direct-to-player card/navigation (with Details in overflow), detail/form screens and an unbound `MediaRepository` contract with **no Firestore operations**.
- `lib/player/`: audio, asset/network video, and dedicated YouTube URL/player screens (iframe-backed `youtube_player_flutter` 10.0.1).
- `android/app/src/main/res/`: generated launcher icons and pre-Android-12 / Android-12+ native logo splash resources derived from the supplied logo.
- `assets/music/`: five MP3 files currently present and referenced by the demo catalogue.
- `assets/video/rude_mv.mp4`: tracked MP4 renamed from a path containing Korean characters/spaces to simplify asset lookup; file signatures contain `ftyp`, `avc1`, `mp4a`. Codec compatibility and offline playback remain unverified after the rename.
- `pubspec.yaml`: Firebase, `just_audio`, `video_player`, `youtube_player_flutter`, `url_launcher`, `font_awesome_flutter` and bundled asset directories. Dependencies resolved on 14 November 2026.
- `android/app/google-services.json`: exists locally; its presence does not verify Firestore, Authentication, rules, or runtime connectivity.

## Verified choices and limitations

- Android Gradle config currently declares namespace/application ID `com.mediahubs.uts0035` and internet permission.
- Android startup attempts `Firebase.initializeApp()` using the existing native Android Google Services setup and surfaces success/failure in the UI. Runtime initialization has not been tested in this phase.
- The library accepts a direct HTTPS audio URL and uses `just_audio.setUrl`; network playback has not been verified on Android. A bundled audio asset was observed playing on the connected device (see `docs/TESTING.md`).
- Video playback uses `VideoPlayerController.asset(item.mediaUrl)`, with loading/error/retry/full-screen controls and controller disposal. An earlier device report showed the generic video-unavailable message; the new player preserves the actual exception for diagnosis. Offline playback must still be tested on Android.
- Firebase/Firestore CRUD is not implemented. Firebase Console state and safe collection rules/path must be verified and approved first. Do not infer a root `media` collection or use unrestricted rules. The unbound repository contract will receive an implementation only after the approved data path is known.
- The Add/Edit form includes metadata fields and input validation, but its save action is disabled until an approved repository is connected.
- Existing user modifications in Android/Firebase configuration, iOS project, dependency files, lockfile, and assets were present at inspection and were not reverted. No iOS target configuration was added.
- On 14 November 2026 the user requested device validation. Analyzer, widget tests and a Gradle non-incremental debug build passed; the APK was installed and the Library was seen on SM A226B. See `docs/TESTING.md` for details and remaining gaps.
- The Flutter package name is `mediahub` and the Android launcher label is `MediaHub`; the Firebase JSON package name was inspected and matches `com.mediahubs.uts0035`.
- Search currently filters the bundled demo catalogue by title, creator, and category; Firestore-backed search is not connected.
- The form accepts only registered bundled asset paths; the MP4 now uses ASCII-only `assets/video/rude_mv.mp4`. YouTube URLs are accepted only over HTTPS on allowlisted hosts and routed through the dedicated player, never to `video_player`. The featured/editable default is `https://youtu.be/chl0R8C4NJ8`.
- Network audio has an optional title input showing `Hearts2Hearts - Moonride` as a **label example only**. No licensed direct audio URL was supplied; do not treat the example as a playable demo.
- The visual layout is inspired by familiar music-player navigation without copying Spotify branding. A persistent mini-player is P1 and was not added; current players release their controllers when leaving their screens.
- On 15 November 2026, later retries of `flutter pub get`, `flutter analyze` and `flutter test` passed (8/8 tests). Flutter APK build failed due to Kotlin incremental cache paths across `C:`/`D:`; a retry timed out. Gradle with incremental Kotlin disabled, a 1200 MB heap, one worker and ForkJoinPool parallelism 1 produced all three debug ABI APKs. Those settings are recorded in `android/gradle.properties`; `-Psplit-per-abi=true` is still needed for split outputs via Gradle. No application was installed or run. See `docs/TESTING.md` for earlier attempts and command results.
- Android split-per-ABI debug APKs compiled via direct Gradle with `-Psplit-per-abi=true -Pkotlin.incremental=false`; Flutter CLI failed on cross-drive Kotlin cache. No device install, launch, or media playback occurred in **this** implementation phase. See `docs/TESTING.md`.

## Manual Firebase gate

Verify Firebase project `mediahubs-bbf06`, registered Android app/package, Firestore Data/database location, Security Rules, and Authentication status. Approve the collection/document path and authorization strategy before code writes. Suggested (not approved/deployed): enable Anonymous Authentication and restrict access per UID under `users/{uid}/media/{mediaId}` with matching rules. If existing schema/rules differ, adapt code to the actually approved setup instead. Record console evidence and implement repository/Auth only after that decision; Firebase initialization code already exists but does not prove Firestore connectivity.

## Screenshot evidence checklist

Capture only actual Android results: Home, Firestore list/data, create, update, delete confirmation/result, audio playback, video playback offline, and test results. Library and bundled-audio screenshots were inspected in a local temporary directory during validation; no project screenshot files have been added yet.
