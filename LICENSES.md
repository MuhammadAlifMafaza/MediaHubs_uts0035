# License and asset register

This file records the licensing information available in this repository. It does not grant rights to any third-party material.

## Project source

No project-level `LICENSE` file is present. The reuse and redistribution terms for MediaHub's original source code have not been specified. Do not interpret this project as open source until its owner selects and adds a project license.

## Bundled media and artwork

| File or group | Material | Rights status in this repository |
|---|---|---|
| `assets/video/rude_mv.mp4` | Hearts2Hearts music video | Copyright and redistribution permission are not documented. Do not redistribute the MP4 or an APK containing it until permission is confirmed. |
| `assets/music/*.mp3` | Hearts2Hearts tracks | Copyright and redistribution permission are not documented. Do not redistribute these tracks until permission is confirmed. |
| `assets/images/profile.jpeg` | Profile photograph | Creator, source, and redistribution terms are not documented. |
| `assets/images/logo/*` and Android launcher/splash images | MediaHub branding artwork | Creator and reuse terms are not documented in this repository. |

The app's Firestore stores media metadata and URLs only. It does not upload these bundled files.

## Software dependencies

The exact resolved versions are recorded in `pubspec.lock`. Flutter/Dart and each direct or development package retain their own license terms; check the license distributed with each package before redistribution. Packages used by this project include:

- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `just_audio`, `video_player`, `youtube_player_flutter`
- `photo_manager`, `url_launcher`, `font_awesome_flutter`, `cupertino_icons`
- `flutter_test`, `flutter_lints`

This register is not a substitute for package notices required by a release build. No permission to redistribute copyrighted music, video, photographs, or logos is implied here.
