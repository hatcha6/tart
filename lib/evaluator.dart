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
  final Set<String> immutableVariables = {};

  Environment([this.enclosing]);

  void define(String name, dynamic value, String keyword) {
    values[name] = value;
    if (keyword == 'final' || keyword == 'const') {
      immutableVariables.add(name);
    }
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
    if (immutableVariables.contains(name.lexeme)) {
      throw EvaluationError(
          "Cannot reassign to final or const variable '${name.lexeme}'.");
    }
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
  bool _isGlobalScope = true;

  late final List<AstNode> Function(String filepath) _importHandler;

  Evaluator() {
    _environment = _globals;
    // ignore: avoid_print
    defineGlobalFunction('print', (List<dynamic> args) => print(args.first));
  }

  void setImportHandler(List<AstNode> Function(String filepath) importHandler) {
    _importHandler = importHandler;
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
      AnonymousFunction() => _evaluateAnonymousFunction(node),
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
      LengthAccess() => _evaluateLengthAccess(node),
      IndexAccess() => _evaluateIndexAccess(node),
      MemberAccess() => _evaluateMemberAccess(node),
      ListLiteral() => _evaluateListLiteral(node),
      BreakStatement() => throw BreakException(),
      ToString() => _evaluateToString(node),
      ImportStatement() => _evaluateImportStatement(node),
      _ => throw EvaluationError('Unknown node type: ${node.runtimeType}'),
    };
  }

  dynamic _evaluateVariableDeclaration(VariableDeclaration node) {
    dynamic value =
        node.initializer != null ? evaluateNode(node.initializer!) : null;
    if (_isGlobalScope) {
      _globals.define(node.name.lexeme, value, node.keyword.lexeme);
    } else {
      _environment.define(node.name.lexeme, value, node.keyword.lexeme);
    }
    return value;
  }

  dynamic _evaluateFunctionDeclaration(FunctionDeclaration node) {
    _environment.define(node.name.lexeme, node, 'final');
    return node;
  }

  dynamic _evaluateImportStatement(ImportStatement node) {
    List<AstNode> importedAst = _importHandler(node.path);
    return evaluate(importedAst);
  }

  dynamic _evaluateIfStatement(IfStatement node) {
    Environment previousEnv = _environment;
    _environment = Environment(_environment);
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

    try {
      if (_isTruthy(evaluateNode(node.condition))) {
        return evaluateNode(node.thenBranch);
      } else if (node.elseBranch != null) {
        return evaluateNode(node.elseBranch!);
      }
    } finally {
      _environment = previousEnv;
      _isGlobalScope = wasGlobalScope;
    }
    return null;
  }

  dynamic _evaluateWhileStatement(WhileStatement node) {
    Environment previousEnv = _environment;
    _environment = Environment(_environment);
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

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
    } finally {
      _environment = previousEnv;
      _isGlobalScope = wasGlobalScope;
    }
    return null;
  }

  dynamic _evaluateForStatement(ForStatement node) {
    Environment previousEnv = _environment;
    _environment = Environment(_environment);
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

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
      _isGlobalScope = wasGlobalScope;
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
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

    dynamic value;
    try {
      for (var statement in node.statements) {
        value = evaluateNode(statement);
      }
    } finally {
      _environment = previousEnv;
      _isGlobalScope = wasGlobalScope;
    }
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
      Text(text: final text, style: final style) => flt.Text(evaluateNode(text),
          style: style != null ? _convertTextStyle(style) : null),
      Column(
        children: final children,
        mainAxisAlignment: final mainAxisAlignment,
        crossAxisAlignment: final crossAxisAlignment
      ) =>
        flt.Column(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: _evaluateListOfWidgets(children),
        ),
      Row(
        children: final children,
        mainAxisAlignment: final mainAxisAlignment,
        crossAxisAlignment: final crossAxisAlignment
      ) =>
        flt.Row(
          mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
          crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
          children: _evaluateListOfWidgets(children),
        ),
      Container(child: final child) =>
        flt.Container(child: _evaluateWidget(child)),
      Image(url: final url) => flt.Image.network(evaluateNode(url)),
      Padding(padding: final padding, child: final child) => flt.Padding(
          padding: _convertEdgeInsets(padding),
          child: _evaluateWidget(child),
        ),
      Center(child: final child) => flt.Center(child: _evaluateWidget(child)),
      SizedBox(width: final width, height: final height, child: final child) =>
        flt.SizedBox(
          width: width != null ? evaluateNode(width).toDouble() : null,
          height: height != null ? evaluateNode(height).toDouble() : null,
          child: child != null ? _evaluateWidget(child) : null,
        ),
      Expanded(child: final child, flex: final flex) => flt.Expanded(
          flex: flex != null ? evaluateNode(flex) : null,
          child: _evaluateWidget(child),
        ),
      ElevatedButton(child: final child, onPressed: final onPressed) =>
        flt.ElevatedButton(
          onPressed: () => callFunctionDeclaration(
            onPressed,
            onPressed.parameters,
          ),
          child: _evaluateWidget(child),
        ),
      Card(child: final child, elevation: final elevation) => flt.Card(
          elevation: elevation != null ? evaluateNode(elevation) : null,
          child: _evaluateWidget(child),
        ),
      ListView(children: final children) => flt.ListView(
          children: _evaluateListOfWidgets(children),
        ),
      GridView(
        children: final children,
        maxCrossAxisExtent: final maxCrossAxisExtent
      ) =>
        flt.GridView(
          gridDelegate: flt.SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: evaluateNode(maxCrossAxisExtent),
          ),
          children: _evaluateListOfWidgets(children),
        ),
      ListViewBuilder(
        itemBuilder: final itemBuilder,
        itemCount: final itemCount
      ) =>
        flt.ListView.builder(
          itemBuilder: (context, index) {
            final previousEnvironment = _environment;
            _environment.define('index', index, 'final');
            final result = callFunctionDeclaration(itemBuilder, [index]);
            _environment = previousEnvironment;
            return result;
          },
          itemCount: evaluateNode(itemCount),
        ),
      GridViewBuilder(
        itemBuilder: final itemBuilder,
        itemCount: final itemCount,
        maxCrossAxisExtent: final maxCrossAxisExtent
      ) =>
        flt.GridView.builder(
          itemBuilder: (context, index) {
            final previousEnvironment = _environment;
            _environment.define('index', index, 'final');
            final result = callFunctionDeclaration(itemBuilder, [index]);
            _environment = previousEnvironment;
            return result;
          },
          itemCount: evaluateNode(itemCount),
          gridDelegate: flt.SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: evaluateNode(maxCrossAxisExtent),
          ),
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
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

    try {
      for (int i = 0; i < declaration.parameters.length; i++) {
        _environment.define(
            declaration.parameters[i].lexeme, arguments[i], 'var');
      }

      return evaluateNode(declaration.body);
    } finally {
      _environment = previousEnv;
      _isGlobalScope = wasGlobalScope;
    }
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
    _globals.define(name, function, 'final');
  }

  void defineGlobalVariable(String name, dynamic value) {
    _globals.define(name, value, 'var');
  }

  dynamic getGlobalVariable(String name) {
    return _globals.getValue(name);
  }

  dynamic getVariable(String name) {
    return _environment.getValue(name);
  }

  flt.TextStyle _convertTextStyle(TextStyle style) {
    return flt.TextStyle(
      fontFamily:
          style.fontFamily != null ? evaluateNode(style.fontFamily!) : null,
      fontSize: style.fontSize != null ? evaluateNode(style.fontSize!) : null,
      color: style.color != null ? _convertColor(style.color! as Color) : null,
      fontWeight: style.fontWeight != null
          ? _convertFontWeight(style.fontWeight! as FontWeight)
          : null,
    );
  }

  flt.Color _convertColor(Color color) {
    return flt.Color.fromARGB(
      color.a != null ? evaluateNode(color.a!) : 255,
      color.r != null ? evaluateNode(color.r!) : 0,
      color.g != null ? evaluateNode(color.g!) : 0,
      color.b != null ? evaluateNode(color.b!) : 0,
    );
  }

  flt.FontWeight _convertFontWeight(FontWeight fontWeight) {
    return switch (fontWeight) {
      FontWeightNormal() => flt.FontWeight.normal,
      FontWeightBold() => flt.FontWeight.bold,
      _ => flt.FontWeight.normal,
    };
  }

  flt.EdgeInsets _convertEdgeInsets(EdgeInsets padding) {
    return flt.EdgeInsets.fromLTRB(
      padding.left != null ? evaluateNode(padding.left!) : 0,
      padding.top != null ? evaluateNode(padding.top!) : 0,
      padding.right != null ? evaluateNode(padding.right!) : 0,
      padding.bottom != null ? evaluateNode(padding.bottom!) : 0,
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

    // For custom objects or classes, we might need to implement a more sophisticated
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

  String _evaluateToString(ToString node) {
    dynamic value = evaluateNode(node.expression);
    return value.toString();
  }

  List<flt.Widget> _evaluateListOfWidgets(AstNode children) {
    if (children is ListLiteral) {
      return children.elements
          .map((child) => child is AstWidget
              ? _evaluateWidget(child)
              : flt.Text(evaluateNode(child).toString()))
          .toList();
    } else {
      final evaluatedChildren = evaluateNode(children);
      if (evaluatedChildren is List) {
        return evaluatedChildren
            .map((child) =>
                child is flt.Widget ? child : flt.Text(child.toString()))
            .toList();
      }
      throw EvaluationError('Expected a list of widgets or a ListLiteral');
    }
  }
}
