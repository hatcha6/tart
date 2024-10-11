library tart;

enum TokenType {
  tartFunction,
  tartIf,
  tartElse,
  tartSwitch,
  tartCase,
  tartDefault,
  tartFor,
  tartWhile,
  tartDo,
  tartBreak,
  tartContinue,
  tartReturn,
  tartTry,
  tartCatch,
  tartFinally,
  tartThrow,
  tartAssert,
  tartConst,
  tartFinal,
  tartIn,
  tartVar,
  tartLate,
  required,
  static,
  tartAsync,
  tartAwait,
  tartYield,

  // Literals
  integer,
  double,
  string,
  boolean,
  tartNull,

  // Identifiers
  identifier,

  // Operators
  plus,
  plusPlus,
  minus,
  minusMinus,
  multiply,
  divide,
  modulo,
  equal,
  notEqual,
  greater,
  less,
  greaterEqual,
  lessEqual,
  and,
  or,
  not,
  increment,
  decrement,
  assign,
  plusAssign,
  minusAssign,
  multiplyAssign,
  divideAssign,

  // Delimiters
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  leftBracket,
  rightBracket,
  semicolon,
  colon,
  comma,
  dot,

  // Special
  eof,
  unknown,
  flutterWidget,
  flutterParam,
  // tartToString,
  tartImport,
}

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;
  final int column;

  const Token(this.type, this.lexeme, this.literal, this.line, this.column);

  @override
  String toString() {
    String literalStr = literal != null ? ' ($literal)' : '';
    return 'Token(type: $type, lexeme: "$lexeme"$literalStr, line: $line)';
  }
}
