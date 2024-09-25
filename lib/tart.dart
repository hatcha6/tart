// ignore_for_file: avoid_print

library tart;

export 'lexer.dart';
export 'token.dart';
export 'parser.dart';
export 'ast.dart';
export 'evaluator.dart';

import 'dart:io';
import 'package:flutter/material.dart';

import 'evaluator.dart';
import 'lexer.dart';
import 'parser.dart';
import 'token.dart';
import 'ast.dart';

class BenchmarkResults {
  final double lexerTokensPerSecond;
  final double lexerTime;
  final double parserNodesPerSecond;
  final double parserTime;
  final double evaluatorTime;
  final double totalTime;
  final double memoryUsage;

  BenchmarkResults({
    required this.lexerTokensPerSecond,
    required this.lexerTime,
    required this.parserNodesPerSecond,
    required this.parserTime,
    required this.evaluatorTime,
    required this.totalTime,
    required this.memoryUsage,
  });

  @override
  String toString() {
    return '''
Tart Benchmark Results:
Lexer:
  - Tokens per second: ${lexerTokensPerSecond.toStringAsFixed(2)}
  - Time: ${lexerTime.toStringAsFixed(6)} seconds
Parser:
  - Nodes per second: ${parserNodesPerSecond.toStringAsFixed(2)}
  - Time: ${parserTime.toStringAsFixed(6)} seconds
Evaluator:
  - Time: ${evaluatorTime.toStringAsFixed(6)} seconds
Total execution time: ${totalTime.toStringAsFixed(6)} seconds
Memory Usage: ${memoryUsage.toStringAsFixed(2)} KB
''';
  }
}

class Tart {
  final Lexer _lexer = Lexer();
  final Parser _parser = Parser();
  final Evaluator evaluator;
  final Parser parser;
  final Lexer lexer;

  Tart()
      : evaluator = Evaluator(),
        parser = Parser(),
        lexer = Lexer();

  dynamic run(String source) {
    List<Token> tokens = _lexer.scanTokens(source);
    List<AstNode> ast = _parser.parse(tokens);
    return evaluator.evaluate(ast);
  }

  (dynamic, BenchmarkResults?) runWithBenchmark(String source) {
    return _runWithBenchmark(source);
  }

  Future<(dynamic, BenchmarkResults?)> runAsync(String source,
      {bool benchmark = false}) async {
    if (benchmark) {
      return _runWithBenchmarkAsync(source);
    } else {
      var tokens = await lexer.scanTokensAsync(source);
      var nodes = await parser.parseAsync(tokens);
      return (evaluator.evaluate(nodes), null);
    }
  }

  void defineGlobalVariable(String name, dynamic value) =>
      evaluator.defineGlobalVariable(name, value);

  void defineGlobalFunction(String name, Function value) =>
      evaluator.defineGlobalFunction(name, value);

  dynamic getGlobalVariable(String name) => evaluator.getGlobalVariable(name);

  dynamic callFunction(String functionName, List arguments) =>
      evaluator.callFunction(functionName, arguments);

  // New benchmarking methods
  (dynamic, BenchmarkResults) _runWithBenchmark(String source) {
    int initialMemoryUsage = _getMemoryUsage();

    Stopwatch lexerStopwatch = Stopwatch()..start();
    List<Token> tokens = _lexer.scanTokens(source);
    lexerStopwatch.stop();
    double lexerTime = lexerStopwatch.elapsedMicroseconds / 1000000;
    double tokensPerSecond = tokens.length / lexerTime;

    Stopwatch parserStopwatch = Stopwatch()..start();
    List<AstNode> nodes = _parser.parse(tokens);
    parserStopwatch.stop();
    double parserTime = parserStopwatch.elapsedMicroseconds / 1000000;
    double nodesPerSecond = nodes.length / parserTime;

    Stopwatch evaluatorStopwatch = Stopwatch()..start();
    final result = evaluator.evaluate(nodes);
    evaluatorStopwatch.stop();
    double evaluatorTime = evaluatorStopwatch.elapsedMicroseconds / 1000000;

    double totalTime = lexerTime + parserTime + evaluatorTime;

    int finalMemoryUsage = _getMemoryUsage();
    double memoryUsage = (finalMemoryUsage - initialMemoryUsage) / 1024;

    return (
      result,
      BenchmarkResults(
        lexerTokensPerSecond: tokensPerSecond,
        lexerTime: lexerTime,
        parserNodesPerSecond: nodesPerSecond,
        parserTime: parserTime,
        evaluatorTime: evaluatorTime,
        totalTime: totalTime,
        memoryUsage: memoryUsage,
      )
    );
  }

  Future<(dynamic, BenchmarkResults)> _runWithBenchmarkAsync(
      String source) async {
    int initialMemoryUsage = _getMemoryUsage();

    Stopwatch lexerStopwatch = Stopwatch()..start();
    List<Token> tokens = await _lexer.scanTokensAsync(source);
    lexerStopwatch.stop();
    double lexerTime = lexerStopwatch.elapsedMicroseconds / 1000000;
    double tokensPerSecond = tokens.length / lexerTime;

    Stopwatch parserStopwatch = Stopwatch()..start();
    List<AstNode> nodes = await _parser.parseAsync(tokens);
    parserStopwatch.stop();
    double parserTime = parserStopwatch.elapsedMicroseconds / 1000000;
    double nodesPerSecond = nodes.length / parserTime;

    Stopwatch evaluatorStopwatch = Stopwatch()..start();
    final result = evaluator.evaluate(nodes);
    evaluatorStopwatch.stop();
    double evaluatorTime = evaluatorStopwatch.elapsedMicroseconds / 1000000;

    double totalTime = lexerTime + parserTime + evaluatorTime;

    int finalMemoryUsage = _getMemoryUsage();
    double memoryUsage = (finalMemoryUsage - initialMemoryUsage) / 1024;

    return (
      result,
      BenchmarkResults(
        lexerTokensPerSecond: tokensPerSecond,
        lexerTime: lexerTime,
        parserNodesPerSecond: nodesPerSecond,
        parserTime: parserTime,
        evaluatorTime: evaluatorTime,
        totalTime: totalTime,
        memoryUsage: memoryUsage,
      )
    );
  }

  int _getMemoryUsage() {
    return ProcessInfo.currentRss;
  }
}

class TartProvider extends InheritedWidget {
  final Tart tart;

  const TartProvider({
    super.key,
    required this.tart,
    required super.child,
  });

  static Tart of(BuildContext context) {
    final TartProvider? provider =
        context.dependOnInheritedWidgetOfExactType<TartProvider>();
    assert(provider != null, 'No TartProvider found in context');
    return provider!.tart;
  }

  @override
  bool updateShouldNotify(TartProvider oldWidget) => tart != oldWidget.tart;
}

class TartStatefulWidget extends StatefulWidget {
  final Map<String, dynamic>? environment;
  final String source;
  final bool printBenchmarks;

  const TartStatefulWidget({
    super.key,
    required this.source,
    this.environment,
    this.printBenchmarks = false,
  });

  @override
  State<TartStatefulWidget> createState() => _TartStatefulWidgetState();
}

class _TartStatefulWidgetState extends State<TartStatefulWidget> {
  late Tart _tart;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tart = TartProvider.of(context);
    if (widget.environment != null) {
      widget.environment!.forEach((key, value) {
        if (value is Function) {
          _tart.defineGlobalFunction(key, value);
        } else {
          _tart.defineGlobalVariable(key, value);
        }
      });
    }
    _tart.defineGlobalFunction('setState', (List<dynamic> args) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic result;
    if (widget.printBenchmarks) {
      final (res, benchmarks) = _tart.runWithBenchmark(widget.source);
      print(benchmarks);
      result = res;
    } else {
      result = _tart.run(widget.source);
    }
    return result as Widget;
  }
}
