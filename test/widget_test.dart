import 'package:flutter_test/flutter_test.dart';
import 'package:mediahubs/main.dart';

void main() {
  testWidgets('Home presents MediaHub and cloud setup status', (tester) async {
    await tester.pumpWidget(const MediaHubApp());

    expect(find.text('MediaHub'), findsOneWidget);
    expect(find.text('Open Library'), findsOneWidget);
    expect(find.text('Cloud library not configured'), findsOneWidget);
  });

  testWidgets('Library lists bundled tracks and explains missing video', (
    tester,
  ) async {
    await tester.pumpWidget(const MediaHubApp());
    await tester.tap(find.text('Open Library'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon Tang'), findsOneWidget);
    expect(find.text('Open asset video player'), findsOneWidget);
    expect(find.text('Play network audio'), findsOneWidget);
  });
}
