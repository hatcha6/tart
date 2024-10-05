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
        const Token(TokenType.tartVar, 'var', null, 1, 1),
        const Token(TokenType.identifier, 'x', null, 1, 1),
        const Token(TokenType.assign, '=', null, 1, 1),
        const Token(TokenType.integer, '42', 42, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

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
        const Token(TokenType.tartFunction, 'function', null, 1, 1),
        const Token(TokenType.identifier, 'foo', null, 1, 1),
        const Token(TokenType.leftParen, '(', null, 1, 1),
        const Token(TokenType.rightParen, ')', null, 1, 1),
        const Token(TokenType.leftBrace, '{', null, 1, 1),
        const Token(TokenType.rightBrace, '}', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<FunctionDeclaration>());
      final funcDecl = result[0] as FunctionDeclaration;
      expect(funcDecl.name.lexeme, 'foo');
      expect(funcDecl.parameters, isEmpty);
      expect(funcDecl.body.statements, isEmpty);
    });

    test('parses anonymous function declarations', () {
      final tokens = [
        const Token(TokenType.leftParen, '(', null, 1, 1),
        const Token(TokenType.rightParen, ')', null, 1, 1),
        const Token(TokenType.leftBrace, '{', null, 1, 1),
        const Token(TokenType.rightBrace, '}', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<AnonymousFunction>());
      final funcDecl = result[0] as AnonymousFunction;
      expect(funcDecl.parameters, isEmpty);
      expect(funcDecl.body.statements, isEmpty);
    });

    test('parses if statements', () {
      final tokens = [
        const Token(TokenType.tartIf, 'if', null, 1, 1),
        const Token(TokenType.leftParen, '(', null, 1, 1),
        const Token(TokenType.boolean, 'true', true, 1, 1),
        const Token(TokenType.rightParen, ')', null, 1, 1),
        const Token(TokenType.leftBrace, '{', null, 1, 1),
        const Token(TokenType.rightBrace, '}', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

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
        const Token(TokenType.tartWhile, 'while', null, 1, 1),
        const Token(TokenType.leftParen, '(', null, 1, 1),
        const Token(TokenType.boolean, 'true', true, 1, 1),
        const Token(TokenType.rightParen, ')', null, 1, 1),
        const Token(TokenType.leftBrace, '{', null, 1, 1),
        const Token(TokenType.rightBrace, '}', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

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
        const Token(TokenType.tartFor, 'for', null, 1, 1),
        const Token(TokenType.leftParen, '(', null, 1, 1),
        const Token(TokenType.tartVar, 'var', null, 1, 1),
        const Token(TokenType.identifier, 'i', null, 1, 1),
        const Token(TokenType.assign, '=', null, 1, 1),
        const Token(TokenType.integer, '0', 0, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.identifier, 'i', null, 1, 1),
        const Token(TokenType.less, '<', null, 1, 1),
        const Token(TokenType.integer, '10', 10, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.identifier, 'i', null, 1, 1),
        const Token(TokenType.plusPlus, '++', null, 1, 1),
        const Token(TokenType.rightParen, ')', null, 1, 1),
        const Token(TokenType.leftBrace, '{', null, 1, 1),
        const Token(TokenType.rightBrace, '}', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

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
        const Token(TokenType.tartReturn, 'return', null, 1, 1),
        const Token(TokenType.integer, '42', 42, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<ReturnStatement>());
      final returnStmt = result[0] as ReturnStatement;
      expect(returnStmt.value, isA<Literal>());
      expect((returnStmt.value as Literal).value, 42);
    });

    test('parses expression statements', () {
      final tokens = [
        const Token(TokenType.identifier, 'x', null, 1, 1),
        const Token(TokenType.assign, '=', null, 1, 1),
        const Token(TokenType.integer, '42', 42, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result, isA<List<AstNode>>());
      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final exprStmt = result[0] as ExpressionStatement;
      expect(exprStmt.expression, isA<Assignment>());
    });

    test('parses member access', () {
      final tokens = [
        const Token(TokenType.identifier, 'obj', null, 1, 1),
        const Token(TokenType.dot, '.', null, 1, 1),
        const Token(TokenType.identifier, 'property', null, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final expr = (result[0] as ExpressionStatement).expression;
      expect(expr, isA<MemberAccess>());
      final memberAccess = expr as MemberAccess;
      expect(memberAccess.object, isA<Variable>());
      expect(memberAccess.name.lexeme, 'property');
    });

    test('parses index access', () {
      final tokens = [
        const Token(TokenType.identifier, 'arr', null, 1, 1),
        const Token(TokenType.leftBracket, '[', null, 1, 1),
        const Token(TokenType.integer, '0', 0, 1, 1),
        const Token(TokenType.rightBracket, ']', null, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final expr = (result[0] as ExpressionStatement).expression;
      expect(expr, isA<IndexAccess>());
      final indexAccess = expr as IndexAccess;
      expect(indexAccess.object, isA<Variable>());
      expect(indexAccess.index, isA<Literal>());
    });

    test('parses list literal', () {
      final tokens = [
        const Token(TokenType.leftBracket, '[', null, 1, 1),
        const Token(TokenType.integer, '1', 1, 1, 1),
        const Token(TokenType.comma, ',', null, 1, 1),
        const Token(TokenType.integer, '2', 2, 1, 1),
        const Token(TokenType.comma, ',', null, 1, 1),
        const Token(TokenType.integer, '3', 3, 1, 1),
        const Token(TokenType.rightBracket, ']', null, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final expr = (result[0] as ExpressionStatement).expression;
      expect(expr, isA<ListLiteral>());
      final listLiteral = expr as ListLiteral;
      expect(listLiteral.elements.length, 3);
      expect(listLiteral.elements.every((e) => e is Literal), true);
    });

    test('parses length access', () {
      final tokens = [
        const Token(TokenType.identifier, 'list', null, 1, 1),
        const Token(TokenType.dot, '.', null, 1, 1),
        const Token(TokenType.identifier, 'length', null, 1, 1),
        const Token(TokenType.semicolon, ';', null, 1, 1),
        const Token(TokenType.eof, '', null, 1, 1),
      ];
      final result = parser.parse(tokens, '');

      expect(result.length, 1);
      expect(result[0], isA<ExpressionStatement>());
      final expr = (result[0] as ExpressionStatement).expression;
      expect(expr, isA<MemberAccess>());
      final memberAccess = expr as MemberAccess;
      expect(memberAccess.object, isA<Variable>());
      expect(memberAccess.name.lexeme, 'length');
    });
  });
}
