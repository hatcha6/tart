library tart;

import 'dart:collection';
import 'token.dart';
import 'dart:isolate';
import 'dart:typed_data';

class Lexer {
  String source = '';
  final List<Token> tokens = [];
  int start = 0;
  int current = 0;
  int line = 1;
  Uint8List _stringBuffer = Uint8List(1024); // Preallocate 1KB
  int _stringBufferIndex = 0;

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
    'async': TokenType.tartAsync,
    'await': TokenType.tartAwait,
    'yield': TokenType.tartYield,
    'true': TokenType.boolean,
    'false': TokenType.boolean,
    'null': TokenType.tartNull,
    'toString': TokenType.tartToString,
    'import': TokenType.tartImport,
  };

  static const int _maxCacheSize = 1000; // Adjust as needed
  static final LinkedHashMap<String, Token> _tokenCache = LinkedHashMap();

  Lexer();

  void reset() {
    source = '';
    tokens.clear();
    start = 0;
    current = 0;
    line = 1;
    _stringBufferIndex = 0;
    _stringBuffer.setAll(0, Uint8List(1024));
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

    tokens.add(_getCachedToken(TokenType.eof, "", null, line, source.length));
    return tokens;
  }

  bool hasNewToken() => tokens.isNotEmpty;

  Token getLastToken() => tokens.removeLast();

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
    _stringBufferIndex = 0;
    while (peek() != quote && !isAtEnd()) {
      if (peek() == '\n') line++;
      int charCode = advance().codeUnitAt(0);

      if (_stringBufferIndex >= _stringBuffer.length) {
        Uint8List newBuffer = Uint8List(_stringBuffer.length * 2);
        newBuffer.setRange(0, _stringBuffer.length, _stringBuffer);
        _stringBuffer = newBuffer;
      }

      _stringBuffer[_stringBufferIndex++] = charCode;
    }

    if (isAtEnd()) {
      addToken(TokenType.unknown);
      return;
    }

    advance(); // The closing quote

    String result = String.fromCharCodes(_stringBuffer, 0, _stringBufferIndex);
    addToken(TokenType.string, result);
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
    int column = start - source.lastIndexOf('\n', start);
    tokens.add(_getCachedToken(type, text, literal, line, column));
  }

  Token _getCachedToken(
      TokenType type, String lexeme, Object? literal, int line, int column) {
    String key = '$type:$lexeme:$literal:$line:$column';
    Token? token = _tokenCache[key];

    if (token != null) {
      // Move the accessed token to the end (most recently used)
      _tokenCache.remove(key);
      _tokenCache[key] = token;
      return token;
    }

    token = Token(type, lexeme, literal, line, column);

    if (_tokenCache.length >= _maxCacheSize) {
      // Remove the least recently used item (first item)
      _tokenCache.remove(_tokenCache.keys.first);
    }

    _tokenCache[key] = token;
    return token;
  }
}
