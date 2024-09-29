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
      Token(TokenType.tartVar, "var", null, 1),
      Token(TokenType.identifier, "x", null, 1),
      Literal(10),
    );
    evaluator.evaluateNode(varDecl);
    expect(evaluator.getVariable('x'), equals(10));

    var assignment = const Assignment(
      Token(TokenType.identifier, "x", null, 1),
      Token(TokenType.assign, "=", null, 1),
      Literal(20),
    );
    evaluator.evaluateNode(assignment);
    expect(evaluator.getVariable('x'), equals(20));
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
      Token(TokenType.tartVar, "var", null, 1),
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
    expect(evaluator.getVariable('x'), equals(5));
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

    expect(evaluator.evaluateNode(callExpr), equals(7));
  });

  test('Evaluates member access', () {
    evaluator.defineGlobalVariable('obj', {'property': 42});
    var expr = MemberAccess(
      const Variable(Token(TokenType.identifier, 'obj', null, 1)),
      const Token(TokenType.identifier, 'property', null, 1),
    );
    expect(evaluator.evaluateNode(expr), equals(42));
  });

  test('Evaluates index access', () {
    evaluator.defineGlobalVariable('arr', [1, 2, 3]);
    var expr = IndexAccess(
      const Variable(Token(TokenType.identifier, 'arr', null, 1)),
      const Literal(1),
    );
    expect(evaluator.evaluateNode(expr), equals(2));
  });

  test('Evaluates list literal', () {
    var expr =
        ListLiteral([const Literal(1), const Literal(2), const Literal(3)]);
    expect(evaluator.evaluateNode(expr), equals([1, 2, 3]));
  });

  test('Evaluates length access', () {
    evaluator.defineGlobalVariable('list', [1, 2, 3, 4]);
    var expr = LengthAccess(
      const Variable(Token(TokenType.identifier, 'list', null, 1)),
    );
    expect(evaluator.evaluateNode(expr), equals(4));

    evaluator.defineGlobalVariable('str', 'hello');
    expr = LengthAccess(
      const Variable(Token(TokenType.identifier, 'str', null, 1)),
    );
    expect(evaluator.evaluateNode(expr), equals(5));

    evaluator.defineGlobalVariable('map', {'a': 1, 'b': 2});
    expr = LengthAccess(
      const Variable(Token(TokenType.identifier, 'map', null, 1)),
    );
    expect(evaluator.evaluateNode(expr), equals(2));
  });

  test('Throws error for invalid length access', () {
    evaluator.defineGlobalVariable('num', 42);
    var expr = LengthAccess(
      const Variable(Token(TokenType.identifier, 'num', null, 1)),
    );
    expect(() => evaluator.evaluateNode(expr), throwsA(isA<EvaluationError>()));
  });

  test('Throws error for invalid index access', () {
    evaluator.defineGlobalVariable('arr', [1, 2, 3]);
    var expr = IndexAccess(
      const Variable(Token(TokenType.identifier, 'arr', null, 1)),
      const Literal(5),
    );
    expect(() => evaluator.evaluateNode(expr), throwsA(isA<EvaluationError>()));

    expr = IndexAccess(
      const Variable(Token(TokenType.identifier, 'arr', null, 1)),
      const Literal('invalid'),
    );
    expect(() => evaluator.evaluateNode(expr), throwsA(isA<EvaluationError>()));
  });

  test('Evaluates recursive Fibonacci function', () {
    const fibFunction = FunctionDeclaration(
      Token(TokenType.identifier, 'fib', null, 1),
      [Token(TokenType.identifier, 'n', null, 1)],
      Block([
        IfStatement(
          BinaryExpression(
            Variable(Token(TokenType.identifier, 'n', null, 1)),
            Token(TokenType.lessEqual, '<=', null, 1),
            Literal(1),
          ),
          Block([
            ReturnStatement(
              Token(TokenType.tartReturn, 'return', null, 1),
              Variable(Token(TokenType.identifier, 'n', null, 1)),
            ),
          ]),
          null,
        ),
        ReturnStatement(
          Token(TokenType.tartReturn, 'return', null, 1),
          BinaryExpression(
            CallExpression(
              Variable(Token(TokenType.identifier, 'fib', null, 1)),
              Token(TokenType.leftParen, '(', null, 1),
              [
                BinaryExpression(
                  Variable(Token(TokenType.identifier, 'n', null, 1)),
                  Token(TokenType.minus, '-', null, 1),
                  Literal(1),
                ),
              ],
            ),
            Token(TokenType.plus, '+', null, 1),
            CallExpression(
              Variable(Token(TokenType.identifier, 'fib', null, 1)),
              Token(TokenType.leftParen, '(', null, 1),
              [
                BinaryExpression(
                  Variable(Token(TokenType.identifier, 'n', null, 1)),
                  Token(TokenType.minus, '-', null, 1),
                  Literal(2),
                ),
              ],
            ),
          ),
        ),
      ]),
    );

    evaluator.evaluateNode(fibFunction);

    expect(
      evaluator.evaluateNode(
        const CallExpression(
          Variable(Token(TokenType.identifier, 'fib', null, 1)),
          Token(TokenType.leftParen, '(', null, 1),
          [Literal(0)],
        ),
      ),
      equals(0),
    );

    expect(
      evaluator.evaluateNode(
        const CallExpression(
          Variable(Token(TokenType.identifier, 'fib', null, 1)),
          Token(TokenType.leftParen, '(', null, 1),
          [Literal(1)],
        ),
      ),
      equals(1),
    );

    expect(
      evaluator.evaluateNode(
        const CallExpression(
          Variable(Token(TokenType.identifier, 'fib', null, 1)),
          Token(TokenType.leftParen, '(', null, 1),
          [Literal(5)],
        ),
      ),
      equals(5),
    );

    expect(
      evaluator.evaluateNode(
        const CallExpression(
          Variable(Token(TokenType.identifier, 'fib', null, 1)),
          Token(TokenType.leftParen, '(', null, 1),
          [Literal(10)],
        ),
      ),
      equals(55),
    );
  });

  test('Throws error when assigning to const or final variable', () {
    // Const variable
    evaluator.evaluateNode(const VariableDeclaration(
      Token(TokenType.tartConst, "const", null, 1),
      Token(TokenType.identifier, "constVar", null, 1),
      Literal(10),
    ));

    expect(
        () => evaluator.evaluateNode(const Assignment(
              Token(TokenType.identifier, "constVar", null, 1),
              Token(TokenType.assign, "=", null, 1),
              Literal(20),
            )),
        throwsA(isA<EvaluationError>()));

    // Final variable
    evaluator.evaluateNode(const VariableDeclaration(
      Token(TokenType.tartFinal, "final", null, 1),
      Token(TokenType.identifier, "finalVar", null, 1),
      Literal(30),
    ));

    expect(
        () => evaluator.evaluateNode(const Assignment(
              Token(TokenType.identifier, "finalVar", null, 1),
              Token(TokenType.assign, "=", null, 1),
              Literal(40),
            )),
        throwsA(isA<EvaluationError>()));
  });

  test('Evaluates for loop', () {
    // Declare a variable to store the sum
    evaluator.evaluateNode(const VariableDeclaration(
      Token(TokenType.tartVar, "var", null, 1),
      Token(TokenType.identifier, "sum", null, 1),
      Literal(0),
    ));

    // Create a for loop that sums numbers from 1 to 5
    var forLoop = const ForStatement(
      VariableDeclaration(
        Token(TokenType.tartVar, "var", null, 1),
        Token(TokenType.identifier, "i", null, 1),
        Literal(1),
      ),
      BinaryExpression(
        Variable(Token(TokenType.identifier, "i", null, 1)),
        Token(TokenType.lessEqual, "<=", null, 1),
        Literal(5),
      ),
      Assignment(
        Token(TokenType.identifier, "i", null, 1),
        Token(TokenType.assign, "=", null, 1),
        BinaryExpression(
          Variable(Token(TokenType.identifier, "i", null, 1)),
          Token(TokenType.plus, "+", null, 1),
          Literal(1),
        ),
      ),
      Block([
        ExpressionStatement(Assignment(
          Token(TokenType.identifier, "sum", null, 1),
          Token(TokenType.assign, "=", null, 1),
          BinaryExpression(
            Variable(Token(TokenType.identifier, "sum", null, 1)),
            Token(TokenType.plus, "+", null, 1),
            Variable(Token(TokenType.identifier, "i", null, 1)),
          ),
        )),
      ]),
    );

    evaluator.evaluateNode(forLoop);
    expect(evaluator.getVariable('sum'), equals(15));
  });

  test('Evaluates callFunction method', () {
    // Test calling a FunctionDeclaration
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

    expect(evaluator.callFunction("add", [3, 4]), equals(7));

    // Test calling a native Dart function
    evaluator.defineGlobalVariable(
        'multiply', (List args) => args[0] * args[1]);
    expect(evaluator.callFunction("multiply", [5, 6]), equals(30));

    // Test calling a non-existent function
    expect(() => evaluator.callFunction("nonexistent", []),
        throwsA(isA<EvaluationError>()));

    // Test calling a non-callable value
    evaluator.defineGlobalVariable('notAFunction', 42);
    expect(() => evaluator.callFunction("notAFunction", []),
        throwsA(isA<EvaluationError>()));
  });
}
