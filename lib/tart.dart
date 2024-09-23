library tart;

export 'lexer.dart';
export 'token.dart';
export 'parser.dart';
export 'ast.dart';
export 'evaluator.dart';

import 'evaluator.dart';
import 'lexer.dart';
import 'parser.dart';

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

  void defineGlobalVariable(String name, dynamic value) =>
      evaluator.defineGlobalVariable(name, value);

  void defineGlobalFunction(String name, Function value) =>
      evaluator.defineGlobalFunction(name, value);

  dynamic getGlobalVariable(String name) => evaluator.getGlobalVariable(name);

  dynamic callFunction(String functionName, List arguments) =>
      evaluator.callFunction(functionName, arguments);
}
