import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/main.dart';
import 'package:mediahub/player/youtube_player_screen.dart';
import 'package:mediahub/media/media_catalog.dart';
import 'package:mediahub/media/media_item.dart';
import 'package:mediahub/media/device_media_repository.dart';
import 'package:mediahub/media/device_media_section.dart';

class _EmptyDeviceMediaRepository implements DeviceMediaRepository {
  const _EmptyDeviceMediaRepository();

  @override
  Future<DeviceMediaResult> load(MediaType type) async =>
      const DeviceMediaResult(items: []);
}

class _DeniedDeviceMediaRepository implements DeviceMediaRepository {
  const _DeniedDeviceMediaRepository();

  @override
  Future<DeviceMediaResult> load(MediaType type) async =>
      const DeviceMediaResult(items: [], permissionDenied: true);
}

void main() {
  testWidgets('Home presents MediaHub and cloud setup status', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MediaHub'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Open Library'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Open Library'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cloud library not configured'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cloud library not configured'), findsOneWidget);
  });

  testWidgets('Audio and Video have separate destinations', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon Tang'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('On this device'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('On this device'), findsOneWidget);
    expect(find.text('Network audio'), findsNothing);
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();
    expect(find.text('RUDE! MV'), findsOneWidget);
    expect(find.text('Featured YouTube video'), findsOneWidget);
  });

  testWidgets('Profile contains creator details', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Muhammad Alif Mafaza'), findsOneWidget);
    expect(find.text('23.230.0035'), findsOneWidget);
    expect(find.text('Sistem Informasi (Bisnis Digital)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byTooltip('GitHub'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byTooltip('GitHub'), findsOneWidget);
    expect(find.byTooltip('Instagram'), findsOneWidget);
    expect(find.byTooltip('LinkedIn'), findsOneWidget);
  });

  testWidgets('Cloud Library shows setup gate without Firestore access', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cloud Library'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud catalogue is not connected yet'), findsOneWidget);
    expect(find.text('Firebase setup required'), findsOneWidget);
  });

  testWidgets('YouTube entry rejects a non-YouTube URL', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use another YouTube URL'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      featuredYoutubeUrl,
    );
    await tester.enterText(
      find.byType(EditableText),
      'https://example.com/sample.mp4',
    );
    await tester.tap(find.text('Open player'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid HTTPS YouTube video URL.'), findsOneWidget);
  });

  testWidgets('Denied device media access is explained', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeviceMediaSection(
            type: MediaType.audio,
            repository: _DeniedDeviceMediaRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Media access not granted'), findsOneWidget);
  });

  test('Bundled video catalogue references its original Unicode asset', () {
    final video = demoMediaItems.singleWhere(
      (item) => item.type == MediaType.video,
    );
    expect(video.mediaUrl, "assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4");
    expect(File(video.mediaUrl).existsSync(), isTrue);
  });
}
