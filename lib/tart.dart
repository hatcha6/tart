// ignore_for_file: avoid_print

library tart;

export 'lexer.dart';
export 'token.dart';
export 'parser.dart';
export 'ast.dart';
export 'evaluator.dart';

import 'dart:io';
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
  final Evaluator evaluator;
  final Parser parser;
  final Lexer lexer;

  Tart()
      : evaluator = Evaluator(),
        parser = Parser(),
        lexer = Lexer();

  dynamic run(String source) {
    var tokens = lexer.scanTokens(source);
    var nodes = parser.parse(tokens);
    return evaluator.evaluate(nodes);
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
    List<Token> tokens = lexer.scanTokens(source);
    lexerStopwatch.stop();
    double lexerTime = lexerStopwatch.elapsedMicroseconds / 1000000;
    double tokensPerSecond = tokens.length / lexerTime;

    Stopwatch parserStopwatch = Stopwatch()..start();
    List<AstNode> nodes = parser.parse(tokens);
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
    List<Token> tokens = await lexer.scanTokensAsync(source);
    lexerStopwatch.stop();
    double lexerTime = lexerStopwatch.elapsedMicroseconds / 1000000;
    double tokensPerSecond = tokens.length / lexerTime;

    Stopwatch parserStopwatch = Stopwatch()..start();
    List<AstNode> nodes = await parser.parseAsync(tokens);
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
