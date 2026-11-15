import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/main.dart';
import 'package:mediahub/player/youtube_player_screen.dart';
import 'package:mediahub/media/media_catalog.dart';
import 'package:mediahub/media/media_item.dart';

void main() {
  testWidgets('Home presents MediaHub and cloud setup status', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
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
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon Tang'), findsOneWidget);
    expect(find.text('Network audio'), findsOneWidget);
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();
    expect(find.text('RUDE! MV'), findsOneWidget);
    expect(find.text('Featured YouTube video'), findsOneWidget);
  });

  testWidgets('Profile contains creator details', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
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

  test('Bundled video catalogue references an actual ASCII asset', () {
    final video = demoMediaItems.singleWhere(
      (item) => item.type == MediaType.video,
    );
    expect(video.mediaUrl, 'assets/video/rude_mv.mp4');
  });
}
