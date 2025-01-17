library tart;

import 'token.dart';
import 'ast.dart';

class Parser {
  List<Token> tokens = const [];
  int current = 0;
  Token? _nextToken;
  final List<ParseError> errors = [];
  String sourceCode = '';

  Parser();

  void reset() {
    tokens = const [];
    current = 0;
    _nextToken = null;
    errors.clear();
    sourceCode = '';
  }

  final edgeInsetsFactories = {
    'EdgeInsetsAll': (parameters) => EdgeInsetsAll(parameters['value']!),
    'EdgeInsetsSymmetric': (parameters) => EdgeInsetsSymmetric(
          parameters['horizontal'],
          parameters['vertical'],
        ),
    'EdgeInsetsOnly': (parameters) => EdgeInsetsOnly(
          parameters['top'],
          parameters['right'],
          parameters['bottom'],
          parameters['left'],
        ),
  };

  static const iconsMap = {
    'IconsAdd': IconsAdd(),
    'IconsRemove': IconsRemove(),
    'IconsEdit': IconsEdit(),
    'IconsDelete': IconsDelete(),
    'IconsSave': IconsSave(),
    'IconsCancel': IconsCancel(),
    'IconsSearch': IconsSearch(),
    'IconsClear': IconsClear(),
    'IconsClose': IconsClose(),
    'IconsMenu': IconsMenu(),
    'IconsSettings': IconsSettings(),
    'IconsHome': IconsHome(),
    'IconsPerson': IconsPerson(),
    'IconsNotifications': IconsNotifications(),
    'IconsFavorite': IconsFavorite(),
    'IconsShare': IconsShare(),
    'IconsMoreVert': IconsMoreVert(),
    'IconsRefresh': IconsRefresh(),
    'IconsArrowBack': IconsArrowBack(),
    'IconsArrowForward': IconsArrowForward(),
    'IconsCheck': IconsCheck(),
    'IconsInfo': IconsInfo(),
    'IconsWarning': IconsWarning(),
    'IconsError': IconsError(),
    'IconsHelp': IconsHelp(),
    'IconsShoppingBag': IconsShoppingBag(),
    'IconsAttractions': IconsAttractions(),
    'IconsRestaurant': IconsRestaurant(),
    'IconsStar': IconsStar(),
  };

  final widgetFactories = {
    'Text': (params) => Text(params['text']!, params['style']),
    'Column': (params) => Column(
          params['children']!,
          params['mainAxisAlignment'],
          params['crossAxisAlignment'],
        ),
    'Row': (params) => Row(
          params['children']!,
          params['mainAxisAlignment'],
          params['crossAxisAlignment'],
        ),
    'Container': (params) => Container(
        params['child'], params['width'], params['height'], params['color']),
    'Image': (params) => Image(params['url']!),
    'Padding': (params) => Padding(params['padding'], params['child']),
    'Center': (params) => Center(params['child']),
    'SizedBox': (params) => SizedBox(
          width: params['width'],
          height: params['height'],
          child: params['child'],
        ),
    'Expanded': (params) => Expanded(params['child'], params['flex']),
    'ElevatedButton': (params) =>
        ElevatedButton(params['child'], params['onPressed']),
    'Card': (params) => Card(params['child'], params['elevation']),
    'ListView': (params) => ListView(
          params['children'],
          params['shrinkWrap'],
          params['physics'],
        ),
    'GridView': (params) {
      final optionalParam = params['maxCrossAxisExtent'];
      final mainCrossAxisExtent = optionalParam ?? const Literal(100.0);
      return GridView(
        params['children'] as AstNode,
        mainCrossAxisExtent,
        params['shrinkWrap'],
        params['physics'],
      );
    },
    'ListViewBuilder': (params) => ListViewBuilder(
          params['itemBuilder'],
          params['itemCount'],
          params['shrinkWrap'],
          params['physics'],
        ),
    'GridViewBuilder': (params) {
      final optionalParam = params['maxCrossAxisExtent'];
      final mainCrossAxisExtent = optionalParam ?? const Literal(100.0);
      return GridViewBuilder(
        params['itemBuilder'],
        params['itemCount'],
        mainCrossAxisExtent,
        params['shrinkWrap'],
        params['physics'],
      );
    },
    'TextField': (params) => TextField(
          params['decoration'],
          params['onSubmitted'],
          params['onChanged'],
        ),
    'ListTile': (params) => ListTile(
          params['leading'],
          params['title'],
          params['subtitle'],
          params['trailing'],
          params['onTap'],
        ),
    'OutlinedButton': (params) =>
        OutlinedButton(params['child'], params['onPressed']),
    'TextButton': (params) => TextButton(params['child'], params['onPressed']),
    'Stack': (params) => Stack(params['children']!, params['alignment']),
    'LinearProgressIndicator': (params) => LinearProgressIndicator(
          params['value'],
          params['backgroundColor'],
          params['color'],
        ),
    'CircularProgressIndicator': (params) => CircularProgressIndicator(
          params['value'],
          params['backgroundColor'],
          params['color'],
        ),
    'Positioned': (params) => Positioned(
          params['left'],
          params['top'],
          params['right'],
          params['bottom'],
          params['child'],
        ),
    'Icon': (params) => Icon(params['icon']),
    'MaterialApp': (params) => MaterialApp(
          params['home'],
        ),
    'Scaffold': (params) => Scaffold(
          params['appBar'],
          params['body'],
          params['floatingActionButton'],
        ),
    'FloatingActionButton': (params) => FloatingActionButton(
          params['child'],
          params['onPressed'],
        ),
    'AppBar': (params) => AppBar(
          params['title'],
          params['leading'],
          params['actions'],
        ),
    'SingleChildScrollView': (params) => SingleChildScrollView(
          params['child'],
        ),
    'StatefulBuilder': (params) => StatefulBuilder(params['builder']),
    'GestureDetector': (params) => GestureDetector(
          params['child'],
          params['onTap'],
          params['onDoubleTap'],
          params['onLongPress'],
        ),
    'Wrap': (params) => Wrap(
          params['children'],
          params['direction'],
        ),
    'Align': (params) => Align(
          params['alignment'],
          params['child'],
        ),
    'Flexible': (params) => Flexible(
          params['child'],
          params['flex'],
        ),
    'FractionallySizedBox': (params) => FractionallySizedBox(
          params['widthFactor'],
          params['heightFactor'],
          params['child'],
        ),
    'InkWell': (params) => InkWell(
          params['child'],
          params['onTap'],
          params['onDoubleTap'],
          params['onLongPress'],
        ),
    'Divider': (params) => Divider(
          params['height'],
          params['thickness'],
          params['color'],
        ),
    'SafeArea': (params) => SafeArea(params['child']),
  };

  List<AstNode> parse(List<Token> tokens, String source) {
    reset();
    this.tokens = tokens;
    sourceCode = source;
    List<AstNode> statements = [];
    while (!isAtEnd()) {
      statements.add(declaration());
    }
    return statements;
  }

  AstNode declaration() {
    try {
      switch (peek().type) {
        case TokenType.flutterParam:
          advance();
          return flutterParameter();
        case TokenType.flutterWidget:
          advance();
          return flutterWidgetDeclaration();
        case TokenType.tartVar:
        case TokenType.tartConst:
        case TokenType.tartFinal:
          advance();
          return varDeclaration();
        case TokenType.tartFunction:
          advance();
          return functionDeclaration();
        case TokenType.leftParen:
          advance();
          return anonymousFunction();
        case TokenType.identifier:
          if (peek().type == TokenType.leftParen) {
            advance();
            return functionDeclaration();
          }
          return statement();
        case TokenType.tartFor:
          advance();
          return forStatement();
        case TokenType.tartReturn:
          advance();
          return returnStatement();
        case TokenType.tartIf:
          advance();
          return ifStatement();
        case TokenType.tartWhile:
          advance();
          return whileStatement();
        case TokenType.tartImport:
          advance();
          return importDeclaration();
        case TokenType.tartTry:
          return tryStatement();
        case TokenType.tartThrow:
          return throwStatement();
        default:
          return statement();
      }
    } catch (e) {
      synchronize();
      // ignore: avoid_print
      print(errors.join('\n'));
      throw error(peek(), "Expected declaration/statement.");
    }
  }

  Map<String, AstNode> _parseParameterNodes(
      [bool consumeLeftParen = true, bool paramNames = true]) {
    Map<String, AstNode> parameters = {};
    if (consumeLeftParen) {
      consume(TokenType.leftParen, "Expect '(' before parameters.");
    }
    if (!check(TokenType.rightParen)) {
      do {
        if (check(TokenType.rightParen)) break;
        Token? paramName;
        if (paramNames) {
          paramName = consume(TokenType.identifier, "Expect parameter name.");
          consume(TokenType.colon, "Expect ':' after parameter name.");
        }
        final paramValue = parameterValue();
        parameters[paramName?.lexeme ?? paramValue.hashCode.toString()] =
            paramValue;
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after parameters.");
    return parameters;
  }

  List<Token> _parseParameterTokens() {
    List<Token> parameters = [];
    if (!check(TokenType.rightParen)) {
      do {
        if (check(TokenType.rightParen)) break;
        parameters.add(consume(TokenType.identifier, "Expect parameter name."));
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after parameters.");
    return parameters;
  }

  AstWidget flutterWidgetDeclaration() {
    Token name =
        consume(TokenType.identifier, "Expect widget name after 'flutter::'.");
    final parameters = _parseParameterNodes();

    final widgetFactory = widgetFactories[name.lexeme];
    if (widgetFactory != null) {
      return widgetFactory(parameters);
    }

    // Handle custom widgets
    return CustomAstWidget(name, parameters);
  }

  AstNode parameterValue() {
    if (match([TokenType.leftParen])) {
      return anonymousFunction();
    }
    if (match([TokenType.flutterParam])) {
      return flutterParameter();
    }
    return expression();
  }

  AstNode flutterParameter() {
    Token name = consume(TokenType.identifier,
        "Expect Flutter parameter type after 'parameter::'.");

    final parameterParsers = {
      'EdgeInsets': parseEdgeInsets,
      'MainAxisAlignment': parseMainAxisAlignment,
      'CrossAxisAlignment': parseCrossAxisAlignment,
      'TextStyle': parseTextStyle,
      'Color': parseColor,
      'FontWeight': parseFontWeight,
      'InputDecoration': parseInputDecoration,
      'Alignment': parseAlignment,
      'ScrollPhysics': parseScrollPhysics,
      'Icons': parseIcons,
    };

    for (final entry in parameterParsers.entries) {
      if (name.lexeme.contains(entry.key)) {
        return entry.value(name);
      }
    }

    throw error(name, "Unknown Flutter parameter type: ${name.lexeme}");
  }

  ScrollPhysics parseScrollPhysics(Token name) {
    consume(TokenType.leftParen, "Expect '(' after ScrollPhysics method.");
    const scrollPhysicsMap = {
      'AlwaysScrollableScrollPhysics': AlwaysScrollableScrollPhysics(),
      'BouncingScrollPhysics': BouncingScrollPhysics(),
      'ClampingScrollPhysics': ClampingScrollPhysics(),
      'NeverScrollableScrollPhysics': NeverScrollableScrollPhysics(),
    };
    final result = scrollPhysicsMap[name.lexeme];
    if (result == null) {
      throw error(name, "Unknown ScrollPhysics method: ${name.lexeme}");
    }
    consume(TokenType.rightParen, "Expect ')' after ScrollPhysics parameters.");
    return result;
  }

  Icons parseIcons(Token name) {
    consume(TokenType.leftParen, "Expect '(' after Icons method.");
    final result = iconsMap[name.lexeme] ?? CustomIcons(name.lexeme);
    consume(TokenType.rightParen, "Expect ')' after Icons parameters.");
    return result;
  }

  Alignment parseAlignment(Token name) {
    consume(TokenType.leftParen, "Expect '(' after Alignment method.");
    const alignmentMap = {
      'AlignmentTopLeft': AlignmentTopLeft(),
      'AlignmentTopCenter': AlignmentTopCenter(),
      'AlignmentTopRight': AlignmentTopRight(),
      'AlignmentCenterLeft': AlignmentCenterLeft(),
      'AlignmentCenterRight': AlignmentCenterRight(),
      'AlignmentBottomLeft': AlignmentBottomLeft(),
      'AlignmentBottomCenter': AlignmentBottomCenter(),
      'AlignmentBottomRight': AlignmentBottomRight(),
      'AlignmentCenter': AlignmentCenter(),
    };
    final result = alignmentMap[name.lexeme];
    if (result == null) {
      throw error(name, "Unknown Alignment method: ${name.lexeme}");
    }
    consume(TokenType.rightParen, "Expect ')' after Alignment parameters.");
    return result;
  }

  InputDecoration parseInputDecoration(Token name) {
    final parameters = _parseParameterNodes();
    return InputDecoration(
      icon: parameters['icon'],
      iconColor: parameters['iconColor'],
      label: parameters['label'],
      labelText: parameters['labelText'],
      labelStyle: parameters['labelStyle'],
      floatingLabelStyle: parameters['floatingLabelStyle'],
      helperText: parameters['helperText'],
      helperStyle: parameters['helperStyle'],
      helperMaxLines: parameters['helperMaxLines'],
      hintText: parameters['hintText'],
      hintStyle: parameters['hintStyle'],
      hintTextDirection: parameters['hintTextDirection'],
      hintMaxLines: parameters['hintMaxLines'],
      errorText: parameters['errorText'],
      errorStyle: parameters['errorStyle'],
      errorMaxLines: parameters['errorMaxLines'],
      floatingLabelBehavior: parameters['floatingLabelBehavior'],
      isCollapsed: parameters['isCollapsed'],
      isDense: parameters['isDense'],
      contentPadding: parameters['contentPadding'],
      prefixIcon: parameters['prefixIcon'],
      prefixIconColor: parameters['prefixIconColor'],
      prefix: parameters['prefix'],
      prefixText: parameters['prefixText'],
      prefixStyle: parameters['prefixStyle'],
      suffixIcon: parameters['suffixIcon'],
      suffixIconColor: parameters['suffixIconColor'],
      suffix: parameters['suffix'],
      suffixText: parameters['suffixText'],
      suffixStyle: parameters['suffixStyle'],
      counterText: parameters['counterText'],
      counterStyle: parameters['counterStyle'],
      filled: parameters['filled'],
      fillColor: parameters['fillColor'],
      focusColor: parameters['focusColor'],
      hoverColor: parameters['hoverColor'],
      errorBorder: parameters['errorBorder'],
      focusedBorder: parameters['focusedBorder'],
      focusedErrorBorder: parameters['focusedErrorBorder'],
      disabledBorder: parameters['disabledBorder'],
      enabledBorder: parameters['enabledBorder'],
      border: parameters['border'],
      enabled: parameters['enabled'],
      semanticCounterText: parameters['semanticCounterText'],
      alignLabelWithHint: parameters['alignLabelWithHint'],
    );
  }

  FontWeight parseFontWeight(Token name) {
    consume(TokenType.leftParen, "Expect '(' after FontWeight method.");
    const fontWeightMap = {
      'FontWeightNormal': FontWeightNormal(),
      'FontWeightBold': FontWeightBold(),
    };
    final result = fontWeightMap[name.lexeme];
    if (result == null) {
      throw error(name, "Unknown FontWeight method: ${name.lexeme}");
    }
    consume(TokenType.rightParen, "Expect ')' after FontWeight parameters.");
    return result;
  }

  Color parseColor(Token name) {
    final parameters = _parseParameterNodes();
    return Color(
      r: parameters['r'],
      g: parameters['g'],
      b: parameters['b'],
      a: parameters['a'],
    );
  }

  TextStyle parseTextStyle(Token name) {
    final parameters = _parseParameterNodes();
    return TextStyle(
      fontFamily: parameters['fontFamily'],
      fontSize: parameters['fontSize'],
      color: parameters['color'],
      fontWeight: parameters['fontWeight'],
    );
  }

  EdgeInsets parseEdgeInsets(Token name) {
    final parameters = _parseParameterNodes();

    final factory = edgeInsetsFactories[name.lexeme];
    if (factory != null) {
      return factory(parameters);
    } else {
      throw error(name, "Unknown EdgeInsets method: ${name.lexeme}");
    }
  }

  MainAxisAlignment parseMainAxisAlignment(Token name) {
    consume(TokenType.leftParen, "Expect '(' after EdgeInsets method.");
    const mainAxisAlignmentMap = {
      'MainAxisAlignmentStart': MainAxisAlignmentStart(),
      'MainAxisAlignmentCenter': MainAxisAlignmentCenter(),
      'MainAxisAlignmentEnd': MainAxisAlignmentEnd(),
      'MainAxisAlignmentSpaceBetween': MainAxisAlignmentSpaceBetween(),
      'MainAxisAlignmentSpaceAround': MainAxisAlignmentSpaceAround(),
      'MainAxisAlignmentSpaceEvenly': MainAxisAlignmentSpaceEvenly(),
    };
    final result = mainAxisAlignmentMap[name.lexeme];
    if (result == null) {
      throw error(name, "Unknown MainAxisAlignment method: ${name.lexeme}");
    }

    consume(TokenType.rightParen, "Expect ')' after EdgeInsets method.");
    return result;
  }

  CrossAxisAlignment parseCrossAxisAlignment(Token name) {
    consume(TokenType.leftParen, "Expect '(' after EdgeInsets method.");
    const crossAxisAlignmentMap = {
      'CrossAxisAlignmentStart': CrossAxisAlignmentStart(),
      'CrossAxisAlignmentCenter': CrossAxisAlignmentCenter(),
      'CrossAxisAlignmentEnd': CrossAxisAlignmentEnd(),
      'CrossAxisAlignmentStretch': CrossAxisAlignmentStretch(),
      'CrossAxisAlignmentBaseline': CrossAxisAlignmentBaseline(),
    };
    final result = crossAxisAlignmentMap[name.lexeme];
    if (result == null) {
      throw error(name, "Unknown CrossAxisAlignment method: ${name.lexeme}");
    }

    consume(TokenType.rightParen, "Expect ')' after EdgeInsets parameters.");
    return result;
  }

  AstNode varDeclaration() {
    Token keyword = previous();
    Token name = consume(TokenType.identifier, "Expect variable name.");
    AstNode? initializer;
    if (match([TokenType.assign])) {
      initializer = expression();
    }
    consume(TokenType.semicolon, "Expect ';' after variable declaration.");
    return VariableDeclaration(keyword, name, initializer);
  }

  AstNode functionDeclaration() {
    Token name = consume(TokenType.identifier, "Expect function name.");
    consume(TokenType.leftParen, "Expect '(' after function name.");
    final parameters = _parseParameterTokens();
    consume(TokenType.leftBrace, "Expect '{' before function body.");
    final body = block();
    return FunctionDeclaration(name, parameters, body);
  }

  AstNode statement() {
    if (match([TokenType.leftBrace])) {
      return block();
    } else if (match([TokenType.tartBreak])) {
      return breakStatement();
    } else {
      return expressionStatement();
    }
  }

  AstNode breakStatement() {
    Token keyword = previous();
    consume(TokenType.semicolon, "Expect ';' after 'break'.");
    return BreakStatement(keyword);
  }

  AstNode ifStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'if'.");
    AstNode condition = expression();
    consume(TokenType.rightParen, "Expect ')' after if condition.");
    AstNode thenBranch = statement();
    AstNode? elseBranch;
    if (match([TokenType.tartElse])) {
      elseBranch = statement();
    }
    return IfStatement(condition, thenBranch, elseBranch);
  }

  AstNode whileStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'while'.");
    AstNode condition = expression();
    consume(TokenType.rightParen, "Expect ')' after while condition.");
    AstNode body = statement();
    return WhileStatement(condition, body);
  }

  AstNode forStatement() {
    consume(TokenType.leftParen, "Expect '(' after 'for'.");
    // Regular for loop
    AstNode? initializer;
    if (match([TokenType.semicolon])) {
      initializer = null;
    } else if (match(
        [TokenType.tartVar, TokenType.tartConst, TokenType.tartFinal])) {
      initializer = varDeclaration();
    } else {
      initializer = expressionStatement();
    }

    AstNode? condition = !check(TokenType.semicolon) ? expression() : null;
    consume(TokenType.semicolon, "Expect ';' after loop condition.");

    AstNode? increment = !check(TokenType.rightParen) ? expression() : null;
    consume(TokenType.rightParen, "Expect ')' after for clauses.");

    AstNode body = statement();
    return ForStatement(initializer, condition, increment, body);
  }

  AstNode returnStatement() {
    Token keyword = previous();
    AstNode? value = !check(TokenType.semicolon) ? expression() : null;
    consume(TokenType.semicolon, "Expect ';' after return value.");
    return ReturnStatement(keyword, value);
  }

  Block block() {
    List<AstNode> statements = [];
    while (!check(TokenType.rightBrace) && !isAtEnd()) {
      statements.add(declaration());
    }
    consume(TokenType.rightBrace, "Expect '}' after block.");
    return Block(statements);
  }

  AstNode expressionStatement() {
    AstNode expr = expression();
    consume(TokenType.semicolon, "Expect ';' after expression.");
    return ExpressionStatement(expr);
  }

  AstNode expression() {
    return assignment();
  }

  AstNode assignment() {
    AstNode expr = logicalOr();
    if (match([
      TokenType.assign,
      TokenType.plusAssign,
      TokenType.minusAssign,
      TokenType.multiplyAssign,
      TokenType.divideAssign,
      TokenType.plusPlus,
      TokenType.minusMinus
    ])) {
      Token operator = previous();
      AstNode value;
      if (operator.type == TokenType.plusPlus ||
          operator.type == TokenType.minusMinus) {
        // For ++ and --, we don't need to parse another expression
        value = const Literal(1);
      } else {
        value = assignment();
      }
      if (expr is Variable) {
        return Assignment(expr.name, operator, value);
      }
      error(operator, "Invalid assignment target.");
    }
    return expr;
  }

  AstNode logicalOr() {
    AstNode expr = logicalAnd();
    while (match([TokenType.or])) {
      Token operator = previous();
      AstNode right = logicalAnd();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode logicalAnd() {
    AstNode expr = equality();
    while (match([TokenType.and])) {
      Token operator = previous();
      AstNode right = equality();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode equality() {
    AstNode expr = comparison();
    while (match([TokenType.notEqual, TokenType.equal])) {
      Token operator = previous();
      AstNode right = comparison();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode comparison() {
    AstNode expr = term();
    while (match([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      Token operator = previous();
      AstNode right = term();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode term() {
    AstNode expr = factor();
    while (match([TokenType.minus, TokenType.plus])) {
      Token operator = previous();
      AstNode right = factor();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode factor() {
    AstNode expr = unary();
    while (match([TokenType.divide, TokenType.multiply])) {
      Token operator = previous();
      AstNode right = unary();
      expr = BinaryExpression(expr, operator, right);
    }
    return expr;
  }

  AstNode unary() {
    if (match([TokenType.not, TokenType.minus])) {
      Token operator = previous();
      AstNode right = unary();
      return UnaryExpression(operator, right);
    }
    return call();
  }

  AstNode call() {
    AstNode expr = primary();
    while (true) {
      if (match([TokenType.leftParen])) {
        expr = finishCall(expr);
      } else if (match([TokenType.dot])) {
        Token name =
            consume(TokenType.identifier, "Expect property name after '.'.");

        List<Token>? arguments;
        if (check(TokenType.leftParen)) {
          advance();
          arguments = _parseParameterTokens();
        }
        expr = MemberAccess(expr, name, arguments);
      } else if (match([TokenType.leftBracket])) {
        AstNode index = expression();
        consume(TokenType.rightBracket, "Expect ']' after index.");
        expr = IndexAccess(expr, index);
      } else {
        break;
      }
    }
    return expr;
  }

  AstNode finishCall(AstNode callee) {
    Map<String, AstNode> args = _parseParameterNodes(false, false);
    return CallExpression(callee, previous(), args.values.toList());
  }

  AstNode primary() {
    if (match([TokenType.tartNull])) return const Literal(null);
    if (match([
      TokenType.integer,
      TokenType.double,
      TokenType.string,
      TokenType.boolean
    ])) {
      return Literal(previous().literal);
    }

    if (match([TokenType.identifier])) return Variable(previous());

    if (match([TokenType.leftParen])) {
      AstNode expr = expression();
      consume(TokenType.rightParen, "Expect ')' after expression.");
      return expr;
    }

    if (match([TokenType.assign])) {
      return Assignment(previous(), peek(), expression());
    }

    if (match([TokenType.flutterWidget])) {
      return flutterWidgetDeclaration();
    }

    if (match([TokenType.flutterParam])) {
      return flutterParameter();
    }

    if (match([TokenType.leftParen])) {
      return anonymousFunction();
    }

    if (match([TokenType.leftBracket])) {
      return listOrSetLiteral();
    }

    if (match([TokenType.leftBrace])) {
      return mapLiteral();
    }

    // if (match([TokenType.tartToString])) {
    //   consume(TokenType.leftParen, "Expect '(' after 'toString'.");
    //   AstNode expr = expression();
    //   consume(TokenType.rightParen, "Expect ')' after expression in toString.");
    //   return ToString(expr);
    // }

    throw error(peek(), "Expected expression.");
  }

  AstNode anonymousFunction() {
    List<Token> parameters = _parseParameterTokens();
    consume(TokenType.leftBrace, "Expect '{' before function body.");
    Block body = block();
    return AnonymousFunction(parameters, body);
  }

  AstNode listOrSetLiteral() {
    List<AstNode> elements = [];
    if (!check(TokenType.rightBracket)) {
      do {
        if (check(TokenType.rightBracket)) break;
        elements.add(expression());
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightBracket, "Expect ']' after list or set elements.");

    // If we have a colon after the closing bracket, it's a set
    if (match([TokenType.colon])) {
      return SetLiteral(elements);
    }

    return ListLiteral(elements);
  }

  AstNode mapLiteral() {
    List<MapEntry> entries = [];
    if (!check(TokenType.rightBrace)) {
      do {
        AstNode key = expression();
        consume(TokenType.colon, "Expect ':' after map key.");
        AstNode value = expression();
        entries.add(MapEntry(key, value));
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightBrace, "Expect '}' after map entries.");
    return MapLiteral(entries);
  }

  bool match(List<TokenType> types) {
    if (types.contains(peek().type)) {
      advance();
      return true;
    }
    return false;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();
    throw error(peek(), message);
  }

  bool check(TokenType type) {
    if (isAtEnd()) return false;
    return peek().type == type;
  }

  Token advance() {
    if (!isAtEnd()) {
      current++;
      _nextToken = null;
    }
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.eof;
  }

  Token peek() {
    _nextToken ??= tokens[current];
    return _nextToken!;
  }

  Token previous() {
    return tokens[current - 1];
  }

  Exception error(Token token, String message) {
    errors.add(ParseError(
        token, message, sourceCode)); // Pass sourceCode to ParseError
    return ParseException(message);
  }

  void synchronize() {
    advance();
    while (!isAtEnd()) {
      if (previous().type == TokenType.semicolon) return;
      switch (peek().type) {
        case TokenType.tartVar:
        case TokenType.tartFor:
        case TokenType.tartIf:
        case TokenType.tartWhile:
        case TokenType.tartReturn:
          return;
        default:
      }
      advance();
    }
  }

  AstNode synchronizeToNextDeclaration() {
    if (!isAtEnd()) {
      return declaration();
    }
    throw error(peek(), "End of file");
  }

  AstNode importDeclaration() {
    Token importToken = previous();
    String path =
        consume(TokenType.string, "Expect string after 'import'.").lexeme;
    consume(TokenType.semicolon, "Expect ';' after import statement.");
    return ImportStatement(importToken, path);
  }

  AstNode tryStatement() {
    consume(TokenType.tartTry, "Expect 'try' keyword.");
    AstNode tryBlock = block();
    List<CatchClause> catchClauses = [];
    AstNode? finallyBlock;

    while (match([TokenType.tartCatch])) {
      Token? exceptionType;
      Token? exceptionVariable;
      if (check(TokenType.identifier)) {
        exceptionType = advance();
        if (check(TokenType.identifier)) {
          exceptionVariable = advance();
        }
      }
      consume(TokenType.leftBrace, "Expect '{' before catch block.");
      AstNode catchBlock = block();
      catchClauses
          .add(CatchClause(exceptionType, exceptionVariable, catchBlock));
    }

    if (match([TokenType.tartFinally])) {
      consume(TokenType.leftBrace, "Expect '{' before finally block.");
      finallyBlock = block();
    }

    return TryStatement(tryBlock, catchClauses, finallyBlock);
  }

  AstNode throwStatement() {
    consume(TokenType.tartThrow, "Expect 'throw' keyword.");
    final expr = expression();
    consume(TokenType.semicolon, "Expect ';' after throw statement.");
    return ThrowStatement(expr);
  }
}

class ParseError {
  final Token token;
  final String message;
  final String sourceCode;

  ParseError(this.token, this.message, this.sourceCode);

  @override
  String toString() {
    if (token.type == TokenType.eof) {
      return "Error at end: $message";
    } else {
      String errorLine = _getErrorLine();
      String pointer = _getErrorPointer();
      return "Error at '${token.lexeme}' (line ${token.line}):\n$errorLine\n$pointer\n$message";
    }
  }

  String _getErrorLine() {
    List<String> lines = sourceCode.split('\n');
    if (token.line > 0 && token.line <= lines.length) {
      return lines[token.line - 1];
    }
    return "";
  }

  String _getErrorPointer() {
    int column = token.column;
    // ignore: prefer_interpolation_to_compose_strings
    return ' ' * (column - 1) + '^';
  }
}

class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => message;
}
