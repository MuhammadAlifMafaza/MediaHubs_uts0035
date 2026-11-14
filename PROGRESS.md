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
- Kept the reusable media card alongside the demo catalogue.
- Preserved the supplied media files and Android/Firebase configuration; updated catalogue paths to match renamed MP3 files and the existing MP4. Did not modify or configure iOS.
- Added logo-based Android launcher icons, pre-Android-12 / Android-12+ splash and logo while Firebase initializes.
- Added YouTube URL validation, iframe-backed player and Library entry, plus Profile with the supplied photo, creator identity and branded social links.
- Added Cloud Library setup gate and corrected the form to accept actual registered asset names (including spaces in the MP4 path).

## Current
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
