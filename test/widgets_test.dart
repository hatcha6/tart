import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart';

void main() {
  testWidgets('Tart can render Flutter widgets', (WidgetTester tester) async {
    // Define a simple Tart script that creates a Text widget
    const String tartScript =
        '''return flutter::Text(text: 'Hello from Tart!');''';

    // Create a Tart interpreter and evaluate the script
    final interpreter = Tart();
    final widget = interpreter.run(tartScript) as Widget;

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    // Verify that the Text widget is rendered
    expect(find.text('Hello from Tart!'), findsOneWidget);
  });
}
