import 'package:flutter_test/flutter_test.dart';
import 'package:tart_dev/parser.dart';
import 'package:tart_dev/token.dart';
import 'package:tart_dev/ast.dart';

void main() {
  late Parser parser;

  setUp(() {
    parser = Parser();
  });

  group('Parser', () {
    test('parses variable declarations', () {
      final tokens = [
        const Token(TokenType.tartVar, 'var', null, 1),
        const Token(TokenType.identifier, 'x', null, 1),
        const Token(TokenType.assign, '=', null, 1),
        const Token(TokenType.integer, '42', 42, 1),
        const Token(TokenType.semicolon, ';', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<VariableDeclaration>());
      final varDecl = result[0] as VariableDeclaration;
      expect(varDecl.name.lexeme, 'x');
      expect(varDecl.initializer, isA<Literal>());
      expect((varDecl.initializer as Literal).value, 42);
    });

    test('parses function declarations', () {
      final tokens = [
        const Token(TokenType.tartFunction, 'function', null, 1),
        const Token(TokenType.identifier, 'foo', null, 1),
        const Token(TokenType.leftParen, '(', null, 1),
        const Token(TokenType.rightParen, ')', null, 1),
        const Token(TokenType.leftBrace, '{', null, 1),
        const Token(TokenType.rightBrace, '}', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<FunctionDeclaration>());
      final funcDecl = result[0] as FunctionDeclaration;
      expect(funcDecl.name.lexeme, 'foo');
      expect(funcDecl.parameters, isEmpty);
      expect(funcDecl.body.statements, isEmpty);
    });

    test('parses if statements', () {
      final tokens = [
        const Token(TokenType.tartIf, 'if', null, 1),
        const Token(TokenType.leftParen, '(', null, 1),
        const Token(TokenType.boolean, 'true', true, 1),
        const Token(TokenType.rightParen, ')', null, 1),
        const Token(TokenType.leftBrace, '{', null, 1),
        const Token(TokenType.rightBrace, '}', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<IfStatement>());
      final ifStmt = result[0] as IfStatement;
      expect(ifStmt.condition, isA<Literal>());
      expect((ifStmt.condition as Literal).value, true);
      expect(ifStmt.thenBranch, isA<Block>());
      expect((ifStmt.thenBranch as Block).statements, isEmpty);
      expect(ifStmt.elseBranch, isNull);
    });

    test('parses while statements', () {
      final tokens = [
        const Token(TokenType.tartWhile, 'while', null, 1),
        const Token(TokenType.leftParen, '(', null, 1),
        const Token(TokenType.boolean, 'true', true, 1),
        const Token(TokenType.rightParen, ')', null, 1),
        const Token(TokenType.leftBrace, '{', null, 1),
        const Token(TokenType.rightBrace, '}', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<WhileStatement>());
      final whileStmt = result[0] as WhileStatement;
      expect(whileStmt.condition, isA<Literal>());
      expect((whileStmt.condition as Literal).value, true);
      expect(whileStmt.body, isA<Block>());
      expect((whileStmt.body as Block).statements, isEmpty);
    });

    test('parses for statements', () {
      final tokens = [
        const Token(TokenType.tartFor, 'for', null, 1),
        const Token(TokenType.leftParen, '(', null, 1),
        const Token(TokenType.tartVar, 'var', null, 1),
        const Token(TokenType.identifier, 'i', null, 1),
        const Token(TokenType.assign, '=', null, 1),
        const Token(TokenType.integer, '0', 0, 1),
        const Token(TokenType.semicolon, ';', null, 1),
        const Token(TokenType.identifier, 'i', null, 1),
        const Token(TokenType.less, '<', null, 1),
        const Token(TokenType.integer, '10', 10, 1),
        const Token(TokenType.semicolon, ';', null, 1),
        const Token(TokenType.identifier, 'i', null, 1),
        const Token(TokenType.plusPlus, '++', null, 1),
        const Token(TokenType.rightParen, ')', null, 1),
        const Token(TokenType.leftBrace, '{', null, 1),
        const Token(TokenType.rightBrace, '}', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<ForStatement>());
      final forStmt = result[0] as ForStatement;
      expect(forStmt.initializer, isA<VariableDeclaration>());
      expect(forStmt.condition, isA<BinaryExpression>());
      expect(forStmt.increment, isA<Assignment>());
      expect(forStmt.body, isA<Block>());
      expect((forStmt.body as Block).statements, isEmpty);
    });

    test('parses return statements', () {
      final tokens = [
        const Token(TokenType.tartReturn, 'return', null, 1),
        const Token(TokenType.integer, '42', 42, 1),
        const Token(TokenType.semicolon, ';', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<ReturnStatement>());
      final returnStmt = result[0] as ReturnStatement;
      expect(returnStmt.value, isA<Literal>());
      expect((returnStmt.value as Literal).value, 42);
    });

    test('parses expression statements', () {
      final tokens = [
        const Token(TokenType.identifier, 'x', null, 1),
        const Token(TokenType.assign, '=', null, 1),
        const Token(TokenType.integer, '42', 42, 1),
        const Token(TokenType.semicolon, ';', null, 1),
        const Token(TokenType.eof, '', null, 1),
      ];
      final result = parser.parse(tokens);

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final exprStmt = result[0] as ExpressionStatement;
      expect(exprStmt.expression, isA<Assignment>());
    });
  });
}
