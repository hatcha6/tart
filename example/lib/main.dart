import 'package:example/examples/calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tart_dev/tart.dart';

import 'examples/dynamic_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TartProvider(
      tart: Tart(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> readTartSource(String fileName) async {
    final contents = rootBundle.loadString(fileName);
    return contents;
  }

  Future<void> navigateToExmaple(BuildContext context, String exampleName,
      [Map<String, dynamic>? evironment]) async {
    final exampleSource = await readTartSource('screens/$exampleName.tart');
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TartStatefulWidget(
            source: exampleSource,
            environment: evironment,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Counter'),
            subtitle: const Text('Simple counter'),
            onTap: () => navigateToExmaple(context, 'counter', {'counter': 0}),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calculator'),
            subtitle: const Text('Simple calculator'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Calculator(),
              ),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Advanced Search View'),
              subtitle: const Text(
                'Search view with dynamic widget for item types',
              ),
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DynamicListView(),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
