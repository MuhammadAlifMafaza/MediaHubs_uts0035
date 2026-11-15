# MediaHub Progress

## Completed in this implementation phase
- Kept the existing Flutter Android project and Android application ID `com.mediahubs.uts0035`.
- Reorganized `lib/` by feature: `main.dart` contains the entry point, app shell, and navigation; separate `home/`, `search/`, `library/`, `media/`, and `player/` directories hold their screens and related code. Removed the redundant `app.dart` at the user's request.
- Set the Flutter package name and Android display label to `mediahub` / `MediaHub`.
- Added the supplied MediaHub logo to the Home screen and completed Home → Library → Media Detail → Audio Player navigation for bundled tracks.
- Added an Add/Edit metadata form with title, creator, media/source type, URL/path validation; Save is deliberately disabled pending approved Firestore setup.
- Added direct HTTPS audio URL entry with `just_audio`, plus playback loading/error, progress, seeking, and controller disposal.
- Added the bundled asset video player flow with loading/error states, progress/seek controls, and controller disposal.
- Added Firebase startup initialization with a visible status and a Firestore metadata model. An unbound repository interface describes cloud operations; the concrete implementation is deferred until the collection path and security model are approved.
- The original reusable media card was replaced by a direct-to-player card with Details in its overflow menu.
- Preserved the supplied media files and Android/Firebase configuration; updated catalogue paths to match renamed MP3 files and the existing MP4. Did not modify or configure iOS.
- Added logo-based Android launcher icons, pre-Android-12 / Android-12+ splash and logo while Firebase initializes.
- Added YouTube URL validation, iframe-backed player and Library entry, plus Profile with the supplied photo, creator identity and branded social links.
- Added Cloud Library setup gate and corrected the form to accept registered bundled assets.

## Current phase (15 November 2026)
- Build repair: `flutter pub get` passed, `flutter analyze` found no issues, and 8/8 widget/unit tests passed via temporary `subst M:`. Standard `flutter build apk --debug --split-per-abi` failed on cross-drive Kotlin cache; its retry after changing Gradle settings timed out. Direct Gradle with incremental Kotlin disabled, one worker and a 1200 MB heap **passed** and produced three debug split APKs under `build/app/outputs/flutter-apk/` (17:59). `android/gradle.properties` now records the low-memory and non-incremental settings. No app was installed or run.
- Added separate Audio/Video tabs and direct-to-player taps from the lists and Search. Home links to both; Library retains metadata/cloud setup, Profile remains a tab. Styled the app and Now Playing/Now Watching screens with MediaHub dark blue/green branding and clearer artwork/progress/controls.
- Renamed the tracked MP4 to `assets/video/rude_mv.mp4` and updated its catalogue path; the video player now displays the underlying initialization/playback error and offers retry/full-screen controls. File signatures include `ftyp`, `avc1`, and `mp4a`, but Android offline playback is **not** verified after this change.
- Pre-filled the editable YouTube URL with `https://youtu.be/chl0R8C4NJ8`; the Video tab also opens the featured video player directly. Network audio shows the Moonride title as an example but requires a lawful direct audio URL from the user.
- Removed only the unused MediaCard implementation and two empty untracked scaffold directories (`lib/models/`, `lib/repositories/`). Supplied assets, Firebase configuration, and generated Gradle caches were not deleted.
- Earlier in this phase, Flutter/Dart CLI and a direct Gradle build timed out. Later retries produced the verified test/build results above. See `docs/TESTING.md` for both attempts.

## Previous status
- Three **debug split-per-ABI APKs built** without installing or running this revision. Earlier device-validation session saw the old Library and bundled audio progress; it does not validate the new screens.
- Firestore CRUD, network audio, YouTube playback and offline video acceptance remain incomplete.

## Blockers / deferred dependencies
- Firestore CRUD requires user verification of Firestore Data, Security Rules, Authentication, and approval of the collection/document path. A concrete repository and CRUD UI remain gated by that decision.
- One MP4 exists under `assets/video/` and is referenced by the catalogue; offline video playback has not been checked.
- The supplied MP3/MP4 files' redistribution rights have not been checked. Do not distribute without confirmation.
- Default `flutter build apk --debug` failed because Kotlin incremental cache files span `C:` and `D:`; `./gradlew.bat :app:assembleDebug "-Pkotlin.incremental=false" --no-daemon --quiet` succeeded instead.

## Next
1. User provides or approves Firebase Console Data, Rules, Authentication and the exact media path; implement matching authentication and CRUD only after confirmation.
2. Verify the newly built app on Android **only after** user permits running it.
3. Confirm media redistribution rights, then test MP4 playback offline on Android.
4. Verify network audio, YouTube, external links and the Firebase CRUD flow after security approval.

## Tests / verification (current phase, 14 November 2026)
- `flutter pub get`: passed. `flutter analyze`: no issues. `flutter test` via `subst M:`: 7/7 passed. Final format check: 0 changes.
- `flutter build apk --debug --split-per-abi`: failed due to cross-drive Kotlin incremental caches. Direct Gradle `:app:assembleDebug -Pkotlin.incremental=false -Psplit-per-abi=true --no-daemon --quiet`: passed. Outputs: `build/app/outputs/flutter-apk/app-{arm64-v8a,armeabi-v7a,x86_64}-debug.apk`.
- New APK not run on a device. Only build contents inspected (arm64 native library and profile/logo resources).

## Tests / verification (previous phase, 14 November 2026)
- `flutter pub get`: passed. `dart format --output=none --set-exit-if-changed lib test`: passed after formatting.
- `flutter analyze`: no issues. `flutter test`: 2/2 passed using a temporary `M:` drive mapping to avoid the apostrophe in the real project path.
- `flutter build apk --debug`: failed due to cross-drive Kotlin incremental caches. Gradle debug build with `-Pkotlin.incremental=false`: passed; APK `build/app/outputs/flutter-apk/app-debug.apk` installed and launched via Android SDK `adb` on SM A226B.
- Library screenshot and asset audio progress/pause were observed. Video, network audio, and live Firestore were not validated.
