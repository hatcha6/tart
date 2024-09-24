library tart;

import 'token.dart';
import 'ast.dart';
import 'dart:async';

class Parser {
  List<Token> tokens = const [];
  int current = 0;
  Token? _nextToken;
  final List<ParseError> errors = [];

  Parser();

  List<AstNode> parse(List<Token> tokens) {
    this.tokens = tokens;
    current = 0;
    List<AstNode> statements = [];
    while (!isAtEnd()) {
      statements.add(declaration());
    }
    return statements;
  }

  Future<List<AstNode>> parseAsync(List<Token> tokens) async {
    this.tokens = tokens;
    current = 0;
    List<Future<AstNode>> futures = [];

    while (!isAtEnd()) {
      futures.add(Future(() => declaration()));
      // Skip to the next top-level declaration
      synchronizeToNextDeclaration();
    }

    return await Future.wait(futures);
  }

  AstNode declaration() {
    try {
      switch (peek().type) {
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
        default:
          throw error(peek(), "Expected declaration.");
      }
    } catch (e) {
      synchronize();
      return const EndOfFile();
    }
  }

  AstWidget flutterWidgetDeclaration() {
    Token name =
        consume(TokenType.identifier, "Expect widget name after 'flutter::'.");
    consume(TokenType.leftParen, "Expect '(' after widget name.");

    Map<String, AstNode> parameters = {};
    if (!check(TokenType.rightParen)) {
      do {
        Token paramName =
            consume(TokenType.identifier, "Expect parameter name.");
        consume(TokenType.colon, "Expect ':' after parameter name.");
        AstNode paramValue = parameterValue();
        parameters[paramName.lexeme] = paramValue;
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after widget parameters.");

    switch (name.lexeme) {
      case 'Text':
        return Text(name, (parameters['text'] as Literal).value);
      case 'Column':
        return Column(name, parameters['children'] as List<AstWidget>);
      case 'Row':
        return Row(name, parameters['children'] as List<AstWidget>);
      case 'Container':
        return Container(name, parameters['child'] as AstWidget);
      case 'Image':
        return Image(name, (parameters['url'] as Literal).value);
      case 'Padding':
        return Padding(name, parameters['padding'] as EdgeInsets,
            parameters['child'] as AstWidget);
      case 'Center':
        return Center(name, parameters['child'] as AstWidget);
      case 'SizedBox':
        return SizedBox(name,
            width: (parameters['width'] as Literal?)?.value.toDouble(),
            height: (parameters['height'] as Literal?)?.value.toDouble(),
            child: parameters['child'] as AstWidget?);
      case 'Expanded':
        return Expanded(name, parameters['child'] as AstWidget,
            flex: (parameters['flex'] as Literal?)?.value as int? ?? 1);
      case 'ElevatedButton':
        return ElevatedButton(name, parameters['child'] as AstWidget,
            parameters['onPressed'] as FunctionDeclaration);
      default:
        throw error(name, "Unknown Flutter widget: ${name.lexeme}");
    }
  }

  AstNode parameterValue() {
    if (match([TokenType.leftParen])) {
      return anonymousFunction();
    }
    return expression();
  }

  AstNode varDeclaration() {
    Token name = consume(TokenType.identifier, "Expect variable name.");
    AstNode? initializer;
    if (match([TokenType.assign])) {
      initializer = expression();
    }
    consume(TokenType.semicolon, "Expect ';' after variable declaration.");
    return VariableDeclaration(name, initializer);
  }

  AstNode functionDeclaration() {
    Token name = consume(TokenType.identifier, "Expect function name.");
    consume(TokenType.leftParen, "Expect '(' after function name.");
    List<Token> parameters = [];
    if (!check(TokenType.rightParen)) {
      do {
        parameters.add(consume(TokenType.identifier, "Expect parameter name."));
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after parameters.");
    consume(TokenType.leftBrace, "Expect '{' before function body.");
    final body = block();
    return FunctionDeclaration(name, parameters, body);
  }

  AstNode statement() {
    if (match([TokenType.leftBrace])) {
      return block();
    } else {
      return expressionStatement();
    }
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
        expr = BinaryExpression(expr, name, Variable(name));
      } else {
        break;
      }
    }
    return expr;
  }

  AstNode finishCall(AstNode callee) {
    List<AstNode> arguments = [];
    if (!check(TokenType.rightParen)) {
      do {
        arguments.add(expression());
      } while (match([TokenType.comma]));
    }
    Token paren = consume(TokenType.rightParen, "Expect ')' after arguments.");
    return CallExpression(callee, paren, arguments);
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

    if (match([TokenType.leftParen])) {
      return anonymousFunction();
    }

    throw error(peek(), "Expected expression.");
  }

  AstNode anonymousFunction() {
    List<Token> parameters = [];
    if (!check(TokenType.rightParen)) {
      do {
        parameters.add(consume(TokenType.identifier, "Expect parameter name."));
      } while (match([TokenType.comma]));
    }
    consume(TokenType.rightParen, "Expect ')' after parameters.");
    consume(TokenType.leftBrace, "Expect '{' before function body.");
    Block body = block();
    return AnonymousFunction(parameters, body);
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
    errors.add(ParseError(token, message));
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

  void synchronizeToNextDeclaration() {
    while (!isAtEnd()) {
      switch (peek().type) {
        case TokenType.flutterWidget:
        case TokenType.tartVar:
        case TokenType.tartConst:
        case TokenType.tartFinal:
        case TokenType.tartFunction:
          return;
        default:
          advance();
      }
    }
  }
}

class ParseError {
  final Token token;
  final String message;

  ParseError(this.token, this.message);

  @override
  String toString() {
    if (token.type == TokenType.eof) {
      return "Error at end: $message";
    } else {
      return "Error at '${token.lexeme}' (line ${token.line}): $message";
    }
  }
}

class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => message;
}
