library tart;

import 'dart:collection';
import 'token.dart';
import 'dart:isolate';

class Lexer {
  String source = '';
  final List<Token> tokens = [];
  int start = 0;
  int current = 0;
  int line = 1;
  final StringBuffer _lexemeBuffer = StringBuffer();

  static final Map<String, TokenType> keywords = {
    'flutter::': TokenType.flutterWidget,
    'f:': TokenType.flutterWidget, // Add the new shorthand
    'parameter::': TokenType.flutterParam,
    'p:': TokenType.flutterParam,
    'function': TokenType.tartFunction,
    'if': TokenType.tartIf,
    'else': TokenType.tartElse,
    'switch': TokenType.tartSwitch,
    'case': TokenType.tartCase,
    'default': TokenType.tartDefault,
    'for': TokenType.tartFor,
    'while': TokenType.tartWhile,
    'do': TokenType.tartDo,
    'break': TokenType.tartBreak,
    'continue': TokenType.tartContinue,
    'return': TokenType.tartReturn,
    'try': TokenType.tartTry,
    'catch': TokenType.tartCatch,
    'finally': TokenType.tartFinally,
    'throw': TokenType.tartThrow,
    'assert': TokenType.tartAssert,
    'const': TokenType.tartConst,
    'final': TokenType.tartFinal,
    'var': TokenType.tartVar,
    'late': TokenType.tartLate,
    'required': TokenType.required,
    'static': TokenType.static,
    'async': TokenType.async,
    'await': TokenType.await,
    'yield': TokenType.yield,
    'true': TokenType.boolean,
    'false': TokenType.boolean,
    'null': TokenType.tartNull,
    'toString': TokenType.tartToString,
  };

  static final Map<String, Token> _tokenCache = HashMap();

  Lexer();

  void reset() {
    source = '';
    tokens.clear();
    start = 0;
    current = 0;
    line = 1;
    _lexemeBuffer.clear();
  }

  List<Token> scanTokens(String source) {
    reset();
    this.source = source;
    start = 0;
    current = 0;
    line = 1;
    tokens.clear();

    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    tokens.add(_getCachedToken(TokenType.eof, "", null, line));
    return tokens;
  }

  static const int chunkSize = 1000; // Adjust based on your needs

  Future<List<Token>> scanTokensAsync(String source) async {
    this.source = source;
    List<Token> allTokens = [];

    int numChunks = (source.length / chunkSize).ceil();
    List<Future<List<Token>>> futures = [];

    for (int i = 0; i < numChunks; i++) {
      int start = i * chunkSize;
      int end = (i + 1) * chunkSize;
      if (end > source.length) end = source.length;

      futures.add(_processChunk(source.substring(start, end), start));
    }

    List<List<Token>> results = await Future.wait(futures);
    for (var tokens in results) {
      allTokens.addAll(tokens);
    }

    allTokens.sort((a, b) => a.line.compareTo(b.line));
    return allTokens;
  }

  Future<List<Token>> _processChunk(String chunk, int offset) async {
    return await Isolate.run(() {
      final lexer = Lexer()
        ..source = chunk
        ..start = 0
        ..current = 0
        ..line = _calculateStartingLine(offset);

      final tokens = <Token>[];

      while (!lexer.isAtEnd()) {
        lexer.scanNextToken();
        if (lexer.hasNewToken()) {
          tokens.add(_createAdjustedToken(lexer.getLastToken(), offset));
        }
      }

      return tokens;
    });
  }

  int _calculateStartingLine(int offset) => offset ~/ chunkSize;

  bool hasNewToken() => tokens.isNotEmpty;

  Token getLastToken() => tokens.removeLast();

  Token _createAdjustedToken(Token token, int offset) {
    return Token(
      token.type,
      token.lexeme,
      token.literal,
      _adjustLineNumber(token.line, offset),
    );
  }

  int _adjustLineNumber(int line, int offset) =>
      line + _calculateStartingLine(offset);

  void scanNextToken() {
    start = current;
    scanToken();
  }

  void scanToken() {
    String c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.leftParen);
        break;
      case ')':
        addToken(TokenType.rightParen);
        break;
      case '{':
        addToken(TokenType.leftBrace);
        break;
      case '}':
        addToken(TokenType.rightBrace);
        break;
      case '[':
        addToken(TokenType.leftBracket);
        break;
      case ']':
        addToken(TokenType.rightBracket);
        break;
      case ';':
        addToken(TokenType.semicolon);
        break;
      case ':':
        addToken(TokenType.colon);
        break;
      case ',':
        addToken(TokenType.comma);
        break;
      case '.':
        addToken(TokenType.dot);
        break;
      case '+':
        addToken(match('=')
            ? TokenType.plusAssign
            : match('+')
                ? TokenType.plusPlus
                : TokenType.plus);
        break;
      case '-':
        addToken(match('=')
            ? TokenType.minusAssign
            : match('-')
                ? TokenType.minusMinus
                : TokenType.minus);
        break;
      case '*':
        addToken(match('=') ? TokenType.multiplyAssign : TokenType.multiply);
        break;
      case '/':
        if (match('/')) {
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else if (match('*')) {
          while (!isAtEnd() && !(peek() == '*' && peekNext() == '/')) {
            if (peek() == '\n') line++;
            advance();
          }
          if (!isAtEnd()) {
            advance();
            advance();
          }
        } else {
          addToken(match('=') ? TokenType.divideAssign : TokenType.divide);
        }
        break;
      case '%':
        addToken(TokenType.modulo);
        break;
      case '!':
        addToken(match('=') ? TokenType.notEqual : TokenType.not);
        break;
      case '=':
        addToken(match('=') ? TokenType.equal : TokenType.assign);
        break;
      case '<':
        addToken(match('=') ? TokenType.lessEqual : TokenType.less);
        break;
      case '>':
        addToken(match('=') ? TokenType.greaterEqual : TokenType.greater);
        break;
      case '&':
        addToken(match('&') ? TokenType.and : TokenType.unknown);
        break;
      case '|':
        addToken(match('|') ? TokenType.or : TokenType.unknown);
        break;
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace
        break;
      case '\n':
        line++;
        break;
      case '"':
      case "'":
        string(c);
        break;
      case 'p':
        if (match(':')) {
          addToken(TokenType.flutterParam);
        } else if (source.length >= current + 10 &&
            source.substring(current - 1, current + 10) == 'parameter::') {
          advance(10);
          addToken(TokenType.flutterParam);
        } else {
          identifier();
        }
        break;
      case 'f':
        if (match(':')) {
          addToken(TokenType.flutterWidget);
        } else if (match('p')) {
          addToken(TokenType.flutterParam);
        } else if (source.length >= current + 8 &&
            source.substring(current - 1, current + 8) == 'flutter::') {
          advance(8);
          addToken(TokenType.flutterWidget);
        } else {
          identifier();
        }
        break;
      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          addToken(TokenType.unknown);
        }
        break;
    }
  }

  void identifier() {
    while (peek() != null && isAlphaNumeric(peek()!)) {
      advance();
    }

    String text = source.substring(start, current);
    TokenType type = keywords[text] ?? TokenType.identifier;

    if (type == TokenType.boolean) {
      addToken(type, text == 'true');
    } else {
      addToken(type);
    }
  }

  void number() {
    while (peek() != null && isDigit(peek()!)) {
      advance();
    }

    if (peek() == '.' && (peekNext() != null && isDigit(peekNext()!))) {
      advance();
      while (peek() != null && isDigit(peek()!)) {
        advance();
      }
      addToken(
          TokenType.double, double.parse(source.substring(start, current)));
    } else {
      addToken(TokenType.integer, int.parse(source.substring(start, current)));
    }
  }

  void string(String quote) {
    _lexemeBuffer.clear();
    while (peek() != quote && !isAtEnd()) {
      if (peek() == '\n') line++;
      _lexemeBuffer.write(advance());
    }

    if (isAtEnd()) {
      addToken(TokenType.unknown);
      return;
    }

    advance(); // The closing quote

    addToken(TokenType.string, _lexemeBuffer.toString());
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;
    current++;
    return true;
  }

  String? peek() {
    return isAtEnd() ? null : source[current];
  }

  String? peekNext() {
    return (current + 1 >= source.length) ? null : source[current + 1];
  }

  bool isAlpha(String c) {
    int code = c.codeUnitAt(0);
    return (code >= 97 && code <= 122) || // a-z
        (code >= 65 && code <= 90) || // A-Z
        code == 95; // _
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }

  bool isDigit(String c) {
    int code = c.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool isAtEnd() {
    return current >= source.length;
  }

  String advance([int count = 1]) {
    String result = source[current];
    current += count;
    return result;
  }

  void addToken(TokenType type, [Object? literal]) {
    String text = source.substring(start, current);
    tokens.add(_getCachedToken(type, text, literal, line));
  }

  Token _getCachedToken(
      TokenType type, String lexeme, Object? literal, int line) {
    String key = '$type:$lexeme:$literal:$line';
    return _tokenCache.putIfAbsent(
        key, () => Token(type, lexeme, literal, line));
  }
}
