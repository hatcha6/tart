import 'token.dart';

sealed class AstNode {}

class EndOfFile extends AstNode {}

class VariableDeclaration extends AstNode {
  final Token name;
  final AstNode? initializer;

  VariableDeclaration(this.name, this.initializer);
}

class FunctionDeclaration extends AstNode {
  final Token name;
  final List<Token> parameters;
  final Block body;

  FunctionDeclaration(this.name, this.parameters, this.body);
}

class IfStatement extends AstNode {
  final AstNode condition;
  final AstNode thenBranch;
  final AstNode? elseBranch;

  IfStatement(this.condition, this.thenBranch, this.elseBranch);
}

class WhileStatement extends AstNode {
  final AstNode condition;
  final AstNode body;

  WhileStatement(this.condition, this.body);
}

class ForStatement extends AstNode {
  final AstNode? initializer;
  final AstNode? condition;
  final AstNode? increment;
  final AstNode body;

  ForStatement(this.initializer, this.condition, this.increment, this.body);
}

class ReturnStatement extends AstNode {
  final Token keyword;
  final AstNode? value;

  ReturnStatement(this.keyword, this.value);
}

class Block extends AstNode {
  final List<AstNode> statements;

  Block(this.statements);
}

class ExpressionStatement extends AstNode {
  final AstNode expression;

  ExpressionStatement(this.expression);
}

class Assignment extends AstNode {
  final Token name;
  final Token operator;
  final AstNode value;

  Assignment(this.name, this.operator, this.value);
}

class BinaryExpression extends AstNode {
  final AstNode left;
  final Token operator;
  final AstNode right;

  BinaryExpression(this.left, this.operator, this.right);
}

class UnaryExpression extends AstNode {
  final Token operator;
  final AstNode right;

  UnaryExpression(this.operator, this.right);
}

class CallExpression extends AstNode {
  final AstNode callee;
  final Token paren;
  final List<AstNode> arguments;

  CallExpression(this.callee, this.paren, this.arguments);
}

class Literal extends AstNode {
  final dynamic value;

  Literal(this.value);
}

class Variable extends AstNode {
  final Token name;

  Variable(this.name);
}
