
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoreport_app/main.dart';

void main() {
  testWidgets('EcoReport App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoReportApp());

    // Verify that our app starts and shows the title.
    expect(find.text('EcoReport GPS'), findsOneWidget);
  });
}