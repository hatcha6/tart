import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart';

void main() {
  late Tart interpreter;

  setUp(() {
    interpreter = Tart();
  });

  testWidgets('Tart can render Flutter widgets', (WidgetTester tester) async {
    // Define a simple Tart script that creates a Text widget
    const String tartScript =
        '''return flutter::Text(text: 'Hello from Tart!');''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

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

  testWidgets('Tart can render nested Flutter widgets',
      (WidgetTester tester) async {
    // Define a simple Tart script that creates a Text widget
    const String tartScript =
        '''return flutter::SizedBox(width: 100, height: 100, child: flutter::Center(child:flutter::Container(child: flutter::Text(text: 'Hello from Tart!'))));''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: widget,
          ),
        ),
      ),
    );

    // Verify that the Text widget is rendered
    expect(find.text('Hello from Tart!'), findsOneWidget);
  });

  testWidgets('Tart can render a button', (WidgetTester tester) async {
    interpreter.defineGlobalVariable('x', 0);
    const String tartScript = '''
return flutter::ElevatedButton(onPressed: () { x += 1; print('Button pressed!'); }, child: flutter::Text(text: 'Press me'));''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    expect(find.text('Press me'), findsOneWidget);

    await tester.tap(find.text('Press me'));
    await tester.pumpAndSettle();

    expect(interpreter.getGlobalVariable('x'), equals(1));
  });
}
