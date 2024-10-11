library tart;

import 'ast.dart';
import 'token.dart';
import 'package:flutter/material.dart' as flt;
import 'dart:math';

class EvaluationError implements Exception {
  final String message;
  EvaluationError(this.message);
  @override
  String toString() => 'EvaluationError: $message';
}

class ReturnException implements Exception {
  final dynamic value;
  ReturnException(this.value);
}

class EvaluationMetrics {
  int widgetCount = 0;
  int nodeCount = 0;
  int variableCount = 0;
  int functionCallCount = 0;
  int expressionCount = 0;

  void reset() {
    widgetCount = 0;
    nodeCount = 0;
    variableCount = 0;
    functionCallCount = 0;
    expressionCount = 0;
  }

  @override
  String toString() {
    return 'EvaluationMetrics(widgets: $widgetCount, nodes: $nodeCount, variables: $variableCount, functionCalls: $functionCallCount, expressions: $expressionCount)';
  }
}

class Environment {
  final String id;
  final Environment? enclosing;
  final Map<String, dynamic> values = {};
  final Set<String> immutableVariables = {};

  Environment(this.id, [this.enclosing]);

  void define(String name, dynamic value, String keyword) {
    values[name] = value;
    if (keyword == 'final' || keyword == 'const') {
      immutableVariables.add(name);
    }
  }

  dynamic get(Token name) {
    return _getFromEnvironment(name.lexeme);
  }

  String getByValue(dynamic value) {
    final entry = values.entries.firstWhere((entry) => entry.value == value,
        orElse: () => throw EvaluationError('No variable has value: $value.'));
    return entry.key;
  }

  dynamic getValue(String name) {
    return _getFromEnvironment(name);
  }

  dynamic _getFromEnvironment(String name) {
    Environment? environment = this;
    while (environment != null) {
      if (environment.values.containsKey(name)) {
        return environment.values[name];
      }
      environment = environment.enclosing;
    }
    throw EvaluationError("Undefined variable '$name'.");
  }

  void assign(Token name, dynamic value) {
    Environment? environment = this;
    while (environment != null) {
      if (environment.values.containsKey(name.lexeme)) {
        if (environment.immutableVariables.contains(name.lexeme)) {
          throw EvaluationError(
              "Cannot reassign to final or const variable '${name.lexeme}'.");
        }
        environment.values[name.lexeme] = value;
        return;
      }
      environment = environment.enclosing;
    }
    throw EvaluationError("Undefined variable '${name.lexeme}'.");
  }
}

class BreakException implements Exception {}

class Evaluator {
  final Map<String, Environment> _environments = {};
  final Environment _globals = Environment('global');
  late Environment _currentEnvironment;
  bool _isGlobalScope = true;

  late final List<AstNode> Function(String filepath) _importHandler;

  // Add this map to store custom widget factories
  final Map<String, flt.Widget Function(Map<String, dynamic> params)>
      _customWidgetFactories = {};
  final Map<Type, flt.Widget Function(AstWidget node)> _widgetFactories = {};
  final Map<String, dynamic Function(AstParameter node)> _parameterFactories =
      {};

  final Map<String, flt.IconData> icons = {
    'IconsAdd': flt.Icons.add,
    'IconsRemove': flt.Icons.remove,
    'IconsEdit': flt.Icons.edit,
    'IconsDelete': flt.Icons.delete,
    'IconsSave': flt.Icons.save,
    'IconsCancel': flt.Icons.cancel,
    'IconsSearch': flt.Icons.search,
    'IconsClear': flt.Icons.clear,
    'IconsClose': flt.Icons.close,
    'IconsMenu': flt.Icons.menu,
    'IconsSettings': flt.Icons.settings,
    'IconsHome': flt.Icons.home,
    'IconsPerson': flt.Icons.person,
    'IconsNotifications': flt.Icons.notifications,
    'IconsFavorite': flt.Icons.favorite,
    'IconsShare': flt.Icons.share,
    'IconsMoreVert': flt.Icons.more_vert,
    'IconsRefresh': flt.Icons.refresh,
    'IconsArrowBack': flt.Icons.arrow_back,
    'IconsArrowForward': flt.Icons.arrow_forward,
    'IconsCheck': flt.Icons.check,
    'IconsInfo': flt.Icons.info,
    'IconsWarning': flt.Icons.warning,
    'IconsError': flt.Icons.error,
    'IconsHelp': flt.Icons.help,
    'IconsShoppingBag': flt.Icons.shopping_bag,
    'IconsAttractions': flt.Icons.attractions,
    'IconsRestaurant': flt.Icons.restaurant,
    'IconsStar': flt.Icons.star,
  };

  final EvaluationMetrics metrics = EvaluationMetrics();

  String createIsolatedEnvironment() {
    String id = _generateUniqueId();
    _environments[id] = Environment(id, _globals);
    return id;
  }

  void setCurrentEnvironment(String id) {
    if (!_environments.containsKey(id)) {
      throw EvaluationError('Environment with ID $id does not exist');
    }
    _currentEnvironment = _environments[id]!;
  }

  void removeEnvironment(String id) {
    _environments.remove(id);
  }

  String _generateUniqueId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Evaluator() {
    _initializeWidgetFactories();
    _initializeParameterFactories();
    _currentEnvironment = _globals;
    // ignore: avoid_print
    defineGlobalFunction('print', (List<dynamic> args) => print(args.first));
    defineGlobalFunction('expectDefined', (List<dynamic> args) {
      if (args.isEmpty || args.length < 2 || args.length > 2) {
        throw EvaluationError('expectDefined requires two arguments');
      }
      if (args[0] == null) {
        throw EvaluationError('expectDefined: ${args[0]}, ${args[1]}');
      }
      try {
        _currentEnvironment.getByValue(args[0]);
      } catch (e) {
        throw EvaluationError('expectDefined: ${args[0]}, ${args[1]}');
      }
      return true;
    });
  }

  void _initializeWidgetFactories() {
    _widgetFactories[Text] = (node) {
      node as Text;
      return flt.Text(
        evaluateNode(node.text),
        style: node.style != null ? _convertTextStyle(node.style!) : null,
      );
    };
    _widgetFactories[Column] = (node) {
      node as Column;
      return flt.Column(
        mainAxisAlignment: _convertMainAxisAlignment(node.mainAxisAlignment),
        crossAxisAlignment: _convertCrossAxisAlignment(node.crossAxisAlignment),
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[Row] = (node) {
      node as Row;
      return flt.Row(
        mainAxisAlignment: _convertMainAxisAlignment(node.mainAxisAlignment),
        crossAxisAlignment: _convertCrossAxisAlignment(node.crossAxisAlignment),
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[Container] = (node) {
      node as Container;
      return flt.Container(
        width: node.width != null ? evaluateNode(node.width!).toDouble() : null,
        height:
            node.height != null ? evaluateNode(node.height!).toDouble() : null,
        color: node.color != null ? evaluateNode(node.color!) : null,
        child: node.child != null ? _evaluateWidget(node.child!) : null,
      );
    };
    _widgetFactories[Image] = (node) {
      node as Image;
      return flt.Image.network(evaluateNode(node.url));
    };
    _widgetFactories[Padding] = (node) {
      node as Padding;
      return flt.Padding(
        padding: _convertEdgeInsets(node.padding),
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[Center] = (node) {
      node as Center;
      return flt.Center(child: _evaluateWidget(node.child));
    };
    _widgetFactories[SizedBox] = (node) {
      node as SizedBox;
      return flt.SizedBox(
        width: node.width != null ? evaluateNode(node.width!).toDouble() : null,
        height:
            node.height != null ? evaluateNode(node.height!).toDouble() : null,
        child: node.child != null ? _evaluateWidget(node.child!) : null,
      );
    };
    _widgetFactories[Expanded] = (node) {
      node as Expanded;
      return flt.Expanded(
        flex: node.flex != null ? evaluateNode(node.flex!) : 1,
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[ElevatedButton] = (node) {
      node as ElevatedButton;
      final onPressed = getFunctionDeclaration(node.onPressed);
      return flt.ElevatedButton(
        onPressed: () => _callClosure(
          onPressed!,
          onPressed.declaration.parameters,
        ),
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[Card] = (node) {
      node as Card;
      return flt.Card(
        elevation: node.elevation != null
            ? evaluateNode(node.elevation!).toDouble()
            : null,
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[ListView] = (node) {
      node as ListView;
      return flt.ListView(
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[GridView] = (node) {
      node as GridView;
      return flt.GridView(
        gridDelegate: flt.SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: evaluateNode(node.maxCrossAxisExtent).toDouble(),
        ),
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[ListViewBuilder] = (node) {
      node as ListViewBuilder;
      final itemBuilder = getFunctionDeclaration(node.itemBuilder);
      return flt.ListView.builder(
        itemBuilder: (context, index) {
          final previousEnvironment = _currentEnvironment;
          _currentEnvironment.define('index', index, 'final');
          final result = _callClosure(itemBuilder!, [index]);
          _currentEnvironment = previousEnvironment;
          return result;
        },
        itemCount: evaluateNode(node.itemCount),
      );
    };
    _widgetFactories[GridViewBuilder] = (node) {
      node as GridViewBuilder;
      final itemBuilder = getFunctionDeclaration(node.itemBuilder);
      return flt.GridView.builder(
        itemBuilder: (context, index) {
          final previousEnvironment = _currentEnvironment;
          _currentEnvironment.define('index', index, 'final');
          final result = _callClosure(itemBuilder!, [index]);
          _currentEnvironment = previousEnvironment;
          return result;
        },
        itemCount: evaluateNode(node.itemCount),
        gridDelegate: flt.SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: evaluateNode(node.maxCrossAxisExtent).toDouble(),
        ),
      );
    };
    _widgetFactories[TextField] = (node) {
      node as TextField;
      final onSubmitted = getFunctionDeclaration(node.onSubmitted);
      final onChanged = getFunctionDeclaration(node.onChanged);
      return flt.TextField(
        decoration:
            node.decoration != null ? evaluateNode(node.decoration!) : null,
        onSubmitted: onSubmitted != null
            ? (value) => _callClosure(onSubmitted, [value])
            : null,
        onChanged: onChanged != null
            ? (value) => _callClosure(onChanged, [value])
            : null,
      );
    };
    _widgetFactories[ListTile] = (node) {
      node as ListTile;
      final onTap = getFunctionDeclaration(node.onTap);
      return flt.ListTile(
        leading: node.leading != null ? evaluateNode(node.leading!) : null,
        title: node.title != null ? evaluateNode(node.title!) : null,
        subtitle: node.subtitle != null ? evaluateNode(node.subtitle!) : null,
        trailing: node.trailing != null ? evaluateNode(node.trailing!) : null,
        onTap: onTap != null ? () => _callClosure(onTap, []) : null,
      );
    };
    _widgetFactories[Stack] = (node) {
      node as Stack;
      return flt.Stack(
        alignment: node.alignment != null
            ? evaluateNode(node.alignment!)
            : flt.Alignment.topLeft,
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[TextButton] = (node) {
      node as TextButton;
      final onPressed = getFunctionDeclaration(node.onPressed);
      return flt.TextButton(
        onPressed: () => _callClosure(
          onPressed!,
          onPressed.declaration.parameters,
        ),
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[OutlinedButton] = (node) {
      node as OutlinedButton;
      final onPressed = getFunctionDeclaration(node.onPressed);
      return flt.OutlinedButton(
        onPressed: () => _callClosure(
          onPressed!,
          onPressed.declaration.parameters,
        ),
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[LinearProgressIndicator] = (node) {
      node as LinearProgressIndicator;
      return flt.LinearProgressIndicator(
        value: node.value != null ? evaluateNode(node.value!).toDouble() : null,
        backgroundColor: node.backgroundColor != null
            ? evaluateNode(node.backgroundColor!)
            : null,
        color: node.color != null ? evaluateNode(node.color!) : null,
      );
    };
    _widgetFactories[CircularProgressIndicator] = (node) {
      node as CircularProgressIndicator;
      return flt.CircularProgressIndicator(
        value: node.value != null ? evaluateNode(node.value!) : null,
        backgroundColor: node.backgroundColor != null
            ? evaluateNode(node.backgroundColor!)
            : null,
        color: node.color != null ? evaluateNode(node.color!) : null,
      );
    };
    _widgetFactories[SingleChildScrollView] = (node) {
      node as SingleChildScrollView;
      return flt.SingleChildScrollView(
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[MaterialApp] = (node) {
      node as MaterialApp;
      return flt.MaterialApp(
        home: _evaluateWidget(node.home),
      );
    };
    _widgetFactories[Scaffold] = (node) {
      node as Scaffold;
      return flt.Scaffold(
        body: node.body != null ? _evaluateWidget(node.body!) : null,
        appBar: node.appBar != null
            ? _evaluateWidget(node.appBar!) as flt.PreferredSizeWidget
            : null,
        floatingActionButton: node.floatingActionButton != null
            ? _evaluateWidget(node.floatingActionButton!)
            : null,
      );
    };
    _widgetFactories[FloatingActionButton] = (node) {
      node as FloatingActionButton;
      final onPressed = getFunctionDeclaration(node.onPressed);
      return flt.FloatingActionButton(
        onPressed: () => _callClosure(
          onPressed!,
          onPressed.declaration.parameters,
        ),
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[AppBar] = (node) {
      node as AppBar;
      return flt.AppBar(
        title: evaluateNode(node.title),
        leading: node.leading != null ? evaluateNode(node.leading!) : null,
        actions:
            node.actions != null ? _evaluateListOfWidgets(node.actions!) : null,
      );
    };
    _widgetFactories[Icon] = (node) {
      node as Icon;
      return flt.Icon(evaluateNode(node.icon));
    };
    _widgetFactories[Positioned] = (node) {
      node as Positioned;
      return flt.Positioned(
        top: node.top != null ? evaluateNode(node.top!).toDouble() : null,
        left: node.left != null ? evaluateNode(node.left!).toDouble() : null,
        child: _evaluateWidget(node.child!),
      );
    };
    _widgetFactories[StatefulBuilder] = (node) {
      node as StatefulBuilder;
      final builder = getFunctionDeclaration(node.builder);
      return flt.StatefulBuilder(
        builder: (context, setState) {
          // Why do we need to pass params?
          tartSetState(params) {
            setState(() {});
          }

          return _callClosure(builder!, [tartSetState]);
        },
      );
    };
    _widgetFactories[GestureDetector] = (node) {
      node as GestureDetector;
      final onTap = getFunctionDeclaration(node.onTap);
      final onDoubleTap = getFunctionDeclaration(node.onDoubleTap);
      final onLongPress = getFunctionDeclaration(node.onLongPress);
      return flt.GestureDetector(
        onTap: onTap != null
            ? () => _callClosure(
                  onTap,
                  onTap.declaration.parameters,
                )
            : null,
        onDoubleTap: onDoubleTap != null
            ? () => _callClosure(
                  onDoubleTap,
                  onDoubleTap.declaration.parameters,
                )
            : null,
        onLongPress: onLongPress != null
            ? () => _callClosure(
                  onLongPress,
                  onLongPress.declaration.parameters,
                )
            : null,
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[Wrap] = (node) {
      node as Wrap;
      return flt.Wrap(
        children: _evaluateListOfWidgets(node.children),
      );
    };
    _widgetFactories[Align] = (node) {
      node as Align;
      return flt.Align(
        alignment: _convertAlignment(node.alignment as Alignment),
        child: _evaluateWidget(node.child!),
      );
    };
    _widgetFactories[Flexible] = (node) {
      node as Flexible;
      return flt.Flexible(
        flex: node.flex != null ? evaluateNode(node.flex!) : 1,
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[FractionallySizedBox] = (node) {
      node as FractionallySizedBox;
      return flt.FractionallySizedBox(
        widthFactor:
            node.widthFactor != null ? evaluateNode(node.widthFactor!) : null,
        heightFactor:
            node.heightFactor != null ? evaluateNode(node.heightFactor!) : null,
        child: _evaluateWidget(node.child!),
      );
    };
    _widgetFactories[InkWell] = (node) {
      node as InkWell;
      final onTap = getFunctionDeclaration(node.onTap);
      final onDoubleTap = getFunctionDeclaration(node.onDoubleTap);
      final onLongPress = getFunctionDeclaration(node.onLongPress);
      return flt.InkWell(
        onTap: onTap != null
            ? () => _callClosure(onTap, onTap.declaration.parameters)
            : null,
        onDoubleTap: onDoubleTap != null
            ? () =>
                _callClosure(onDoubleTap, onDoubleTap.declaration.parameters)
            : null,
        onLongPress: onLongPress != null
            ? () =>
                _callClosure(onLongPress, onLongPress.declaration.parameters)
            : null,
        child: _evaluateWidget(node.child),
      );
    };
    _widgetFactories[Divider] = (node) {
      node as Divider;
      return flt.Divider(
        height: node.height != null ? evaluateNode(node.height!) : null,
        thickness:
            node.thickness != null ? evaluateNode(node.thickness!) : null,
        color: node.color != null ? _convertColor(node.color as Color) : null,
      );
    };
    _widgetFactories[SafeArea] = (node) {
      node as SafeArea;
      return flt.SafeArea(child: _evaluateWidget(node.child));
    };
  }

  void _initializeParameterFactories() {
    _parameterFactories['EdgeInsets'] = (node) {
      node as EdgeInsets;
      return _convertEdgeInsets(node);
    };
    _parameterFactories['MainAxisAlignment'] = (node) {
      node as MainAxisAlignment;
      return _convertMainAxisAlignment(node);
    };
    _parameterFactories['CrossAxisAlignment'] = (node) {
      node as CrossAxisAlignment;
      return _convertCrossAxisAlignment(node);
    };
    _parameterFactories['Color'] = (node) {
      node as Color;
      return _convertColor(node);
    };
    _parameterFactories['FontWeight'] = (node) {
      node as FontWeight;
      return _convertFontWeight(node);
    };
    _parameterFactories['InputDecoration'] = (node) {
      node as InputDecoration;
      return _convertInputDecoration(node);
    };
    _parameterFactories['Alignment'] = (node) {
      node as Alignment;
      return _convertAlignment(node);
    };
    _parameterFactories['Icons'] = (node) {
      node as Icons;
      return _convertIcon(node);
    };
  }

  void registerCustomIcons(Map<String, flt.IconData> customIcons) {
    icons.addAll(customIcons);
  }

  void setImportHandler(List<AstNode> Function(String filepath) importHandler) {
    _importHandler = importHandler;
  }

  // Method to register custom widgets
  void registerCustomWidget(String widgetName,
      flt.Widget Function(Map<String, dynamic> params) factory) {
    _customWidgetFactories[widgetName] = factory;
  }

  dynamic evaluate(List<AstNode> nodes, {String? environmentId}) {
    if (environmentId != null) {
      setCurrentEnvironment(environmentId);
    }

    dynamic result;
    for (var node in nodes) {
      try {
        result = evaluateNode(node);
      } on ReturnException catch (e) {
        result = e.value;
      }
    }
    return result;
  }

  Closure? getFunctionDeclaration(AstNode? node) {
    final value = evaluateNode(node ?? const Literal(null));
    if (value == null) {
      return null;
    }
    if (value is Closure || value is Function) {
      return value;
    }
    throw EvaluationError('Expected function declaration, got $value');
  }

  dynamic evaluateNode(AstNode node) {
    metrics.nodeCount++;
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
      Variable() => _currentEnvironment.get(node.name),
      Assignment() => _evaluateAssignment(node),
      AstWidget() => _evaluateWidget(node),
      EndOfFile() => null,
      IndexAccess() => _evaluateIndexAccess(node),
      MemberAccess() => _evaluateMemberAccess(node),
      ListLiteral() => _evaluateListLiteral(node),
      BreakStatement() => throw BreakException(),
      ImportStatement() => _evaluateImportStatement(node),
      AstParameter() => _evaluateParameter(node),
      TryStatement() => _evaluateTryStatement(node),
      ThrowStatement() => _evaluateThrowStatement(node),
      _ => throw EvaluationError('Unknown node type: ${node.runtimeType}'),
    };
  }

  dynamic _evaluateVariableDeclaration(VariableDeclaration node) {
    metrics.variableCount++;
    dynamic value =
        node.initializer != null ? evaluateNode(node.initializer!) : null;
    if (_isGlobalScope) {
      _globals.define(node.name.lexeme, value, node.keyword.lexeme);
    } else {
      _currentEnvironment.define(node.name.lexeme, value, node.keyword.lexeme);
    }
    return value;
  }

  dynamic _evaluateFunctionDeclaration(FunctionDeclaration node) {
    // Create a closure that captures the current environment
    Closure closure = Closure(node, _currentEnvironment);
    _currentEnvironment.define(node.name.lexeme, closure, 'final');
    return closure;
  }

  dynamic _evaluateImportStatement(ImportStatement node) {
    List<AstNode> importedAst = _importHandler(node.path);
    return evaluate(importedAst);
  }

  T _withInnerScope<T>(String scopeId, Function() body) {
    Environment previousEnv = _currentEnvironment;
    final newEnv = Environment(scopeId, _currentEnvironment);
    _currentEnvironment = newEnv;
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

    try {
      return body() as T;
    } finally {
      _currentEnvironment = previousEnv;
      _isGlobalScope = wasGlobalScope;
    }
  }

  dynamic _evaluateIfStatement(IfStatement node) {
    return _withInnerScope('if', () {
      if (_isTruthy(evaluateNode(node.condition))) {
        return evaluateNode(node.thenBranch);
      } else if (node.elseBranch != null) {
        return evaluateNode(node.elseBranch!);
      }
      return null;
    });
  }

  dynamic _evaluateWhileStatement(WhileStatement node) {
    return _withInnerScope('while', () {
      while (_isTruthy(evaluateNode(node.condition))) {
        try {
          evaluateNode(node.body);
        } on BreakException {
          break;
        }
      }
      return null;
    });
  }

  dynamic _evaluateForStatement(ForStatement node) {
    return _withInnerScope('for', () {
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
    });
  }

  dynamic _evaluateReturnStatement(ReturnStatement node) {
    dynamic value = node.value != null ? evaluateNode(node.value!) : null;
    throw ReturnException(value); // Throw exception instead of returning
  }

  dynamic _evaluateBlock(Block node) {
    return _withInnerScope('block', () {
      dynamic value;
      for (var statement in node.statements) {
        value = evaluateNode(statement);
      }
      return value;
    });
  }

  dynamic _evaluateBinaryExpression(BinaryExpression node) {
    metrics.expressionCount++;
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
      TokenType.plusAssign => left += right,
      TokenType.minusAssign => left -= right,
      TokenType.multiplyAssign => left *= right,
      TokenType.divideAssign => left /= right,
      _ => throw EvaluationError(
          'Unknown binary operator: ${node.operator.lexeme}'),
    };
  }

  dynamic _evaluateUnaryExpression(UnaryExpression node) {
    metrics.expressionCount++;
    dynamic right = evaluateNode(node.right);

    return switch (node.operator.type) {
      TokenType.minus => -right,
      TokenType.not => !_isTruthy(right),
      _ => throw EvaluationError(
          'Unknown unary operator: ${node.operator.lexeme}'),
    };
  }

  dynamic _evaluateCallExpression(CallExpression node) {
    metrics.functionCallCount++;
    dynamic callee = evaluateNode(node.callee);

    List<dynamic> arguments =
        node.arguments.map((arg) => evaluateNode(arg)).toList();

    if (callee is Closure) {
      return _callClosure(callee, arguments);
    } else if (callee is Function) {
      return callee(arguments);
    }

    throw EvaluationError('Can only call functions and methods.');
  }

  dynamic _evaluateAssignment(Assignment node) {
    dynamic value = evaluateNode(node.value);
    _currentEnvironment.assign(node.name, value);
    return value;
  }

  flt.Widget _evaluateWidget(AstWidget node) {
    metrics.widgetCount++;
    final widgetType = node.runtimeType;
    var factory = _widgetFactories[widgetType];
    if (factory != null) {
      return factory(node);
    } else {
      return _evaluateCustomWidget(node as CustomAstWidget);
    }
  }

  dynamic _evaluateParameter(AstParameter node) {
    final parameterType = node.tartType;
    final factoryKey = _parameterFactories.keys.firstWhere(
      (e) => parameterType.contains(e),
    );
    final factory = _parameterFactories[factoryKey];
    if (factory != null) {
      return factory(node);
    } else {
      throw EvaluationError('Unknown parameter type: ${node.tartType}');
    }
  }

  dynamic _evaluateAnonymousFunction(AnonymousFunction node) {
    // Create a closure that captures the current environment
    return Closure(node, _currentEnvironment);
  }

  dynamic callFunctionDeclaration(
      FunctionDeclaration declaration, List<dynamic> arguments) {
    return _withInnerScope('function', () {
      for (int i = 0; i < declaration.parameters.length; i++) {
        _currentEnvironment.define(
            declaration.parameters[i].lexeme, arguments[i], 'var');
      }

      try {
        return evaluateNode(declaration.body);
      } on ReturnException catch (e) {
        return e.value;
      }
    });
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return true;
  }

  dynamic callFunction(String functionName, List arguments) {
    final function = _currentEnvironment.getValue(functionName);
    if (function is Closure) {
      return _callClosure(function, arguments);
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
    return _currentEnvironment.getValue(name);
  }

  void defineEnvironmentVariable(String name, dynamic value,
      {String? environmentId}) {
    _environments[environmentId ?? _currentEnvironment.id]!
        .define(name, value, 'var');
  }

  void defineEnvironmentFunction(String name, Function value,
      {String? environmentId}) {
    _environments[environmentId ?? _currentEnvironment.id]!
        .define(name, value, 'final');
  }

  dynamic getEnvironmentVariable(String name, {String? environmentId}) {
    return _environments[environmentId ?? _currentEnvironment.id]!
        .getValue(name);
  }

  flt.IconData _convertIcon(Icons node) {
    return icons[node.tartType]!;
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

  flt.AlignmentGeometry _convertAlignment(Alignment node) {
    return switch (node) {
      AlignmentTopLeft() => flt.Alignment.topLeft,
      AlignmentTopCenter() => flt.Alignment.topCenter,
      AlignmentTopRight() => flt.Alignment.topRight,
      AlignmentCenterLeft() => flt.Alignment.centerLeft,
      AlignmentCenterRight() => flt.Alignment.centerRight,
      AlignmentBottomLeft() => flt.Alignment.bottomLeft,
      AlignmentBottomCenter() => flt.Alignment.bottomCenter,
      AlignmentBottomRight() => flt.Alignment.bottomRight,
      _ => flt.Alignment.topLeft,
    };
  }

  flt.InputDecoration _convertInputDecoration(InputDecoration decoration) {
    return flt.InputDecoration(
      icon: decoration.icon != null
          ? _evaluateWidget(decoration.icon! as AstWidget)
          : null,
      iconColor: decoration.iconColor != null
          ? _convertColor(decoration.iconColor! as Color)
          : null,
      label: decoration.label != null
          ? _evaluateWidget(decoration.label! as AstWidget)
          : null,
      labelText: decoration.labelText != null
          ? evaluateNode(decoration.labelText!)
          : null,
      labelStyle: decoration.labelStyle != null
          ? _convertTextStyle(decoration.labelStyle! as TextStyle)
          : null,
      floatingLabelStyle: decoration.floatingLabelStyle != null
          ? _convertTextStyle(decoration.floatingLabelStyle! as TextStyle)
          : null,
      helperText: decoration.helperText != null
          ? evaluateNode(decoration.helperText!)
          : null,
      helperStyle: decoration.helperStyle != null
          ? _convertTextStyle(decoration.helperStyle! as TextStyle)
          : null,
      helperMaxLines: decoration.helperMaxLines != null
          ? evaluateNode(decoration.helperMaxLines!)
          : null,
      hintText: decoration.hintText != null
          ? evaluateNode(decoration.hintText!)
          : null,
      hintStyle: decoration.hintStyle != null
          ? _convertTextStyle(decoration.hintStyle! as TextStyle)
          : null,
      hintTextDirection: decoration.hintTextDirection != null
          ? evaluateNode(decoration.hintTextDirection!)
          : null,
      hintMaxLines: decoration.hintMaxLines != null
          ? evaluateNode(decoration.hintMaxLines!)
          : null,
      errorText: decoration.errorText != null
          ? evaluateNode(decoration.errorText!)
          : null,
      errorStyle: decoration.errorStyle != null
          ? _convertTextStyle(decoration.errorStyle! as TextStyle)
          : null,
      errorMaxLines: decoration.errorMaxLines != null
          ? evaluateNode(decoration.errorMaxLines!)
          : null,
      floatingLabelBehavior: decoration.floatingLabelBehavior != null
          ? evaluateNode(decoration.floatingLabelBehavior!)
          : null,
      isCollapsed: decoration.isCollapsed != null
          ? evaluateNode(decoration.isCollapsed!)
          : null,
      isDense:
          decoration.isDense != null ? evaluateNode(decoration.isDense!) : null,
      contentPadding: decoration.contentPadding != null
          ? _convertEdgeInsets(decoration.contentPadding! as EdgeInsets)
          : null,
      prefixIcon: decoration.prefixIcon != null
          ? _evaluateWidget(decoration.prefixIcon! as AstWidget)
          : null,
      prefixIconColor: decoration.prefixIconColor != null
          ? _convertColor(decoration.prefixIconColor! as Color)
          : null,
      prefix: decoration.prefix != null
          ? _evaluateWidget(decoration.prefix! as AstWidget)
          : null,
      prefixText: decoration.prefixText != null
          ? evaluateNode(decoration.prefixText!)
          : null,
      prefixStyle: decoration.prefixStyle != null
          ? _convertTextStyle(decoration.prefixStyle! as TextStyle)
          : null,
      suffixIcon: decoration.suffixIcon != null
          ? _evaluateWidget(decoration.suffixIcon! as AstWidget)
          : null,
      suffixIconColor: decoration.suffixIconColor != null
          ? _convertColor(decoration.suffixIconColor! as Color)
          : null,
      suffix: decoration.suffix != null
          ? _evaluateWidget(decoration.suffix! as AstWidget)
          : null,
      suffixText: decoration.suffixText != null
          ? evaluateNode(decoration.suffixText!)
          : null,
      suffixStyle: decoration.suffixStyle != null
          ? _convertTextStyle(decoration.suffixStyle! as TextStyle)
          : null,
      counterText: decoration.counterText != null
          ? evaluateNode(decoration.counterText!)
          : null,
      counterStyle: decoration.counterStyle != null
          ? _convertTextStyle(decoration.counterStyle! as TextStyle)
          : null,
      filled:
          decoration.filled != null ? evaluateNode(decoration.filled!) : null,
      fillColor: decoration.fillColor != null
          ? _convertColor(decoration.fillColor! as Color)
          : null,
      focusColor: decoration.focusColor != null
          ? _convertColor(decoration.focusColor! as Color)
          : null,
      hoverColor: decoration.hoverColor != null
          ? _convertColor(decoration.hoverColor! as Color)
          : null,
      errorBorder: decoration.errorBorder != null
          ? evaluateNode(decoration.errorBorder!)
          : null,
      focusedBorder: decoration.focusedBorder != null
          ? evaluateNode(decoration.focusedBorder!)
          : null,
      focusedErrorBorder: decoration.focusedErrorBorder != null
          ? evaluateNode(decoration.focusedErrorBorder!)
          : null,
      disabledBorder: decoration.disabledBorder != null
          ? evaluateNode(decoration.disabledBorder!)
          : null,
      enabledBorder: decoration.enabledBorder != null
          ? evaluateNode(decoration.enabledBorder!)
          : null,
      border:
          decoration.border != null ? evaluateNode(decoration.border!) : null,
      enabled:
          decoration.enabled != null ? evaluateNode(decoration.enabled!) : true,
      semanticCounterText: decoration.semanticCounterText != null
          ? evaluateNode(decoration.semanticCounterText!)
          : null,
      alignLabelWithHint: decoration.alignLabelWithHint != null
          ? evaluateNode(decoration.alignLabelWithHint!)
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
      padding.left != null ? evaluateNode(padding.left!).toDouble() : 0,
      padding.top != null ? evaluateNode(padding.top!).toDouble() : 0,
      padding.right != null ? evaluateNode(padding.right!).toDouble() : 0,
      padding.bottom != null ? evaluateNode(padding.bottom!).toDouble() : 0,
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
    final object = evaluateNode(node.object);
    String memberName = node.name.lexeme;

    dynamic member;
    try {
      member = object[memberName];
    } catch (e) {
      // throw EvaluationError('Member $memberName not found');
    }

    if (node.arguments != null) {
      if (memberName == 'toString') {
        return object.toString();
      }
      if (member is! Function) {
        throw EvaluationError('Cannot call non-function member $memberName');
      }
      return callFunction('${object['name']}.$memberName', node.arguments!);
    }

    switch (memberName) {
      case 'length':
        if (object is! Iterable && object is! String && object is! Map) {
          throw EvaluationError('Cannot get length of ${object.runtimeType}');
        }
        return object.length;
      case 'runtimeType':
        return object.runtimeType;
      default:
        return member;
    }
  }

  dynamic _evaluateListLiteral(ListLiteral node) {
    return node.elements.map((element) => evaluateNode(element)).toList();
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

  flt.Widget _evaluateCustomWidget(CustomAstWidget node) {
    final factoryKey = _customWidgetFactories.keys
        .firstWhere((e) => node.name.lexeme.contains(e));
    final factory = _customWidgetFactories[factoryKey];
    if (factory != null) {
      Map<String, dynamic> params = {};
      for (var entry in node.params.entries) {
        params[entry.key] = evaluateNode(entry.value);
      }
      return factory(params);
    }
    throw EvaluationError("Unknown custom widget: ${node.tartType}");
  }

  dynamic _evaluateTryStatement(TryStatement node) {
    try {
      return evaluateNode(node.tryBlock);
    } catch (e) {
      for (var catchClause in node.catchClauses) {
        if (catchClause.exceptionType == null ||
            e.runtimeType.toString() == catchClause.exceptionType!.lexeme) {
          return _withInnerScope('catch', () {
            if (catchClause.exceptionVariable != null) {
              _currentEnvironment.define(
                  catchClause.exceptionVariable!.lexeme, e, 'var');
            }
            return evaluateNode(catchClause.catchBlock);
          });
        }
      }
      rethrow; // If no matching catch clause is found, rethrow the exception
    } finally {
      if (node.finallyBlock != null) {
        evaluateNode(node.finallyBlock!);
      }
    }
  }

  dynamic _evaluateThrowStatement(ThrowStatement node) {
    dynamic value = evaluateNode(node.expression);
    throw value;
  }

  void resetMetrics() {
    metrics.reset();
  }

  dynamic _callClosure(Closure closure, List<dynamic> arguments) {
    return _withInnerScope('function', () {
      Environment functionEnv = Environment('function', closure.environment);
      Environment previousEnv = _currentEnvironment;
      _currentEnvironment = functionEnv;

      try {
        FunctionDeclaration funcDecl = closure.declaration;
        for (int i = 0; i < funcDecl.parameters.length; i++) {
          _currentEnvironment.define(
              funcDecl.parameters[i].lexeme, arguments[i], 'var');
        }

        return evaluateNode(funcDecl.body);
      } on ReturnException catch (e) {
        return e.value;
      } finally {
        _currentEnvironment = previousEnv;
      }
    });
  }
}

class Closure {
  final FunctionDeclaration declaration;
  final Environment environment;

  Closure(this.declaration, this.environment);
}
