// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tart_dev/tart.dart' as tart;

/// Get a stable path to a test resource by scanning up to the project root.
File getProjectFile(String path) {
  var dir = Directory.current;
  return File('${dir.path}/$path');
}

void main() {
  late tart.Tart interpreter;

  setUp(() {
    interpreter = tart.Tart(
      importHandler: (filePath) => 'final text = "This variable was imported";',
      customWidgets: {
        'CustomButton': (params) => ElevatedButton(
              onPressed: () {
                print('Custom Button pressed!');
              },
              child: Text(params['text'] as String),
            ),
      },
      customIcons: {
        'IconsCustom': Icons.favorite,
      },
    );
  });

  group('Basic Widget Rendering', () {
    testWidgets('renders a simple Text widget', (WidgetTester tester) async {
      const String tartScript =
          '''return flutter::Text(text: 'Hello from Tart!');''';

      final result = interpreter.run(tartScript);

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

    testWidgets('renders nested Flutter widgets', (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

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

    testWidgets('renders a custom icon', (WidgetTester tester) async {
      const String tartScript =
          '''return flutter::Icon(icon: p:IconsCustom());''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: widget)),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('Interactive Widgets', () {
    testWidgets('renders a functional ElevatedButton',
        (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      const String tartScript = '''
return flutter::ElevatedButton(onPressed: () { x += 1; print('Button pressed!'); }, child: flutter::Text(text: 'Press me'));''';

      final result = interpreter.run(tartScript);

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

    testWidgets('updates state correctly with setState',
        (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      const String tartScript = '''
return flutter::ElevatedButton(onPressed: () { x += 1; setState(); }, child: flutter::Text(text: x.toString()));''';

      await tester.pumpWidget(
        tart.TartProvider(
          tart: interpreter,
          child: const MaterialApp(
            home: Scaffold(
              body: tart.TartStatefulWidget(
                source: tartScript,
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

    testWidgets('renders a functional TextButton', (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      const String tartScript = '''
return flutter::TextButton(onPressed: () { x += 1; print('Button pressed!'); }, child: flutter::Text(text: 'Press me'));''';

      final result = interpreter.run(tartScript);

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

    testWidgets('renders a functional OutlinedButton',
        (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      const String tartScript = '''
return flutter::OutlinedButton(onPressed: () { x += 1; print('Button pressed!'); }, child: flutter::Text(text: 'Press me'));''';

      final result = interpreter.run(tartScript);

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
  });

  group('Layout Widgets', () {
    testWidgets('renders ListView with multiple items',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::ListView(children: [
  flutter::Text(text: 'Item 1'),
  flutter::Text(text: 'Item 2'),
  flutter::Text(text: 'Item 3'),
]);''';

      final result = interpreter.run(tartScript);

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

    testWidgets('renders GridView with multiple items',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::GridView(
  children: [
    flutter::Text(text: 'Item 1'),
    flutter::Text(text: 'Item 2'),
  flutter::Text(text: 'Item 3'),
]);''';

      final result = interpreter.run(tartScript);

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

    testWidgets('renders Column with alignment properties',
        (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

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

    testWidgets('renders Row with alignment properties',
        (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

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

    testWidgets('renders Container with child', (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Container(
  child: flutter::Text(text: 'Inside Container')
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Inside Container'), findsOneWidget);
    });

    testWidgets('renders Padding with specified EdgeInsets',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Padding(
  padding: parameter::EdgeInsetsAll(value: 16.0),
  child: flutter::Text(text: 'Padded Text')
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Padded Text'), findsOneWidget);
    });

    testWidgets('renders Center widget', (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Center(
  child: flutter::Text(text: 'Centered Text')
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Centered Text'), findsOneWidget);
    });

    testWidgets('renders SizedBox with specific dimensions',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::SizedBox(
  width: 100,
  height: 50,
  child: flutter::Text(text: 'Inside SizedBox')
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Inside SizedBox'), findsOneWidget);
    });

    testWidgets('renders Expanded within a Row', (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Expanded Text'), findsOneWidget);
      expect(find.text('Normal Text'), findsOneWidget);
    });

    testWidgets('renders Stack with multiple children',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Stack(
  children: [
    flutter::Text(text: 'Left'),
    flutter::Text(text: 'Center'),
    flutter::Text(text: 'Right'),
  ]
);''';

      final result = interpreter.run(tartScript);
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
  });

  group('Complex Widgets', () {
    testWidgets('renders Card with elevation', (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Card(
  elevation: 4.0,
  child: flutter::Text(text: 'Card Content')
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('renders ListViewBuilder with dynamic items',
        (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

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

    testWidgets('renders GridViewBuilder with dynamic items',
        (WidgetTester tester) async {
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

      final result = interpreter.run(tartScript);

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

    testWidgets('renders TextField with decoration and onSubmitted callback',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::TextField(
  decoration: parameter::InputDecoration(
    labelText: 'Enter your name',
  ),
  onSubmitted: (value) {
    print('Submitted value: ' + value);
  },
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('renders ListTile with title, subtitle, and trailing',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::ListTile(
  title: flutter::Text(text: 'List Tile Title'),
  subtitle: flutter::Text(text: 'List Tile Subtitle'),
  trailing: flutter::Text(text: 'List Tile Trailing'),
);''';

      final result = interpreter.run(tartScript);

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
  });

  group('Progress Indicators', () {
    testWidgets('renders LinearProgressIndicator with custom color',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::LinearProgressIndicator(
  value: 0.5,
  color: parameter::Color(r: 255, g: 0, b: 0),
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator with custom value',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::CircularProgressIndicator(
  value: 0.5,
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Custom and Advanced Features', () {
    testWidgets('renders custom widget (CustomButton)',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::CustomButton(text: 'Custom Button');''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Custom Button'), findsOneWidget);
    });

    testWidgets('imports and uses variables from other files',
        (WidgetTester tester) async {
      const String tartScript = '''
import 'imported.tart';
return flutter::Text(text: text);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('This variable was imported'), findsOneWidget);
    });

    testWidgets('handles large widget trees efficiently',
        (WidgetTester tester) async {
      final file = getProjectFile('assets/large_test.tart');
      final tartScript = file.readAsStringSync();

      await tester.pumpWidget(
        tart.TartProvider(
          tart: interpreter,
          child: MaterialApp(
            home: Scaffold(
              body: tart.TartStatefulWidget(
                source: tartScript,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Custom Large Button'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders multiple TartStatefulWidgets',
        (WidgetTester tester) async {
      const String tartScript = '''
return flutter::Row(children: [
  flutter::Text(text: 'Hello'),
  flutter::Text(text: 'World' + x.toString()),
  flutter::TextButton(onPressed: () { x += 1; setState(); }, child: flutter::Text(text: 'Press me' + index.toString())),
]);''';

      await tester.pumpWidget(
        tart.TartProvider(
          tart: interpreter,
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  SizedBox(
                    height: 500,
                    child: tart.TartStatefulWidget(
                      environment: {
                        'index': 1,
                        'x': 0,
                      },
                      source: tartScript,
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: tart.TartStatefulWidget(
                      environment: {'index': 2, 'x': 0},
                      source: tartScript,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsAtLeast(2));
      expect(find.text('World0'), findsAtLeast(2));

      await tester.tap(find.text('Press me1'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsAtLeast(2));
      expect(find.text('World1'), findsOneWidget);
      expect(find.text('World0'), findsOneWidget);
    });

    testWidgets('renders Flutter widgets passed as environment variables',
        (WidgetTester tester) async {
      final env = interpreter.createIsolatedEnvironment();
      interpreter.setCurrentEnvironment(env);
      const flutterWidget = Text('Hello from flutter');
      interpreter.defineEnvironmentVariable('flutterWidget', flutterWidget,
          environmentId: env);
      const String tartScript = '''
return flutterWidget;''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Hello from flutter'), findsOneWidget);
      interpreter.removeEnvironment(env);
    });

    testWidgets('renders and updates StatefulBuilder',
        (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      const String tartScript = '''
return flutter::StatefulBuilder(
  builder: (setState) {
    return flutter::ElevatedButton(onPressed: () { x += 1; setState(); }, child: flutter::Text(text: 'Press me' + x.toString()));
  },
);''';

      final result = interpreter.run(tartScript);

      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Press me0'), findsOneWidget);

      await tester.tap(find.text('Press me0'));
      await tester.pumpAndSettle();

      expect(find.text('Press me1'), findsOneWidget);
    });

    testWidgets('renders multiple StatefulBuilders independently',
        (WidgetTester tester) async {
      interpreter.defineGlobalVariable('x', 0);
      interpreter.defineGlobalVariable('y', 0);
      const String tartScript = '''
return f:Column(
  children: [
flutter::StatefulBuilder(
  builder: (setState) {
    return flutter::ElevatedButton(onPressed: () { x += 1; setState(); }, child: flutter::Text(text: 'Press mex' + x.toString()));
  },
),flutter::StatefulBuilder(
  builder: (setState) {
    return flutter::ElevatedButton(onPressed: () { y += 1; setState(); }, child: flutter::Text(text: 'Press mey' + y.toString()));
  },
)
  ]
);''';

      final result = interpreter.run(tartScript);
      final widget = result as Widget;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Press mex0'), findsOneWidget);
      expect(find.text('Press mey0'), findsOneWidget);
      await tester.tap(find.text('Press mey0'));
      await tester.pumpAndSettle();

      expect(find.text('Press mey1'), findsOneWidget);
      expect(find.text('Press mex0'), findsOneWidget);
      await tester.tap(find.text('Press mex0'));
      await tester.pumpAndSettle();
      expect(find.text('Press mex1'), findsOneWidget);
    });
  });
}
