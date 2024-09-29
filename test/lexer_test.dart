import 'package:flutter_test/flutter_test.dart';

import 'package:tart_dev/lexer.dart';
import 'package:tart_dev/token.dart';

void main() {
  late Lexer lexer;

  setUp(() {
    lexer = Lexer();
  });

  group('Lexer', () {
    test('scans single-character tokens', () {
      final tokens = lexer.scanTokens('(){},;');
      expect(tokens.map((t) => t.type), [
        TokenType.leftParen,
        TokenType.rightParen,
        TokenType.leftBrace,
        TokenType.rightBrace,
        TokenType.comma,
        TokenType.semicolon,
        TokenType.eof,
      ]);
    });

    test('scans operators', () {
      final tokens = lexer.scanTokens('+ - * / = == != < <= > >=');
      expect(tokens.map((t) => t.type), [
        TokenType.plus,
        TokenType.minus,
        TokenType.multiply,
        TokenType.divide,
        TokenType.assign,
        TokenType.equal,
        TokenType.notEqual,
        TokenType.less,
        TokenType.lessEqual,
        TokenType.greater,
        TokenType.greaterEqual,
        TokenType.eof,
      ]);
    });

    test('scans keywords', () {
      final tokens = lexer.scanTokens('if else var true false null');
      expect(tokens.map((t) => t.type), [
        TokenType.tartIf,
        TokenType.tartElse,
        TokenType.tartVar,
        TokenType.boolean,
        TokenType.boolean,
        TokenType.tartNull,
        TokenType.eof,
      ]);
    });

    test('scans identifiers', () {
      final tokens = lexer.scanTokens('foo bar baz');
      expect(tokens.map((t) => t.type), [
        TokenType.identifier,
        TokenType.identifier,
        TokenType.identifier,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.lexeme), ['foo', 'bar', 'baz', '']);
    });

    test('scans numbers', () {
      final tokens = lexer.scanTokens('123 45.67');
      expect(tokens.map((t) => t.type), [
        TokenType.integer,
        TokenType.double,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.literal), [123, 45.67, null]);
    });

    test('scans strings', () {
      final tokens = lexer.scanTokens('"Hello, world!" \'Single quoted\'');
      expect(tokens.map((t) => t.type), [
        TokenType.string,
        TokenType.string,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.literal),
          ['Hello, world!', 'Single quoted', null]);
    });

    test('handles comments', () {
      final tokens = lexer.scanTokens(
          '// This is a comment\n/* This is a\nmulti-line comment */\ncode');
      expect(tokens.map((t) => t.type), [
        TokenType.identifier,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.lexeme), ['code', '']);
    });

    test('tracks line numbers', () {
      final tokens = lexer.scanTokens('line1\nline2\nline3');
      expect(tokens.map((t) => t.line), [1, 2, 3, 3]);
    });
  });

  test('toString returns correct string representation', () {
    const tokenWithLiteral = Token(
      TokenType.string,
      '"Hello"',
      'Hello',
      1,
    );
    expect(tokenWithLiteral.toString(),
        'Token(type: TokenType.string, lexeme: ""Hello"" (Hello), line: 1)');

    const tokenWithoutLiteral = Token(
      TokenType.eof,
      '',
      null,
      2,
    );
    expect(tokenWithoutLiteral.toString(),
        'Token(type: TokenType.eof, lexeme: "", line: 2)');
  });
}
