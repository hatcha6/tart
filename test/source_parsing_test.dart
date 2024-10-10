import 'package:flutter_test/flutter_test.dart';
import 'package:tart_dev/tart.dart';
import 'package:tart_dev/ast.dart';

void main() {
  late Lexer lexer;
  late Parser parser;

  setUp(() {
    lexer = Lexer();
    parser = Parser();
  });

  List<AstNode> parseSource(String source) {
    final tokens = lexer.scanTokens(source);
    return parser.parse(tokens, source);
  }

  group('Variable Declarations', () {
    test('parses integer variable declaration correctly', () {
      final ast = parseSource('var x = 5;');
      expect(ast.length, 1);
      expect(ast[0], isA<VariableDeclaration>());
      final varDecl = ast[0] as VariableDeclaration;
      expect(varDecl.name.lexeme, 'x');
      expect((varDecl.initializer as Literal).value, 5);
    });

    test('parses constant float declaration correctly', () {
      final ast = parseSource('const pi = 3.14;');
      expect(ast.length, 1);
      expect(ast[0], isA<VariableDeclaration>());
      final varDecl = ast[0] as VariableDeclaration;
      expect(varDecl.name.lexeme, 'pi');
      expect((varDecl.initializer as Literal).value, 3.14);
    });
  });

  group('Control Flow Statements', () {
    test('parses if-else statement correctly', () {
      final ast =
          parseSource('if (x > 0) { return true; } else { return false; }');
      expect(ast.length, 1);
      expect(ast[0], isA<IfStatement>());
      final ifStmt = ast[0] as IfStatement;
      expect(ifStmt.condition, isA<BinaryExpression>());
      expect(ifStmt.thenBranch, isA<Block>());
      expect(ifStmt.elseBranch, isA<Block>());
    });

    test('parses for loop correctly', () {
      final ast = parseSource('for (var i = 0; i < 10; i++) { print(i); }');
      expect(ast.length, 1);
      expect(ast[0], isA<ForStatement>());
      final forStmt = ast[0] as ForStatement;
      expect(forStmt.initializer, isA<VariableDeclaration>());
      expect(forStmt.condition, isA<BinaryExpression>());
      expect(forStmt.increment, isA<Assignment>());
      expect(forStmt.body, isA<Block>());
    });

    test('parses while loop correctly', () {
      final ast = parseSource('while (true) { if (condition) break; }');
      expect(ast.length, 1);
      expect(ast[0], isA<WhileStatement>());
      final whileStmt = ast[0] as WhileStatement;
      expect(whileStmt.condition, isA<Literal>());
      expect(whileStmt.body, isA<Block>());
    });
  });

  group('Functions', () {
    test('parses function declaration correctly', () {
      final ast = parseSource('function add(a, b) { return a + b; }');
      expect(ast.length, 1);
      expect(ast[0], isA<FunctionDeclaration>());
      final funcDecl = ast[0] as FunctionDeclaration;
      expect(funcDecl.name.lexeme, 'add');
      expect(funcDecl.parameters.length, 2);
      expect(funcDecl.body.statements.length, 1);
    });

    test('parses function call correctly', () {
      final ast = parseSource('var result = add(5, 3);');
      expect(ast.length, 1);
      expect(ast[0], isA<VariableDeclaration>());
      final varDecl = ast[0] as VariableDeclaration;
      expect(varDecl.name.lexeme, 'result');
      expect(varDecl.initializer, isA<CallExpression>());
    });
  });

  group('Expressions', () {
    test('parses arithmetic expression correctly', () {
      final ast = parseSource('var x = 1 + 2 * 3 - 4 / 2;');
      expect(ast.length, 1);
      expect(ast[0], isA<VariableDeclaration>());
      final varDecl = ast[0] as VariableDeclaration;
      expect(varDecl.initializer, isA<BinaryExpression>());
    });

    test('parses logical expression correctly', () {
      final ast = parseSource('var flag = true && false || true;');
      expect(ast.length, 1);
      expect(ast[0], isA<VariableDeclaration>());
      final varDecl = ast[0] as VariableDeclaration;
      expect(varDecl.initializer, isA<BinaryExpression>());
    });

    test('parses string concatenation correctly', () {
      final ast = parseSource(
          'var name = "John"; var greeting = "Hello, " + name + "!";');
      expect(ast.length, 2);
      expect(ast[0], isA<VariableDeclaration>());
      expect(ast[1], isA<VariableDeclaration>());
      final greetingDecl = ast[1] as VariableDeclaration;
      expect(greetingDecl.initializer, isA<BinaryExpression>());
    });
  });
}
