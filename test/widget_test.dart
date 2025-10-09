import 'package:flutter_test/flutter_test.dart';
import 'package:test_abc/main.dart';

void main() {
  testWidgets('Step Counter app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StepCounterApp());

    // Verify that the app title is displayed
    expect(find.text('Step Counter'), findsOneWidget);
  });
}
