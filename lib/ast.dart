library tart;

import 'token.dart';

part 'widget_ast.dart';

sealed class AstNode {
  const AstNode();
}

class EndOfFile extends AstNode {
  const EndOfFile();
}

class VariableDeclaration extends AstNode {
  final Token name;
  final AstNode? initializer;

  const VariableDeclaration(this.name, this.initializer);
}

class FunctionDeclaration extends AstNode {
  final Token name;
  final List<Token> parameters;
  final Block body;

  const FunctionDeclaration(this.name, this.parameters, this.body);
}

class IfStatement extends AstNode {
  final AstNode condition;
  final AstNode thenBranch;
  final AstNode? elseBranch;

  const IfStatement(this.condition, this.thenBranch, this.elseBranch);
}

class WhileStatement extends AstNode {
  final AstNode condition;
  final AstNode body;

  const WhileStatement(this.condition, this.body);
}

class ForStatement extends AstNode {
  final AstNode? initializer;
  final AstNode? condition;
  final AstNode? increment;
  final AstNode body;

  const ForStatement(
      this.initializer, this.condition, this.increment, this.body);
}

class ReturnStatement extends AstNode {
  final Token keyword;
  final AstNode? value;

  const ReturnStatement(this.keyword, this.value);
}

class Block extends AstNode {
  final List<AstNode> statements;

  const Block(this.statements);
}

class ExpressionStatement extends AstNode {
  final AstNode expression;

  const ExpressionStatement(this.expression);
}

class Assignment extends AstNode {
  final Token name;
  final Token operator;
  final AstNode value;

  const Assignment(this.name, this.operator, this.value);
}

class BinaryExpression extends AstNode {
  final AstNode left;
  final Token operator;
  final AstNode right;

  const BinaryExpression(this.left, this.operator, this.right);
}

class UnaryExpression extends AstNode {
  final Token operator;
  final AstNode right;

  const UnaryExpression(this.operator, this.right);
}

class CallExpression extends AstNode {
  final AstNode callee;
  final Token paren;
  final List<AstNode> arguments;

  const CallExpression(this.callee, this.paren, this.arguments);
}

class Literal extends AstNode {
  final dynamic value;

  const Literal(this.value);
}

class Variable extends AstNode {
  final Token name;

  const Variable(this.name);
}
