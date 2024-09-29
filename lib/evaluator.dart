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

// Add this class
class ReturnException implements Exception {
  final dynamic value;
  ReturnException(this.value);
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
    return _getFromEnvironment(name.lexeme);
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
  final Environment _globals = Environment();
  late Environment _environment;
  bool _isGlobalScope = true;

  late final List<AstNode> Function(String filepath) _importHandler;

  // Add this map to store custom widget factories
  final Map<String, flt.Widget Function(Map<String, dynamic> params)>
      _customWidgetFactories = {};

  Evaluator() {
    _environment = _globals;
    defineGlobalFunction('print', (List<dynamic> args) => print(args.first));
  }

  void setImportHandler(List<AstNode> Function(String filepath) importHandler) {
    _importHandler = importHandler;
  }

  // Method to register custom widgets
  void registerCustomWidget(String widgetName,
      flt.Widget Function(Map<String, dynamic> params) factory) {
    _customWidgetFactories[widgetName] = factory;
  }

  dynamic evaluate(List<AstNode> nodes) {
    dynamic result;
    for (var node in nodes) {
      try {
        result = evaluateNode(node);
      } on ReturnException catch (e) {
        result = e.value; // Handle return value
      }
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
    throw ReturnException(value); // Throw exception instead of returning
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
      TextField(
        decoration: final decoration,
        onSubmitted: final onSubmitted,
        onChanged: final onChanged
      ) =>
        flt.TextField(
          decoration: decoration != null
              ? _convertInputDecoration(decoration as InputDecoration)
              : null,
          onSubmitted: onSubmitted != null
              ? (value) => callFunctionDeclaration(onSubmitted, [value])
              : null,
          onChanged: onChanged != null
              ? (value) => callFunctionDeclaration(onChanged, [value])
              : null,
        ),
      ListTile(
        leading: final leading,
        title: final title,
        subtitle: final subtitle,
        trailing: final trailing,
        onTap: final onTap
      ) =>
        flt.ListTile(
          leading:
              leading != null ? _evaluateWidget(leading as AstWidget) : null,
          title: title != null ? _evaluateWidget(title as AstWidget) : null,
          subtitle:
              subtitle != null ? _evaluateWidget(subtitle as AstWidget) : null,
          trailing:
              trailing != null ? _evaluateWidget(trailing as AstWidget) : null,
          onTap:
              onTap != null ? () => callFunctionDeclaration(onTap, []) : null,
        ),
      Stack(children: final children, alignment: final alignment) => flt.Stack(
          alignment: (alignment != null
                  ? _convertAlignment(alignment as AstWidget)
                  : null) ??
              flt.Alignment.topLeft,
          children: _evaluateListOfWidgets(children),
        ),
      TextButton(child: final child, onPressed: final onPressed) =>
        flt.TextButton(
          onPressed: () => callFunctionDeclaration(
            onPressed,
            onPressed.parameters,
          ),
          child: _evaluateWidget(child),
        ),
      OutlinedButton(child: final child, onPressed: final onPressed) =>
        flt.OutlinedButton(
          onPressed: () => callFunctionDeclaration(
            onPressed,
            onPressed.parameters,
          ),
          child: _evaluateWidget(child),
        ),
      LinearProgressIndicator(
        value: final value,
        backgroundColor: final backgroundColor,
        color: final color
      ) =>
        flt.LinearProgressIndicator(
          value: value != null ? evaluateNode(value) : null,
          backgroundColor: backgroundColor != null
              ? _convertColor(backgroundColor as Color)
              : null,
          color: color != null ? _convertColor(color as Color) : null,
        ),
      CircularProgressIndicator(
        value: final value,
        backgroundColor: final backgroundColor,
        color: final color
      ) =>
        flt.CircularProgressIndicator(
          value: value != null ? evaluateNode(value) : null,
          backgroundColor: backgroundColor != null
              ? _convertColor(backgroundColor as Color)
              : null,
          color: color != null ? _convertColor(color as Color) : null,
        ),
      CustomAstWidget() => _evaluateCustomWidget(node),
    };
  }

  dynamic _evaluateAnonymousFunction(AnonymousFunction node) {
    return node;
  }

  dynamic callFunctionDeclaration(
      FunctionDeclaration declaration, List<dynamic> arguments) {
    Environment functionEnv = Environment(_environment);

    for (int i = 0; i < declaration.parameters.length; i++) {
      functionEnv.define(declaration.parameters[i].lexeme, arguments[i], 'var');
    }

    Environment previousEnv = _environment;
    _environment = functionEnv;
    bool wasGlobalScope = _isGlobalScope;
    _isGlobalScope = false;

    try {
      return evaluateNode(declaration.body);
    } on ReturnException catch (e) {
      return e.value; // Handle return value
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

  flt.AlignmentGeometry _convertAlignment(AstWidget node) {
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

  flt.Widget _evaluateCustomWidget(CustomAstWidget node) {
    final factory = _customWidgetFactories[node.name.lexeme];
    if (factory != null) {
      Map<String, dynamic> params = {};
      for (var entry in node.params.entries) {
        params[entry.key] = evaluateNode(entry.value);
      }
      return factory(params);
    }
    throw EvaluationError("Unknown custom widget: ${node.name.lexeme}");
  }
}
