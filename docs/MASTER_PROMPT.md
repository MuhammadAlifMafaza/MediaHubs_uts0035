# MASTER PROMPT — Build MediaHub Android with OpenCode

Copy the text from **BEGIN PROMPT** through **END PROMPT** into an OpenCode coding-agent session from the MediaHub project root. Place `PRD.md`, `AGENTS.md`, and this file in that directory first.

## BEGIN PROMPT

You are the primary senior Flutter/Android engineer responsible for implementing **MediaHub** for the UTS course project.

### Mandatory context

Read the ENTIRE local `PRD.md` and `AGENTS.md` before modifying files. Treat the PRD acceptance criteria as the build target and follow the safety, verification, and documentation rules in AGENTS.md. Inspect the current folder and `git status`; determine whether a Flutter project already exists before creating one. Preserve existing work.

### Fixed scope

- **Android only**; iOS is postponed.
- Flutter project: `mediahub`; display name: `MediaHub`.
- Application ID: `com.mediahubs.uts0035`.
- Firebase project: `mediahubs-bbf06`.
- Main database: Cloud Firestore.
- Required multimedia: `just_audio` for network audio and `video_player` for bundled video assets.
- Build **all P0 requirements**. P1/P2 are out of scope unless explicitly requested later.

### Working mode

Operate autonomously through routine engineering work. Inspect, edit, run commands, review diagnostics, and iterate. Do not stop after generating boilerplate or planning. Use sequential milestones with checkpoints in `PROGRESS.md`. When an external decision or credential is required, document the exact blocker, continue independent tasks, and ask the user only when further dependent work genuinely cannot proceed.

Do **not** use speculative model IDs, assume extra agents exist, or invent provider routing: use the model selected by the current OpenCode session. A second-model review is optional and must be explicitly supported and actually performed before claiming it.

### Execution plan

**Phase 0 — Inspect prerequisites**

1. Detect Flutter/Dart/Android SDK versions and emulator/device availability using `flutter doctor`, `flutter --version`, `flutter devices` as appropriate.
2. Inspect the project tree, Flutter files, Git state, assets, and existing Firebase setup.
3. Identify whether the Firebase JSON exists. If the filename is `google-services(1).json`, carefully copy it to Android's expected `google-services.json` path when initializing. Do not print keys or IDs unrelated to the setup.
4. Identify what cannot be verified from the Firebase Console: existing database, collection, security rules, Authentication.
5. Record the initial status and dependencies in `PROGRESS.md`.

**Phase 1 — Flutter application skeleton**

1. If there is no project, create Android-only Flutter project; otherwise adapt the existing project without overwriting unrelated work.
2. Set package identity to `com.mediahubs.uts0035` and display name to MediaHub.
3. Build the app shell and navigation: Home, Library, Media Detail, Add/Edit Form, Audio Player, Video Player.
4. Add shared UI theme with MediaHub's blue/green branding. Use an existing logo if supplied; otherwise use a simple placeholder and explicitly record it.
5. Add Android-compatible dependencies with verified versions and reasonable architecture (model, repository, screens, service).
6. Format, analyze, and fix issues.

**Phase 2 — Firebase and Firestore**

1. Configure Firebase initialization using the installed compatible FlutterFire approach.
2. Verify that the Android package matches the provided Firebase app configuration.
3. Determine the safest practical authorization model from actual Firestore/Auth configuration. Prefer per-user authenticated rules. Do not write unrestricted rules.
4. If Firestore/Auth remote settings cannot be inspected, implement an adaptable repository interface and document required console steps; **do not claim live CRUD passed**.
5. Implement the agreed media metadata schema: `title`, `creator`, `type`, `description`, `category`, `sourceType`, `mediaUrl`, `thumbnailUrl`, timestamps.
6. Implement realtime read, create, update, delete with exception handling and validation.

**Phase 3 — CRUD UI**

1. Connect Library to Firestore with loading, empty, populated, and error states.
2. Implement Add/Edit screen, including validation and disabled/loading submit state.
3. Implement Media Detail and a deletion confirmation dialog.
4. Verify create → read → update → delete against actual Firebase if access is available; otherwise provide reproducible manual steps and mark not run.

**Phase 4 — Audio playback**

1. Implement direct audio URL playback using `just_audio`.
2. Provide play/pause, loading and error status, elapsed/total time and seeking when supported.
3. Dispose the player correctly.
4. Use a working, legally accessible test URL if available. If not, provide a user-replaceable sample configuration and mark playback verification as blocked/not run.

**Phase 5 — Offline asset video**

1. Use an existing suitable MP4 asset if provided; otherwise clearly flag that a real sample video must be supplied. Do not invent media files and claim they were tested.
2. Register media in `pubspec.yaml`.
3. Implement video loading/play/pause/progress using `VideoPlayerController.asset` with proper lifecycle and error handling.
4. Ensure the video playback does not require an internet connection.

**Phase 6 — Integrate and validate**

1. Wire Home → Library → Details → CRUD/Player. Keep UI responsive on Android phones.
2. Run checks: `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, and `flutter build apk --debug` when the environment allows.
3. Fix implementation failures; re-run relevant commands.
4. Do not delete build artifacts, rewrite config, or alter user files outside project scope without checking.

**Phase 7 — Deliver UTS documentation**

1. Create/update `README.md` with setup, Firebase prerequisites, build/run, and demo steps.
2. Create/update `docs/IMPLEMENTATION.md` including key files, data paths, architecture, completed features, limitations, and documentation screenshot checklist.
3. Create/update `docs/TESTING.md` with all PRD test cases, actual Pass/Fail/Blocked/Not Run status, commands, logs summary, and Android device/version if known.
4. Maintain `PROGRESS.md` reflecting completed work, remaining blockers, next tasks, and verification.

### Quality gates

For a phase to be marked complete, its files must exist, relevant validation must have run, and the outcome must be recorded. Do not claim that code compiles or media plays unless verified. Do not state that Firebase is connected merely because `google-services.json` exists. Do not mark tests as Pass without actual execution. If a remote Firebase configuration is needed, surface precise manual setup instructions.

### Final response format

Report in Indonesian:

1. Status hasil implementasi P0 (completed vs blocked).
2. Project structure and noteworthy files.
3. `flutter analyze`, `flutter test`, `flutter build apk --debug` results (real outcomes only).
4. APK path if it was actually generated.
5. Firebase Console actions still needed from user.
6. Known issues and recommended next step.

Start now. Read `PRD.md` and `AGENTS.md` fully, inspect the workspace, and implement the Android MVP as far as permissions and available tools safely permit. Keep going across phases without additional prompting for routine tasks.

## END PROMPT

---

## Quick start

1. Put `PRD.md`, `AGENTS.md`, and `MASTER_PROMPT.md` in the MediaHub repository root.
2. Open the folder with OpenCode, select one of your configured coding-capable models (GPT, Claude, Gemini, etc.).
3. Paste the content inside the prompt delimiters. Alternatively tell OpenCode to read `MASTER_PROMPT.md` and execute its instructions.
4. Review the agent's progress and console-specific blockers. Verify the built APK on your Android device before UTS submission.

**Reminder:** one prompt launches one autonomous workflow; it does not guarantee Firebase setup, device testing, or multi-model collaboration without configured tools and user access.
