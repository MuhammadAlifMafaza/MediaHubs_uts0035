# Implementation Notes

## Current structure

- Current unverified phase: `photo_manager` 3.12.0 scans Android MediaStore for audio/video after per-type permission; device IDs are resolved to `content://` URIs only when tapped. `video_player` 2.14.1 uses `VideoPlayerController.contentUri` for device videos; `just_audio` uses device URI for audio. The bundled MP4 is `assets/video/rude_mv.mp4`. Audio has a direct HTTPS URL entry screen. The no-auth Firestore change built successfully in release mode, but the new APK has not been installed/launched and live Firestore CRUD/device playback remain unverified; details in `docs/TESTING.md`.

- `lib/main.dart`: app entry point, dark blue/green Material 3 theme, logo during Firebase bootstrap, and Home/Audio/Video/Library/Profile navigation.
- `lib/home/`, `lib/audio/`, `lib/video/`, `lib/search/`, `lib/library/`, `lib/profile/`: separate screens; Search opens from app bars; Library shows bundled media and a cloud setup gate.
- `lib/media/`: metadata model/catalog, Firestore repository, direct-to-player navigation, cloud create/edit form, and details with delete confirmation.
- `lib/users/`: independent classroom CRUD for shared root Firestore `users` records (`nama`, `email`, `kelas`), without Firebase Authentication or owner filtering; it is not connected to the media Library or Firebase account management.
- `lib/player/`: audio, asset/network video, and dedicated YouTube URL/player screens (iframe-backed `youtube_player_flutter` 10.0.1).
- `android/app/src/main/res/`: generated launcher icons and pre-Android-12 / Android-12+ native logo splash resources derived from the supplied logo.
- `assets/music/`: five MP3 files currently present and referenced by the demo catalogue.
- `assets/video/rude_mv.mp4`: bundled MP4 with a simplified asset path. Android playback remains unverified; renaming the file does not by itself establish codec compatibility.
- `pubspec.yaml`: Firebase Core/Firestore, `just_audio`, `video_player`, `youtube_player_flutter`, `url_launcher`, `font_awesome_flutter` and bundled asset directories. Firebase Authentication is not used.
- `android/app/google-services.json`: exists locally; its presence does not verify Firestore Rules or runtime connectivity.

## Verified choices and limitations

- Android Gradle config currently declares namespace/application ID `com.mediahubs.uts0035` and internet permission.
- Android startup attempts `Firebase.initializeApp()` using the existing native Android Google Services setup and surfaces success/failure in the UI. Runtime initialization has not been tested in this phase.
- Audio includes a direct HTTPS URL form that opens the shared `just_audio` player; network playback has not been verified on Android. A bundled audio asset was observed playing on the connected device (see `docs/TESTING.md`).
- Video playback uses `VideoPlayerController.asset(item.mediaUrl)`, with loading/error/retry/full-screen controls and controller disposal. An earlier device report showed the generic video-unavailable message; the new player preserves the actual exception for diagnosis. Offline playback must still be tested on Android.
- Firestore repositories use public root collections `media` and `users` without Authentication. `docs/firestore.rules.example` validates schemas but permits any client to read/create/update/delete records in those collections; it is not deployed. Do not store private data there.
- Cloud Library provides realtime listing, loading/empty/error states, create/edit, and delete confirmation. CRUD has not been verified against Firebase.
- The Video tab displays its featured YouTube player section above offline videos. The root `users` CRUD and media Library use distinct screens and repositories. Firebase Storage is not integrated; media files remain local or on their existing network source.
- Existing user modifications in Android/Firebase configuration, iOS project, dependency files, lockfile, and assets were present at inspection and were not reverted. No iOS target configuration was added.
- On 14 November 2026 the user requested device validation. Analyzer, widget tests and a Gradle non-incremental debug build passed; the APK was installed and the Library was seen on SM A226B. See `docs/TESTING.md` for details and remaining gaps.
- The Flutter package name is `mediahub` and the Android launcher label is `MediaHub`; the Firebase JSON package name was inspected and matches `com.mediahubs.uts0035`.
- Search currently filters the bundled demo catalogue by title, creator, and category; Firestore-backed search is not connected.
- The form accepts only registered bundled asset paths; the local MP4 path is `assets/video/rude_mv.mp4`. YouTube URLs are accepted only over HTTPS on allowlisted hosts and routed through the dedicated player, never to `video_player`. The featured/editable default is `https://youtu.be/chl0R8C4NJ8`.
- The network audio screen accepts a user-provided direct HTTPS URL; no playable example stream URL is bundled or claimed.
- The visual layout is inspired by familiar music-player navigation without copying Spotify branding. A persistent mini-player is P1 and was not added; current players release their controllers when leaving their screens.
- On 15 November 2026, later retries of `flutter pub get`, `flutter analyze` and `flutter test` passed (8/8 tests). Flutter APK build failed due to Kotlin incremental cache paths across `C:`/`D:`; a retry timed out. Gradle with incremental Kotlin disabled, a 1200 MB heap, one worker and ForkJoinPool parallelism 1 produced all three debug ABI APKs. Those settings are recorded in `android/gradle.properties`; `-Psplit-per-abi=true` is still needed for split outputs via Gradle. No application was installed or run. See `docs/TESTING.md` for earlier attempts and command results.
- Android split-per-ABI debug APKs compiled via direct Gradle with `-Psplit-per-abi=true -Pkotlin.incremental=false`; Flutter CLI failed on cross-drive Kotlin cache. No device install, launch, or media playback occurred in **this** implementation phase. See `docs/TESTING.md`.

## Manual Firebase setup

In Firebase project `mediahubs-bbf06`, create Firestore if needed, review `docs/firestore.rules.example`, and publish the public rules for root collections `media` and `users`. No Authentication provider is required. Any client can read, create, update, or delete these records; schema validation does not provide ownership or protect sensitive data. The new `media` root collection does not automatically migrate older `users/{uid}/media` subcollections. Firebase Storage remains unimplemented. Record console and device evidence after setup; local repository code does not prove remote access.

## Screenshot evidence checklist

Capture only actual Android results: Home, Firestore list/data, create, update, delete confirmation/result, audio playback, video playback offline, and test results. Library and bundled-audio screenshots were inspected in a local temporary directory during validation; no project screenshot files have been added yet.
