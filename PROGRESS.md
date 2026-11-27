# MediaHub Progress

## Firestore shared access without Authentication (27 November 2026)
- **Decision:** The project owner chose no Firebase Authentication. Root `songs`, `users`, and `playlist` are shared and publicly readable/writable under the Rules; do not store private data there.
- **Completed:** Removed `firebase_auth` and anonymous sign-in from both Firestore repositories. Cloud Library now uses root `songs`; classroom CRUD uses root `users` without `ownerUid`.
- **Completed:** Replaced the per-user Rules example with core-field/timestamp validation for `songs` and `users`, allowing additional fields and optional song description/category/thumbnail. Network media remains HTTPS; any non-empty `assets/` path is allowed. Public CRUD on `playlist` remains unrestricted. Legacy `ownerUid` is removed when existing user records are edited.
- **Dependency:** `dart pub get --offline` completed successfully; `firebase_auth` was removed from `pubspec.lock`.
- **Validation:** `dart format --output=none --set-exit-if-changed lib test` passed; `dart analyze lib test` passed; `flutter test --concurrency=1` passed 11/11.
- **Flexible Rules update:** Format and analyzer checks passed after changing Rules/docs. Flutter test retest stalled before output and was stopped; no application Dart source changed. Firebase Rules Playground validation remains pending because Rules are not deployed and Emulator/CLI is unavailable.
- **Users list repair:** Parsing no longer fails the whole stream for missing, blank, or non-string `nama`/`email`/`kelas`. Invalid rows remain visible with placeholders and a repair warning; users can edit or delete them, with no automatic Firestore writes during reads. Regression tests were added. Format/analyzer pass; Flutter test invocation stalled before output and was stopped.
- **Build:** `flutter build apk --release` passed; output is `build/app/outputs/flutter-apk/app-release.apk` (55.2 MB). This APK was not installed/launched after the change.
- **Pending:** The Firebase Console Rules have not been published and Firestore CRUD has not been tested against the live project. Extra fields are accepted from any public client, not just this app. Existing root `media` documents and older `users/{uid}/media` documents are not migrated to root `songs`. Firebase Storage remains unimplemented; playlist has no app UI or schema validation.
- **User-local files preserved:** `lib/media/media_catalog.dart` title edit, the local screenshot files, and the generated Kotlin session deletion were not included in this change.

> The entries below are historical implementation phases. The no-auth shared Firestore decision and current validation above supersede their earlier authentication gates.

## Users CRUD and video player update (27 November 2026)
- **Completed:** Renamed the bundled video path to `assets/video/rude_mv.mp4`, updated the catalog/pubspec/test references, and moved the YouTube section above offline/device videos.
- **Completed:** Added a standalone root `users` Firestore CRUD flow (`nama`, `email`, `kelas`) launched from Home. It is separate from Library/media CRUD and scopes records by anonymous `ownerUid`.
- **Security:** Added a Rules example for the root `users` CRUD path alongside the existing media rules. No Firebase Console settings or remote Rules were changed; Anonymous Authentication and the matching Rules must still be enabled/reviewed by the project owner.
- **Tests:** `dart format --output=none --set-exit-if-changed lib test` passed; `flutter analyze` passed; the focused Video ordering test passed. The Users CRUD widget test passed in a full run, but that full run had one failure in the existing Cloud Library detail-action test. `flutter build apk --debug` timed out after 240 seconds; no new APK is claimed.
- **Current:** Verify local video playback and live Firestore CRUD on a device after the cloud setup is approved; diagnose the existing Cloud Library widget-test viewport failure separately.
- **Playlist:** Existing `playlist` collection was not changed because its schema and requested operations were not specified.
- **Rights:** The bundled music-video asset still has no documented redistribution permission; renaming did not alter its rights status.

## Repository cleanup (27 November 2026)
- Synced the video asset assertion and current README/implementation notes with the Unicode asset filename now present in the workspace: `assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4`.
- Added `/android/build/` to `.gitignore` and removed the generated Gradle HTML report from Git's index while preserving its local copy. This prevents generated build output from skewing GitHub's language statistics.
- No tests or builds were run during this cleanup; device playback remains unverified.

## Library and network audio improvements (27 November 2026)
**Completed:** Added bundled media to Library, replaced the inert Library action with Cloud setup, and added a direct HTTPS audio URL form.
**Current:** Firebase read/write remains gated on approved Firestore schema and rules.
**Next:** Enable Anonymous sign-in and apply reviewed Firestore Rules in Console; then verify CRUD and player behavior on Android.
**Blockers:** Firebase Console setup has not been changed or verified. No system Gradle wrapper/executable is present; Flutter test/build commands timed out without output.
**Tests:** `dart pub get`, SDK formatter, and standalone Dart analyzer passed. `flutter test` and `flutter analyze` timed out; Android build and Firebase integration were not run.

**Firestore implementation:** Added `firebase_auth` 7.1.0, anonymous sign-in on cloud access, per-user paths, realtime list states, CRUD forms/details/delete confirmation, and an example per-user Rules file. No remote Firebase configuration was changed.

## Local video asset path repair (27 November 2026)
**Completed:** Confirmed catalog and physical MP4 paths match; made the MP4 declaration explicit in `pubspec.yaml`, fixed the obsolete widget-test path, aligned the Firestore sample rule and docs with the actual Unicode filename. Static MP4 markers indicate H.264 Main Profile Level 3.1 and AAC.
**Current:** Asset playback requires a newly built APK and Android device confirmation.
**Blockers:** Flutter build timed out; no Gradle wrapper or system Gradle executable is installed. No new APK or playback result is claimed.

## Active phase — device media and player recovery (15 November 2026)
- Release validation attempt (later, same date): connected SM A226B detected through `adb`, but `flutter --version`, `flutter build apk --release --split-per-abi`, and `flutter run --release -d R9CT4004VJE --no-resident` all timed out without output. Direct Gradle release assembly timed out while its Flutter bundling subprocess stalled; **no new release APK was created and no new app build was installed/launched**. `android/build/reports/problems/problems-report.html` changed as a generated byproduct. See `docs/TESTING.md`.
- The Git worktree was clean at the start. The tracked MP4 already had its original Unicode filename, but `lib/media/media_catalog.dart` still pointed to missing `rude_mv.mp4`; the catalogue and asset assertion now use the existing filename.
- Added Android read-media permissions and `photo_manager` 3.12.0. Audio and Video tabs request only their own media permission when selected, show local MediaStore items/empty/denied/error states, and resolve device IDs to content URIs on tap. No original device file is deleted or uploaded.
- Kept a network playback branch for future approved cloud audio, but removed the manual network URL form. No Firebase Storage or Firestore reads/writes were enabled; cloud access rules and the no-login write strategy remain unapproved.
- Standalone SDK formatter and analyzer completed (22 Dart files, 0 diagnostics). `flutter test` timed out; Gradle waited indefinitely for its Flutter asset-bundling subprocess and timed out. The user authorized stopping Flutter/Dart processes and running the project, but `flutter --version` and `flutter run -d R9CT4004VJE --debug --no-resident` still timed out without output. APK timestamps still belong to the earlier build, so **no new APK or device playback is claimed for these changes**. The connected SM A226B was detected with `adb`. See `docs/TESTING.md`.

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
