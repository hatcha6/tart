// ignore_for_file: constant_identifier_names

import 'token.dart';

class Lexer {
  final String source;
  final List<Token> tokens = [];
  int start = 0;
  int current = 0;
  int line = 1;

  static final Map<String, TokenType> keywords = {
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
    'flutter::': TokenType.flutterWidget,
  };

  Lexer(this.source);

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    tokens.add(Token(TokenType.eof, "", null, line));
    return tokens;
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
        if (match(':')) {
          // Check for 'flutter::' keyword
          if (source.substring(start, current - 2) == 'flutter') {
            addToken(TokenType.flutterWidget);
          } else {
            addToken(TokenType.colon);
          }
        } else {
          addToken(TokenType.colon);
        }
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
          // Single-line comment
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else if (match('*')) {
          // Multi-line comment
          while (!isAtEnd() && !(peek() == '*' && peekNext() == '/')) {
            if (peek() == '\n') line++;
            advance();
          }
          if (!isAtEnd()) {
            advance(); // consume *
            advance(); // consume /
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
        string();
        break;
      case "'":
        string();
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
    while (isAlphaNumeric(peek())) {
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
    while (isDigit(peek())) {
      advance();
    }

    if (peek() == '.' && isDigit(peekNext())) {
      advance();
      while (isDigit(peek())) {
        advance();
      }
      addToken(
          TokenType.double, double.parse(source.substring(start, current)));
    } else {
      addToken(TokenType.integer, int.parse(source.substring(start, current)));
    }
  }

  void string() {
    String quote = source[start];
    while (peek() != quote && !isAtEnd()) {
      if (peek() == '\n') line++;
      advance();
    }

    if (isAtEnd()) {
      // Unterminated string
      addToken(TokenType.unknown);
      return;
    }

    advance(); // The closing quote

    String value = source.substring(start + 1, current - 1);
    addToken(TokenType.string, value);
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;
    current++;
    return true;
  }

  String peek() {
    return isAtEnd() ? '0' : source[current];
  }

  String peekNext() {
    return (current + 1 >= source.length) ? '0' : source[current + 1];
  }

  bool isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }

  bool isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool isAtEnd() {
    return current >= source.length;
  }

  String advance() {
    if (isAtEnd()) return '0';
    return source[current++];
  }

  void addToken(TokenType type, [Object? literal]) {
    String text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
  }
}
