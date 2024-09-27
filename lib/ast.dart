library tart;

import 'token.dart';
import 'dart:math';

part 'widget_ast.dart';
part 'parameter_ast.dart';

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

class AnonymousFunction extends FunctionDeclaration {
  static int _counter = 0;
  static final Random _random = Random();

  AnonymousFunction(List<Token> parameters, Block body)
      : super(
          Token(
            TokenType.identifier,
            '_anon_${_generateUniqueId()}',
            null,
            -1,
          ),
          parameters,
          body,
        );

  static String _generateUniqueId() {
    _counter++;
    String randomString = String.fromCharCodes(
      List.generate(8, (_) => _random.nextInt(26) + 97),
    );
    return '$randomString$_counter';
  }
}

class MemberAccess extends AstNode {
  final AstNode object;
  final Token name;

  MemberAccess(this.object, this.name);
}

class IndexAccess extends AstNode {
  final AstNode object;
  final AstNode index;

  IndexAccess(this.object, this.index);
}

class ListLiteral extends AstNode {
  final List<AstNode> elements;

  ListLiteral(this.elements);
}

class LengthAccess extends AstNode {
  final AstNode object;

  LengthAccess(this.object);
}

class MapLiteral extends AstNode {
  final List<MapEntry> entries;

  MapLiteral(this.entries);
}

class MapEntry extends AstNode {
  final AstNode key;
  final AstNode value;

  MapEntry(this.key, this.value);
}

class SetLiteral extends AstNode {
  final List<AstNode> elements;

  SetLiteral(this.elements);
}

class BreakStatement extends AstNode {
  final Token keyword;

  const BreakStatement(this.keyword);
}

class ToString extends AstNode {
  final AstNode expression;

  ToString(this.expression);
}
