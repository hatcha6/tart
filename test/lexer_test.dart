import 'package:flutter_test/flutter_test.dart';

import 'package:tart_dev/lexer.dart';
import 'package:tart_dev/token.dart';

void main() {
  group('Lexer', () {
    test('scans single-character tokens', () {
      final lexer = Lexer('(){},;');
      final tokens = lexer.scanTokens();
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
      final lexer = Lexer('+ - * / = == != < <= > >=');
      final tokens = lexer.scanTokens();
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
      final lexer = Lexer('if else var true false null');
      final tokens = lexer.scanTokens();
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
      final lexer = Lexer('foo bar baz');
      final tokens = lexer.scanTokens();
      expect(tokens.map((t) => t.type), [
        TokenType.identifier,
        TokenType.identifier,
        TokenType.identifier,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.lexeme), ['foo', 'bar', 'baz', '']);
    });

    test('scans numbers', () {
      final lexer = Lexer('123 45.67');
      final tokens = lexer.scanTokens();
      expect(tokens.map((t) => t.type), [
        TokenType.integer,
        TokenType.double,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.literal), [123, 45.67, null]);
    });

    test('scans strings', () {
      final lexer = Lexer('"Hello, world!" \'Single quoted\'');
      final tokens = lexer.scanTokens();
      expect(tokens.map((t) => t.type), [
        TokenType.string,
        TokenType.string,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.literal),
          ['Hello, world!', 'Single quoted', null]);
    });

    test('handles comments', () {
      final lexer = Lexer(
          '// This is a comment\n/* This is a\nmulti-line comment */\ncode');
      final tokens = lexer.scanTokens();
      expect(tokens.map((t) => t.type), [
        TokenType.identifier,
        TokenType.eof,
      ]);
      expect(tokens.map((t) => t.lexeme), ['code', '']);
    });

    test('tracks line numbers', () {
      final lexer = Lexer('line1\nline2\nline3');
      final tokens = lexer.scanTokens();
      expect(tokens.map((t) => t.line), [1, 2, 3, 3]);
    });
  });
}
