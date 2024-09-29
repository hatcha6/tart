// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart' as tart;

void main() {
  late tart.Tart interpreter;

  setUp(() {
    interpreter = tart.Tart(
      importHandler: (filePath) => 'final text = "This variable was imported";',
    );
  });

  testWidgets('Tart can render Flutter widgets', (WidgetTester tester) async {
    const String tartScript =
        '''return flutter::Text(text: 'Hello from Tart!');''';

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

    expect(find.text('Hello from Tart!'), findsOneWidget);
  });

  testWidgets('Tart can render nested Flutter widgets',
      (WidgetTester tester) async {
    const String tartScript = '''return flutter::SizedBox(
            width: 100,
            height: 100,
            child: flutter::Center(
              child: flutter::Container(
                child: f:Text(
                  text: 'Hello from Tart!',
                  color: p:Color(r: 255, g: 255, b: 255),
                  style: parameter::TextStyle(
                    fontWeight: p:FontWeightBold(),
                  ),
                ),
              ),
            ),
          );''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: widget,
          ),
        ),
      ),
    );

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

  testWidgets('Tart can correctly run setState', (WidgetTester tester) async {
    interpreter.defineGlobalVariable('x', 0);
    const String tartScript = '''
return flutter::ElevatedButton(onPressed: () { x += 1; setState(); }, child: flutter::Text(text: toString(x)));''';

    await tester.pumpWidget(
      tart.TartProvider(
        tart: interpreter,
        child: const MaterialApp(
          home: Scaffold(
            body: tart.TartStatefulWidget(
              source: tartScript,
              printBenchmarks: true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    expect(interpreter.getGlobalVariable('x'), equals(1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Tart can render ListView', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::ListView(children: [
  flutter::Text(text: 'Item 1'),
  flutter::Text(text: 'Item 2'),
  flutter::Text(text: 'Item 3'),
]);''';

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

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('Tart can render GridView', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::GridView(
  children: [
    flutter::Text(text: 'Item 1'),
    flutter::Text(text: 'Item 2'),
  flutter::Text(text: 'Item 3'),
]);''';

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

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('Tart can render Column', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Column(
  mainAxisAlignment: parameter::MainAxisAlignmentCenter(),
  crossAxisAlignment: parameter::CrossAxisAlignmentStart(),
  children: [
    flutter::Text(text: 'Item 1'),
    flutter::Text(text: 'Item 2'),
    flutter::Text(text: 'Item 3'),
  ]
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('Tart can render Row', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Row(
  mainAxisAlignment: parameter::MainAxisAlignmentSpaceEvenly(),
  crossAxisAlignment: parameter::CrossAxisAlignmentCenter(),
  children: [
    flutter::Text(text: 'Left'),
    flutter::Text(text: 'Center'),
    flutter::Text(text: 'Right'),
  ]
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Left'), findsOneWidget);
    expect(find.text('Center'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);
  });

  testWidgets('Tart can render Container', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Container(
  child: flutter::Text(text: 'Inside Container')
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Inside Container'), findsOneWidget);
  });

// This test needs more setup to work because flutter test doesn't allow (?) http
// requests in unit tests
//   testWidgets('Tart can render Image', (WidgetTester tester) async {
//     const String tartScript = '''
// return flutter::Image(url: 'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png');''';

//     final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
//     print(benchmark);
//     final widget = result as Widget;

//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(body: widget),
//       ),
//     );

//     expect(
//         find.image(const NetworkImage(
//             'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png')),
//         findsOneWidget);
//   });

  testWidgets('Tart can render Padding', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Padding(
  padding: parameter::EdgeInsetsAll(value: 16.0),
  child: flutter::Text(text: 'Padded Text')
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Padded Text'), findsOneWidget);
  });

  testWidgets('Tart can render Center', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Center(
  child: flutter::Text(text: 'Centered Text')
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Centered Text'), findsOneWidget);
  });

  testWidgets('Tart can render SizedBox', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::SizedBox(
  width: 100,
  height: 50,
  child: flutter::Text(text: 'Inside SizedBox')
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Inside SizedBox'), findsOneWidget);
  });

  testWidgets('Tart can render Expanded', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Row(
  children: [
    flutter::Expanded(
      flex: 2,
      child: flutter::Text(text: 'Expanded Text')
    ),
    flutter::Text(text: 'Normal Text')
  ]
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Expanded Text'), findsOneWidget);
    expect(find.text('Normal Text'), findsOneWidget);
  });

  testWidgets('Tart can render Card', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::Card(
  elevation: 4.0,
  child: flutter::Text(text: 'Card Content')
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
  });

  testWidgets('Tart can render ListViewBuilder', (WidgetTester tester) async {
    interpreter.defineGlobalVariable('items', [
      'Item 0',
      'Item 1',
      'Item 2',
      'Item 3',
      'Item 4',
      'Item 5',
      'Item 6',
      'Item 7',
      'Item 8',
      'Item 9'
    ]);
    const String tartScript = '''
return flutter::ListViewBuilder(
  itemBuilder: (index) {
    return flutter::Text(text: items[index]);
  },
  itemCount: items.length,
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
  });

  testWidgets('Tart can render GridViewBuilder', (WidgetTester tester) async {
    const String tartScript = '''
final items = [
      'Item 0',
      'Item 1',
      'Item 2',
      'Item 3',
      'Item 4',
      'Item 5',
      'Item 6',
      'Item 7',
      'Item 8',
      'Item 9'
    ];
return flutter::GridViewBuilder(
  itemBuilder: (index) {
    return flutter::Text(text: items[index]);
  },
  itemCount: items.length,
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
  });

  testWidgets('Tart can import and use variables from other files',
      (WidgetTester tester) async {
    const String tartScript = '''
import 'imported.tart';
return flutter::Text(text: text);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('This variable was imported'), findsOneWidget);
  });

  testWidgets('Tart can render TextField', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::TextField(
  decoration: parameter::InputDecoration(
    labelText: 'Enter your name',
  ),
  onSubmitted: (value) {
    print('Submitted value: ' + value);
  },
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('Enter your name'), findsOneWidget);
  });

  testWidgets('Tart can render ListTile', (WidgetTester tester) async {
    const String tartScript = '''
return flutter::ListTile(
  title: flutter::Text(text: 'List Tile Title'),
  subtitle: flutter::Text(text: 'List Tile Subtitle'),
  trailing: flutter::Text(text: 'List Tile Trailing'),
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.text('List Tile Title'), findsOneWidget);
    expect(find.text('List Tile Subtitle'), findsOneWidget);
    expect(find.text('List Tile Trailing'), findsOneWidget);
  });

  testWidgets('Tart can render LinearProgressIndicator',
      (WidgetTester tester) async {
    const String tartScript = '''
return flutter::LinearProgressIndicator(
  value: 0.5,
  color: parameter::Color(r: 255, g: 0, b: 0),
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('Tart can render CircularProgressIndicator',
      (WidgetTester tester) async {
    const String tartScript = '''
return flutter::CircularProgressIndicator(
  value: 0.5,
);''';

    final (result, benchmark) = interpreter.runWithBenchmark(tartScript);
    print(benchmark);
    final widget = result as Widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
