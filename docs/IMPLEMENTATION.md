# Implementation Notes

## Current structure

- `lib/main.dart`: Material 3 app, Home, Library, local/network audio players, and an asset video player screen.
- `assets/music/`: four pre-existing MP3 files referenced by the demo library.
- `pubspec.yaml`: pre-existing `just_audio` and `video_player` declarations and asset directories.
- `android/app/google-services.json`: exists locally; its presence does not verify Firestore, Authentication, rules, or runtime connectivity.

## Verified choices and limitations

- Android Gradle config currently declares namespace/application ID `com.mediahubs.uts0035` and internet permission.
- The library accepts a direct HTTPS audio URL and uses `just_audio.setUrl`; actual playback has not been verified on Android.
- Video playback uses `VideoPlayerController.asset('assets/video/sample.mp4')`, with loading/error states and lifecycle disposal. The `assets/video/` directory contains no MP4, so playable video acceptance remains blocked.
- Firebase/Firestore CRUD is not implemented. Firebase Console state and safe collection rules/path must be verified and approved first. Do not infer a root `media` collection or use unrestricted rules.
- Existing user modifications in Android/Firebase configuration, iOS project, dependency files, lockfile, and assets were present at inspection and were not reverted. No iOS target configuration was added.

## Manual Firebase gate

Verify Firebase project `mediahubs-bbf06`, registered Android app/package, Firestore Data/database location, Security Rules, and Authentication status. Approve the collection/document path and authorization strategy before code writes. Prefer authenticated user-scoped paths and rules consistent with those paths. Record console evidence and proceed with FlutterFire initialization/repository only after that decision.

## Screenshot evidence checklist

Capture only actual Android results: Home, Firestore list/data, create, update, delete confirmation/result, audio playback, video playback offline, and test results. Store the actual screenshots in `docs/screenshots/`; none are claimed yet.
