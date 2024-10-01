import 'package:flutter_test/flutter_test.dart';
import 'package:tart_dev/tart.dart';
import 'package:tart_dev/ast.dart';

void main() {
  void testParse(String source, Function(List<AstNode>) validator) {
    test('Parse: $source', () {
      final lexer = Lexer();
      final tokens = lexer.scanTokens(source);
      final parser = Parser();
      final ast = parser.parse(tokens);
      validator(ast);
    });
  }

  group('Lexer and Parser Integration Tests', () {
    testParse(
      'var x = 5;',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<VariableDeclaration>());
        final varDecl = ast[0] as VariableDeclaration;
        expect(varDecl.name.lexeme, 'x');
        expect((varDecl.initializer as Literal).value, 5);
      },
    );

    testParse(
      'const pi = 3.14;',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<VariableDeclaration>());
        final varDecl = ast[0] as VariableDeclaration;
        expect(varDecl.name.lexeme, 'pi');
        expect((varDecl.initializer as Literal).value, 3.14);
      },
    );

    testParse(
      'if (x > 0) { return true; } else { return false; }',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<IfStatement>());
        final ifStmt = ast[0] as IfStatement;
        expect(ifStmt.condition, isA<BinaryExpression>());
        expect(ifStmt.thenBranch, isA<Block>());
        expect(ifStmt.elseBranch, isA<Block>());
      },
    );

    testParse(
      'for (var i = 0; i < 10; i++) { print(i); }',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<ForStatement>());
        final forStmt = ast[0] as ForStatement;
        expect(forStmt.initializer, isA<VariableDeclaration>());
        expect(forStmt.condition, isA<BinaryExpression>());
        expect(forStmt.increment, isA<Assignment>());
        expect(forStmt.body, isA<Block>());
      },
    );

    testParse(
      'function add(a, b) { return a + b; }',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<FunctionDeclaration>());
        final funcDecl = ast[0] as FunctionDeclaration;
        expect(funcDecl.name.lexeme, 'add');
        expect(funcDecl.parameters.length, 2);
        expect(funcDecl.body.statements.length, 1);
      },
    );

    testParse(
      'var result = add(5, 3);',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<VariableDeclaration>());
        final varDecl = ast[0] as VariableDeclaration;
        expect(varDecl.name.lexeme, 'result');
        expect(varDecl.initializer, isA<CallExpression>());
      },
    );

    testParse(
      'while (true) { if (condition) break; }',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<WhileStatement>());
        final whileStmt = ast[0] as WhileStatement;
        expect(whileStmt.condition, isA<Literal>());
        expect(whileStmt.body, isA<Block>());
      },
    );

    testParse(
      'var x = 1 + 2 * 3 - 4 / 2;',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<VariableDeclaration>());
        final varDecl = ast[0] as VariableDeclaration;
        expect(varDecl.initializer, isA<BinaryExpression>());
      },
    );

    testParse(
      'var flag = true && false || true;',
      (ast) {
        expect(ast.length, 1);
        expect(ast[0], isA<VariableDeclaration>());
        final varDecl = ast[0] as VariableDeclaration;
        expect(varDecl.initializer, isA<BinaryExpression>());
      },
    );

    testParse(
      'var name = "John"; var greeting = "Hello, " + name + "!";',
      (ast) {
        expect(ast.length, 2);
        expect(ast[0], isA<VariableDeclaration>());
        expect(ast[1], isA<VariableDeclaration>());
        final greetingDecl = ast[1] as VariableDeclaration;
        expect(greetingDecl.initializer, isA<BinaryExpression>());
      },
    );
  });
}
