import 'package:flutter_test/flutter_test.dart';
import 'package:eventtt_app/main.dart';

void main() {
  testWidgets('VenueVibeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VenueVibeApp());
    expect(find.text('Venue'), findsWidgets);
  });
}
