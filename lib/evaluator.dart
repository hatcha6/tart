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

class BreakException implements Exception {}

class Evaluator {
  final Environment _globals = Environment();
  late Environment _environment;

  Evaluator() {
    _environment = Environment(_globals);
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
      Variable() => _environment.get(node.name),
      Assignment() => _evaluateAssignment(node),
      AstWidget() => _evaluateWidget(node),
      EndOfFile() => null,
      AnonymousFunction() => _evaluateAnonymousFunction(node),
      LengthAccess() => _evaluateLengthAccess(node),
      IndexAccess() => _evaluateIndexAccess(node),
      MemberAccess() => _evaluateMemberAccess(node),
      ListLiteral() => _evaluateListLiteral(node),
      BreakStatement() => throw BreakException(),
      _ => throw EvaluationError('Unknown node type: ${node.runtimeType}'),
    };
  }

  dynamic _evaluateVariableDeclaration(VariableDeclaration node) {
    dynamic value =
        node.initializer != null ? evaluateNode(node.initializer!) : null;
    _environment.define(node.name.lexeme, value);
    return value;
  }

  dynamic _evaluateFunctionDeclaration(FunctionDeclaration node) {
    _environment.define(node.name.lexeme, node);
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
    try {
      while (_isTruthy(evaluateNode(node.condition))) {
        try {
          evaluateNode(node.body);
        } on BreakException {
          break;
        }
      }
    } on BreakException {
      // Ignore break at the loop level
    }
    return null;
  }

  dynamic _evaluateForStatement(ForStatement node) {
    Environment previousEnv = _environment;
    _environment = Environment(_environment);

    try {
      if (node.initializer != null) {
        evaluateNode(node.initializer!);
      }
      while (
          node.condition == null || _isTruthy(evaluateNode(node.condition!))) {
        try {
          evaluateNode(node.body);
          if (node.increment != null) {
            evaluateNode(node.increment!);
          }
        } on BreakException {
          break;
        }
      }
    } on BreakException {
      // Ignore break at the loop level
    } finally {
      _environment = previousEnv;
    }
    return null;
  }

  dynamic _evaluateReturnStatement(ReturnStatement node) {
    dynamic value = node.value != null ? evaluateNode(node.value!) : null;
    return value;
  }

  dynamic _evaluateBlock(Block node) {
    Environment previousEnv = _environment;
    _environment = Environment(_environment);

    dynamic value;
    for (var statement in node.statements) {
      value = evaluateNode(statement);
    }
    _environment = previousEnv;
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
      return callFunctionDeclaration(callee, arguments);
    } else if (callee is Function) {
      return callee(arguments);
    }

    throw EvaluationError('Can only call functions and methods.');
  }

  dynamic _evaluateAssignment(Assignment node) {
    dynamic value = evaluateNode(node.value);
    _environment.assign(node.name, value);
    return value;
  }

  flt.Widget _evaluateWidget(AstWidget node) {
    return switch (node) {
      Text(text: final text) => flt.Text(text),
      Column(
        children: final children,
        mainAxisAlignment: final mainAxisAlignment,
        crossAxisAlignment: final crossAxisAlignment
      ) =>
        flt.Column(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: children.map((child) => _evaluateWidget(child)).toList(),
        ),
      Row(
        children: final children,
        mainAxisAlignment: final mainAxisAlignment,
        crossAxisAlignment: final crossAxisAlignment
      ) =>
        flt.Row(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: children.map((child) => _evaluateWidget(child)).toList(),
        ),
      Container(child: final child) =>
        flt.Container(child: _evaluateWidget(child)),
      Image(url: final url) => flt.Image.network(url),
      Padding(padding: final padding, child: final child) => flt.Padding(
          padding: _convertEdgeInsets(padding),
          child: _evaluateWidget(child),
        ),
      Center(child: final child) => flt.Center(child: _evaluateWidget(child)),
      SizedBox(width: final width, height: final height, child: final child) =>
        flt.SizedBox(
          width: width,
          height: height,
          child: child != null ? _evaluateWidget(child) : null,
        ),
      Expanded(child: final child, flex: final flex) => flt.Expanded(
          flex: flex,
          child: _evaluateWidget(child),
        ),
      ElevatedButton(child: final child, onPressed: final onPressed) =>
        flt.ElevatedButton(
          onPressed: () {
            if (onPressed is AnonymousFunction) {
              callFunctionDeclaration(onPressed, onPressed.parameters);
            } else {
              callFunctionDeclaration(onPressed, onPressed.parameters);
            }
          },
          child: _evaluateWidget(child),
        ),
    };
  }

  dynamic _evaluateAnonymousFunction(AnonymousFunction node) {
    return node;
  }

  dynamic callFunctionDeclaration(
      FunctionDeclaration declaration, List<dynamic> arguments) {
    Environment previousEnv = _environment;
    _environment = Environment(_globals);

    for (int i = 0; i < declaration.parameters.length; i++) {
      _environment.define(declaration.parameters[i].lexeme, arguments[i]);
    }

    final value = evaluateNode(declaration.body);
    _environment = previousEnv;
    return value;
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return true;
  }

  dynamic callFunction(String functionName, List arguments) {
    final function = _environment.getValue(functionName);
    if (function is FunctionDeclaration) {
      return callFunctionDeclaration(function, arguments);
    } else if (function is Function) {
      return function(arguments);
    }
    throw EvaluationError(
        "Function '$functionName' not found or not callable.");
  }

  void defineGlobalFunction(String name, Function function) {
    _globals.define(name, function);
  }

  void defineGlobalVariable(String name, dynamic value) {
    _globals.define(name, value);
  }

  dynamic getGlobalVariable(String name) {
    return _globals.getValue(name);
  }

  dynamic getVariable(String name) {
    return _environment.getValue(name);
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

  dynamic _evaluateLengthAccess(LengthAccess node) {
    dynamic object = evaluateNode(node.object);
    if (object is String) {
      return object.length;
    } else if (object is List) {
      return object.length;
    } else if (object is Map) {
      return object.length;
    } else {
      throw EvaluationError('Cannot get length of ${object.runtimeType}');
    }
  }

  dynamic _evaluateIndexAccess(IndexAccess node) {
    dynamic object = evaluateNode(node.object);
    dynamic index = evaluateNode(node.index);

    if (object is List) {
      if (index is! int) {
        throw EvaluationError('List index must be an integer');
      }
      if (index < 0 || index >= object.length) {
        throw EvaluationError('List index out of range');
      }
      return object[index];
    } else if (object is Map) {
      return object[index];
    } else {
      throw EvaluationError('Cannot use index access on ${object.runtimeType}');
    }
  }

  dynamic _evaluateMemberAccess(MemberAccess node) {
    dynamic object = evaluateNode(node.object);
    String memberName = node.name.lexeme;

    if (object is Map) {
      if (object.containsKey(memberName)) {
        return object[memberName];
      }
    }

    // For custom objects or classes, you might need to implement a more sophisticated
    // method to access properties or methods. This is a basic implementation.
    if (object != null) {
      try {
        return (object as dynamic)[memberName];
      } catch (e) {
        throw EvaluationError(
          "No $memberName method or property of ${object.runtimeType}",
        );
      }
    }

    throw EvaluationError(
        'Cannot access member $memberName on ${object.runtimeType}');
  }

  dynamic _evaluateListLiteral(ListLiteral node) {
    return node.elements.map((element) => evaluateNode(element)).toList();
  }
}
