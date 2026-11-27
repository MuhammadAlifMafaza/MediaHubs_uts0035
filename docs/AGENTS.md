# MediaHub — OpenCode Agent Instructions

> Persistent project instructions for AI coding agents. Read `PRD.md` in full before changing source code.

## Project identity

- Product: **MediaHub**, personal multimedia library and player.
- Scope: **Android only for UTS**. Do not create or configure an iOS target.
- Flutter project: `mediahub`; display name: `MediaHub`.
- Android application ID: `com.mediahubs.uts0035`.
- Firebase project ID: `mediahubs-bbf06`.
- Firebase Android configuration should come from the user-provided `google-services.json` (rename any downloaded `google-services(1).json` when copying into `android/app/`). Never fabricate configuration values.
- Reference specification: `PRD.md` version 2.0 (or the latest user-approved revision).

## Source of truth and priorities

1. Explicit user instructions and current verified environment state.
2. `PRD.md` requirements and acceptance criteria.
3. This `AGENTS.md` for coding conventions and autonomous workflow.
4. `MASTER_PROMPT.md` for execution sequence.

Implement **P0 features first**: Firestore read/create/update/delete; audio playback from network; bundled asset video playback; Home/Library/Detail/Forms; loading, empty, error, and confirmation states. Features P1/P2 (YouTube, mini player, SQLite, file importing, iOS) must not delay or destabilize P0.

## Working rules

1. Inspect the existing files and `git status` before edits. Preserve user code, credentials, and unrelated changes.
2. Never reset, overwrite, or delete unrelated files. Do not run destructive commands without explicit scope and confirmation when necessary.
3. Keep implementation small, readable, and demonstrable for UTS. Prefer simple Flutter Material 3 widgets and clear repository/service boundaries.
4. Maintain names and schema consistently. Model media metadata separately from actual binary audio/video files.
5. Follow Dart null safety, `dart format`, and Flutter lint recommendations. Dispose audio/video controllers; check `mounted` around asynchronous widget updates.
6. Do not add packages until required; choose versions supported by the installed Flutter and Android SDK. Record package and SDK compatibility decisions.
7. Validate input (title, creator, media type, source type, URL/path). Display actionable errors; do not silently swallow exceptions.
8. Use `StreamBuilder` or equivalent reactive state for Firestore lists, and track loading, empty, error, and success states.
9. For all CRUD actions, include clear success/failure feedback and delete confirmation.
10. Never imply cloud metadata caching means MP3/MP4 have been downloaded for offline use.

## Firebase and security policy

- Treat existing Firebase Android JSON as **project configuration**, not as proof of working Firestore, authentication, or rules.
- Before implementing writes, inspect available Firestore schema and Rules. If inaccessible, clearly record the missing console actions.
- The project owner explicitly approved no-auth shared Firestore CRUD for this UTS demo. Cloud Library uses root `songs`, classroom CRUD uses root `users`, and root `playlist` also has public Rules in `docs/firestore.rules.example`; do not add Firebase Authentication unless the owner changes this decision.
- These public Rules allow any client to read, create, update, or delete documents in all three collections. `songs` and `users` validate core fields but accept extra fields; `songs` also allows optional descriptive fields. `playlist` has no app schema/UI yet. Because access is public, any client can write extra fields. Do not store sensitive data. Do not deploy remote Rules or create cloud resources without explicit authorization.
- Do not create service-account keys, commit tokens, echo secrets, or copy project credentials into documentation.
- Do not change remote Firebase settings, deploy rules, or create cloud resources without authorization and access.
- When a required Firebase choice is unverified, stop only the dependent task; continue independent UI, asset playback, and tests.

## Android build and media rules

- Maintain package `com.mediahubs.uts0035` consistently across Android Gradle, manifest, and source package names where relevant.
- Use FlutterFire setup compatible with the installed SDK. Do not assume the downloaded JSON alone initializes Firebase.
- Keep Android internet permission for network-backed Firebase/audio functionality.
- Bundled video assets must be listed correctly in `pubspec.yaml` and tested offline.
- `video_player` should receive a playable asset or direct media URL; a YouTube watch URL is **not** a direct video stream.
- Test media legally reusable, small enough for the repository, and playable on Android target devices.

## Multi-model OpenCode usage

- One primary agent owns implementation and integration unless the user explicitly configures additional agents.
- OpenCode may expose Gemini, Claude, GPT, and other providers, but **provider availability does not automatically enable model routing or delegation**.
- Never invent model IDs or change `opencode.json` without checking installed commands, available configured provider/model identifiers, and user approval when costs/permissions would change.
- Optional independent review with a second configured model may be performed sequentially, not by concurrent agents writing the same files.
- Do not claim independent multi-model review occurred unless actually executed and recorded.

## Validation loop

After completing a coherent phase, run relevant checks where available:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Apply formatting before formatting validation when needed. Commands requiring missing SDK, emulator, or network access may be reported as **Blocked**; never mark them **Passed** without running them. Fix errors caused by the work, rerun failing checks, and note unresolved environment blockers.

## Files to maintain

- `PRD.md`: product requirements (do not silently rewrite approved scope).
- `AGENTS.md`: durable agent constraints.
- `MASTER_PROMPT.md`: execution brief for an autonomous run.
- `PROGRESS.md`: create/update after each phase with Completed, Current, Next, Blockers, Tests.
- `README.md`: prerequisites, setup, commands, and usage.
- `docs/IMPLEMENTATION.md`: verified implementation choices and evidence pointers.
- `docs/TESTING.md`: test cases with actual outcome; never fabricate results.

## Stop conditions and final report

Pause dependent actions for missing authorization, Firebase console access, unsupported SDK dependencies, or risky/destructive operations. Ask a focused question identifying the precise blocker. Otherwise continue the next safe phase.

Final response must report: finished P0 items, actual command/test results, APK path **if built**, remaining limitations, Firebase steps requiring user action, and documentation paths. Never describe an untested build as successful.
