library tart;

import 'ast.dart';
import 'token.dart';
import 'package:flutter/material.dart' as flt;

class EvaluationError implements Exception {
  final String message;
  EvaluationError(this.message);
  @override
  String toString() => 'EvaluationError: $message';
}

class Environment {
  final Environment? enclosing;
  final Map<String, dynamic> values = {};

  Environment([this.enclosing]);

  void define(String name, dynamic value) {
    values[name] = value;
  }

  dynamic get(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme];
    }
    if (enclosing != null) return enclosing!.get(name);
    throw EvaluationError("Undefined variable '${name.lexeme}'.");
  }

  dynamic getValue(String name) {
    if (values.containsKey(name)) {
      return values[name];
    }
    if (enclosing != null) return enclosing!.getValue(name);
    throw EvaluationError("Undefined variable '$name'.");
  }

  void assign(Token name, dynamic value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }
    if (enclosing != null) {
      enclosing!.assign(name, value);
      return;
    }
    throw EvaluationError("Undefined variable '${name.lexeme}'.");
  }
}

class Evaluator {
  final Environment globals = Environment();
  late Environment environment;

  Evaluator() {
    environment = Environment(globals);
    // ignore: avoid_print
    defineGlobalFunction('print', (List<dynamic> args) => print(args.first));
  }

  dynamic evaluate(List<AstNode> nodes) {
    dynamic result;
    for (var node in nodes) {
      result = evaluateNode(node);
    }
    return result;
  }

  dynamic evaluateNode(AstNode node) {
    return switch (node) {
      VariableDeclaration() => _evaluateVariableDeclaration(node),
      FunctionDeclaration() => _evaluateFunctionDeclaration(node),
      ExpressionStatement() => evaluateNode(node.expression),
      IfStatement() => _evaluateIfStatement(node),
      WhileStatement() => _evaluateWhileStatement(node),
      ForStatement() => _evaluateForStatement(node),
      ReturnStatement() => _evaluateReturnStatement(node),
      Block() => _evaluateBlock(node),
      BinaryExpression() => _evaluateBinaryExpression(node),
      UnaryExpression() => _evaluateUnaryExpression(node),
      CallExpression() => _evaluateCallExpression(node),
      Literal() => node.value,
      Variable() => environment.get(node.name),
      Assignment() => _evaluateAssignment(node),
      AstWidget() => _evaluateWidget(node),
      EndOfFile() => null,
      _ => throw EvaluationError('Unknown node type: ${node.runtimeType}'),
    };
  }

  dynamic _evaluateVariableDeclaration(VariableDeclaration node) {
    dynamic value =
        node.initializer != null ? evaluateNode(node.initializer!) : null;
    environment.define(node.name.lexeme, value);
    return value;
  }

  dynamic _evaluateFunctionDeclaration(FunctionDeclaration node) {
    environment.define(node.name.lexeme, node);
    return node;
  }

  dynamic _evaluateIfStatement(IfStatement node) {
    if (_isTruthy(evaluateNode(node.condition))) {
      return evaluateNode(node.thenBranch);
    } else if (node.elseBranch != null) {
      return evaluateNode(node.elseBranch!);
    }
    return null;
  }

  dynamic _evaluateWhileStatement(WhileStatement node) {
    while (_isTruthy(evaluateNode(node.condition))) {
      evaluateNode(node.body);
    }
    return null;
  }

  dynamic _evaluateForStatement(ForStatement node) {
    Environment previousEnv = environment;
    environment = Environment(environment);

    try {
      if (node.initializer != null) {
        evaluateNode(node.initializer!);
      }
      while (
          node.condition == null || _isTruthy(evaluateNode(node.condition!))) {
        evaluateNode(node.body);
        if (node.increment != null) {
          evaluateNode(node.increment!);
        }
      }
    } finally {
      environment = previousEnv;
    }
    return null;
  }

  dynamic _evaluateReturnStatement(ReturnStatement node) {
    dynamic value = node.value != null ? evaluateNode(node.value!) : null;
    return _Return(value);
  }

  dynamic _evaluateBlock(Block node) {
    Environment previousEnv = environment;
    environment = Environment(environment);

    dynamic value;
    for (var statement in node.statements) {
      value = evaluateNode(statement);
    }
    environment = previousEnv;
    return value;
  }

  dynamic _evaluateBinaryExpression(BinaryExpression node) {
    dynamic left = evaluateNode(node.left);
    dynamic right = evaluateNode(node.right);

    return switch (node.operator.type) {
      TokenType.plus => left + right,
      TokenType.minus => left - right,
      TokenType.multiply => left * right,
      TokenType.divide => left / right,
      TokenType.equal => left == right,
      TokenType.notEqual => left != right,
      TokenType.less => left < right,
      TokenType.lessEqual => left <= right,
      TokenType.greater => left > right,
      TokenType.greaterEqual => left >= right,
      TokenType.and => _isTruthy(left) && _isTruthy(right),
      TokenType.or => _isTruthy(left) || _isTruthy(right),
      _ => throw EvaluationError(
          'Unknown binary operator: ${node.operator.lexeme}'),
    };
  }

  dynamic _evaluateUnaryExpression(UnaryExpression node) {
    dynamic right = evaluateNode(node.right);

    return switch (node.operator.type) {
      TokenType.minus => -right,
      TokenType.not => !_isTruthy(right),
      _ => throw EvaluationError(
          'Unknown unary operator: ${node.operator.lexeme}'),
    };
  }

  dynamic _evaluateCallExpression(CallExpression node) {
    dynamic callee = evaluateNode(node.callee);

    List<dynamic> arguments =
        node.arguments.map((arg) => evaluateNode(arg)).toList();

    if (callee is FunctionDeclaration) {
      return _callFunction(callee, arguments);
    } else if (callee is Function) {
      return callee(arguments);
    }

    throw EvaluationError('Can only call functions and methods.');
  }

  dynamic _evaluateAssignment(Assignment node) {
    dynamic value = evaluateNode(node.value);
    environment.assign(node.name, value);
    return value;
  }

  flt.Widget _evaluateWidget(AstWidget node) {
    return switch (node) {
      Text(text: var text) => flt.Text(text),
      Column(
        children: var children,
        mainAxisAlignment: var mainAxisAlignment,
        crossAxisAlignment: var crossAxisAlignment
      ) =>
        flt.Column(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: children.map((child) => _evaluateWidget(child)).toList(),
        ),
      Row(
        children: var children,
        mainAxisAlignment: var mainAxisAlignment,
        crossAxisAlignment: var crossAxisAlignment
      ) =>
        flt.Row(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: children.map((child) => _evaluateWidget(child)).toList(),
        ),
      Container(child: var child) =>
        flt.Container(child: _evaluateWidget(child)),
      Image(url: var url) => flt.Image.network(url),
      Padding(padding: var padding, child: var child) => flt.Padding(
          padding: _convertEdgeInsets(padding),
          child: _evaluateWidget(child),
        ),
      Center(child: var child) => flt.Center(child: _evaluateWidget(child)),
      SizedBox(width: var width, height: var height, child: var child) =>
        flt.SizedBox(
          width: width,
          height: height,
          child: child != null ? _evaluateWidget(child) : null,
        ),
      Expanded(child: var child, flex: var flex) => flt.Expanded(
          flex: flex,
          child: _evaluateWidget(child),
        ),
      ElevatedButton(child: var child, onPressed: var onPressed) =>
        flt.ElevatedButton(
          onPressed: () => evaluateNode(onPressed),
          child: _evaluateWidget(child),
        ),
    };
  }

  dynamic _callFunction(
      FunctionDeclaration declaration, List<dynamic> arguments) {
    Environment previousEnv = environment;
    environment = Environment(globals);

    for (int i = 0; i < declaration.parameters.length; i++) {
      environment.define(declaration.parameters[i].lexeme, arguments[i]);
    }

    final value = evaluateNode(declaration.body);
    environment = previousEnv;
    return value;
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return true;
  }

  dynamic callFunction(String functionName, List<dynamic> arguments) {
    var function = environment.getValue(functionName);
    if (function is FunctionDeclaration) {
      return _callFunction(function, arguments);
    } else if (function is Function) {
      return function(arguments);
    }
    throw EvaluationError(
        "Function '$functionName' not found or not callable.");
  }

  void defineGlobalFunction(String name, Function function) {
    globals.define(name, function);
  }

  void defineGlobalVariable(String name, dynamic value) {
    globals.define(name, value);
  }

  dynamic getGlobalVariable(String name) {
    return globals.getValue(name);
  }

  flt.EdgeInsets _convertEdgeInsets(EdgeInsets padding) {
    return flt.EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      padding.bottom,
    );
  }

  flt.CrossAxisAlignment _convertCrossAxisAlignment(
      CrossAxisAlignment? crossAxisAlignment) {
    return switch (crossAxisAlignment) {
      CrossAxisAlignmentStart() => flt.CrossAxisAlignment.start,
      CrossAxisAlignmentCenter() => flt.CrossAxisAlignment.center,
      CrossAxisAlignmentEnd() => flt.CrossAxisAlignment.end,
      CrossAxisAlignmentStretch() => flt.CrossAxisAlignment.stretch,
      CrossAxisAlignmentBaseline() => flt.CrossAxisAlignment.baseline,
      _ => flt.CrossAxisAlignment.start,
    };
  }

  flt.MainAxisAlignment _convertMainAxisAlignment(
      MainAxisAlignment? mainAxisAlignment) {
    return switch (mainAxisAlignment) {
      MainAxisAlignmentStart() => flt.MainAxisAlignment.start,
      MainAxisAlignmentCenter() => flt.MainAxisAlignment.center,
      MainAxisAlignmentEnd() => flt.MainAxisAlignment.end,
      MainAxisAlignmentSpaceBetween() => flt.MainAxisAlignment.spaceBetween,
      MainAxisAlignmentSpaceAround() => flt.MainAxisAlignment.spaceAround,
      MainAxisAlignmentSpaceEvenly() => flt.MainAxisAlignment.spaceEvenly,
      _ => flt.MainAxisAlignment.start,
    };
  }
}

class _Return {
  final dynamic value;
  _Return(this.value);
}
