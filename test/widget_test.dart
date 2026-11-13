import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/main.dart';

void main() {
  testWidgets('Home presents MediaHub and cloud setup status', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MediaHub'), findsOneWidget);
    expect(find.text('Open Library'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cloud library not configured'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cloud library not configured'), findsOneWidget);
  });

  testWidgets('Library lists bundled tracks and video', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Library'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon Tang'), findsOneWidget);
    expect(find.text('Play network audio'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('RUDE! MV'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('RUDE! MV'), findsOneWidget);
  });
}
