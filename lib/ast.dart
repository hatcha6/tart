library tart;

import 'token.dart';
import 'dart:math';

part 'widget_ast.dart';
part 'parameter_ast.dart';
part 'icons_ast.dart';

sealed class AstNode {
  final String tartType;
  const AstNode(this.tartType);
}

class AstList extends AstNode {
  final List<AstNode> nodes;

  const AstList(this.nodes) : super('AstList');
}

class AstObject extends AstNode {
  final Map<String, AstNode> properties;

  const AstObject(this.properties) : super('AstObject');
}

class ImportStatement extends AstNode {
  final Token keyword;
  final String path;

  const ImportStatement(this.keyword, this.path) : super('ImportStatement');
}

class EndOfFile extends AstNode {
  const EndOfFile() : super('EndOfFile');
}

class VariableDeclaration extends AstNode {
  final Token keyword;
  final Token name;
  final AstNode? initializer;

  const VariableDeclaration(this.keyword, this.name, this.initializer)
      : super('VariableDeclaration');
}

class FunctionDeclaration extends AstNode {
  final Token name;
  final List<Token> parameters;
  final Block body;

  const FunctionDeclaration(this.name, this.parameters, this.body)
      : super('FunctionDeclaration');
}

class IfStatement extends AstNode {
  final AstNode condition;
  final AstNode thenBranch;
  final AstNode? elseBranch;

  const IfStatement(this.condition, this.thenBranch, this.elseBranch)
      : super('IfStatement');
}

class WhileStatement extends AstNode {
  final AstNode condition;
  final AstNode body;

  const WhileStatement(this.condition, this.body) : super('WhileStatement');
}

class ForStatement extends AstNode {
  final AstNode? initializer;
  final AstNode? condition;
  final AstNode? increment;
  final AstNode body;

  const ForStatement(
      this.initializer, this.condition, this.increment, this.body)
      : super('ForStatement');
}

class ReturnStatement extends AstNode {
  final Token keyword;
  final AstNode? value;

  const ReturnStatement(this.keyword, this.value) : super('ReturnStatement');
}

class Block extends AstNode {
  final List<AstNode> statements;

  const Block(this.statements) : super('Block');
}

class ExpressionStatement extends AstNode {
  final AstNode expression;

  const ExpressionStatement(this.expression) : super('ExpressionStatement');
}

class Assignment extends AstNode {
  final Token name;
  final Token operator;
  final AstNode value;

  const Assignment(this.name, this.operator, this.value) : super('Assignment');
}

class BinaryExpression extends AstNode {
  final AstNode left;
  final Token operator;
  final AstNode right;

  const BinaryExpression(this.left, this.operator, this.right)
      : super('BinaryExpression');
}

class UnaryExpression extends AstNode {
  final Token operator;
  final AstNode right;

  const UnaryExpression(this.operator, this.right) : super('UnaryExpression');
}

class CallExpression extends AstNode {
  final AstNode callee;
  final Token paren;
  final List<AstNode> arguments;

  const CallExpression(this.callee, this.paren, this.arguments)
      : super('CallExpression');
}

class Literal extends AstNode {
  final dynamic value;

  const Literal(this.value) : super('Literal');
}

class Variable extends AstNode {
  final Token name;

  const Variable(this.name) : super('Variable');
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

  const MemberAccess(this.object, this.name) : super('MemberAccess');
}

class IndexAccess extends AstNode {
  final AstNode object;
  final AstNode index;

  const IndexAccess(this.object, this.index) : super('IndexAccess');
}

class ListLiteral extends AstNode {
  final List<AstNode> elements;

  const ListLiteral(this.elements) : super('ListLiteral');
}

class LengthAccess extends AstNode {
  final AstNode object;

  const LengthAccess(this.object) : super('LengthAccess');
}

class MapLiteral extends AstNode {
  final List<MapEntry> entries;

  const MapLiteral(this.entries) : super('MapLiteral');
}

class MapEntry extends AstNode {
  final AstNode key;
  final AstNode value;

  const MapEntry(this.key, this.value) : super('MapEntry');
}

class SetLiteral extends AstNode {
  final List<AstNode> elements;

  const SetLiteral(this.elements) : super('SetLiteral');
}

class BreakStatement extends AstNode {
  final Token keyword;

  const BreakStatement(this.keyword) : super('BreakStatement');
}

class ToString extends AstNode {
  final AstNode expression;

  const ToString(this.expression) : super('ToString');
}

class TryStatement extends AstNode {
  final AstNode tryBlock;
  final List<CatchClause> catchClauses;
  final AstNode? finallyBlock;

  const TryStatement(this.tryBlock, this.catchClauses, this.finallyBlock)
      : super('TryStatement');
}

class CatchClause extends AstNode {
  final Token? exceptionType;
  final Token? exceptionVariable;
  final AstNode catchBlock;

  const CatchClause(this.exceptionType, this.exceptionVariable, this.catchBlock)
      : super('CatchClause');
}

class ThrowStatement extends AstNode {
  final AstNode expression;

  const ThrowStatement(this.expression) : super('ThrowStatement');
}
