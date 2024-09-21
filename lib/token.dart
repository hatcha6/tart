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
  tartVar,
  tartLate,
  required,
  static,
  async,
  await,
  yield,

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
}

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() => '$type $lexeme $literal';
}
