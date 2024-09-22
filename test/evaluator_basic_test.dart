import 'package:flutter_test/flutter_test.dart';
import 'package:tart_dev/ast.dart';
import 'package:tart_dev/evaluator.dart';
import 'package:tart_dev/token.dart';

void main() {
  late Evaluator evaluator;

  setUp(() {
    evaluator = Evaluator();
  });

  test('Evaluates literal expressions', () {
    expect(evaluator.evaluateNode(const Literal(5)), equals(5));
    expect(evaluator.evaluateNode(const Literal(3.14)), equals(3.14));
    expect(evaluator.evaluateNode(const Literal("Hello")), equals("Hello"));
    expect(evaluator.evaluateNode(const Literal(true)), equals(true));
    expect(evaluator.evaluateNode(const Literal(false)), equals(false));
    expect(evaluator.evaluateNode(const Literal(null)), equals(null));
  });

  test('Evaluates variable declarations and assignments', () {
    var varDecl = const VariableDeclaration(
      Token(TokenType.identifier, "x", null, 1),
      Literal(10),
    );
    evaluator.evaluateNode(varDecl);
    expect(
        evaluator.environment
            .get(const Token(TokenType.identifier, "x", null, 1)),
        equals(10));

    var assignment = const Assignment(
      Token(TokenType.identifier, "x", null, 1),
      Token(TokenType.assign, "=", null, 1),
      Literal(20),
    );
    evaluator.evaluateNode(assignment);
    expect(
        evaluator.environment
            .get(const Token(TokenType.identifier, "x", null, 1)),
        equals(20));
  });

  test('Evaluates binary expressions', () {
    var expr = const BinaryExpression(
      Literal(5),
      Token(TokenType.plus, "+", null, 1),
      Literal(3),
    );
    expect(evaluator.evaluateNode(expr), equals(8));

    expr = const BinaryExpression(
      Literal(10),
      Token(TokenType.minus, "-", null, 1),
      Literal(4),
    );
    expect(evaluator.evaluateNode(expr), equals(6));

    expr = const BinaryExpression(
      Literal(3),
      Token(TokenType.multiply, "*", null, 1),
      Literal(4),
    );
    expect(evaluator.evaluateNode(expr), equals(12));

    expr = const BinaryExpression(
      Literal(15),
      Token(TokenType.divide, "/", null, 1),
      Literal(3),
    );
    expect(evaluator.evaluateNode(expr), equals(5));
  });

  test('Evaluates unary expressions', () {
    var expr = const UnaryExpression(
      Token(TokenType.minus, "-", null, 1),
      Literal(5),
    );
    expect(evaluator.evaluateNode(expr), equals(-5));

    expr = const UnaryExpression(
      Token(TokenType.not, "!", null, 1),
      Literal(false),
    );
    expect(evaluator.evaluateNode(expr), equals(true));
  });

  test('Evaluates if statements', () {
    var ifStmt = const IfStatement(
      Literal(true),
      Literal(10),
      Literal(20),
    );
    expect(evaluator.evaluateNode(ifStmt), equals(10));

    ifStmt = const IfStatement(
      Literal(false),
      Literal(10),
      Literal(20),
    );
    expect(evaluator.evaluateNode(ifStmt), equals(20));
  });

  test('Evaluates while statements', () {
    evaluator.evaluateNode(const VariableDeclaration(
      Token(TokenType.identifier, "x", null, 1),
      Literal(0),
    ));

    var whileStmt = const WhileStatement(
      BinaryExpression(
        Variable(Token(TokenType.identifier, "x", null, 1)),
        Token(TokenType.less, "<", null, 1),
        Literal(5),
      ),
      Block([
        ExpressionStatement(Assignment(
          Token(TokenType.identifier, "x", null, 1),
          Token(TokenType.assign, "=", null, 1),
          BinaryExpression(
            Variable(Token(TokenType.identifier, "x", null, 1)),
            Token(TokenType.plus, "+", null, 1),
            Literal(1),
          ),
        )),
      ]),
    );

    evaluator.evaluateNode(whileStmt);
    expect(
        evaluator.environment
            .get(const Token(TokenType.identifier, "x", null, 1)),
        equals(5));
  });

  test('Evaluates function declarations and calls', () {
    const funcDecl = FunctionDeclaration(
      Token(TokenType.identifier, "add", null, 1),
      [
        Token(TokenType.identifier, "a", null, 1),
        Token(TokenType.identifier, "b", null, 1),
      ],
      Block([
        ReturnStatement(
          Token(TokenType.tartReturn, "return", null, 1),
          BinaryExpression(
            Variable(Token(TokenType.identifier, "a", null, 1)),
            Token(TokenType.plus, "+", null, 1),
            Variable(Token(TokenType.identifier, "b", null, 1)),
          ),
        ),
      ]),
    );

    evaluator.evaluateNode(funcDecl);

    var callExpr = const CallExpression(
      funcDecl,
      Token(TokenType.leftParen, "(", null, 1),
      [Literal(3), Literal(4)],
    );

    expect(evaluator.evaluateNode(callExpr).value, equals(7));
  });
}
