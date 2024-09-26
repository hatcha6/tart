part of 'ast.dart';

sealed class AstWidget extends AstNode {
  final Token name;

  const AstWidget(this.name);
}

class EdgeInsets extends AstNode {
  final AstNode? top;
  final AstNode? right;
  final AstNode? bottom;
  final AstNode? left;

  const EdgeInsets(this.top, this.right, this.bottom, this.left);
}

class EdgeInsetsAll extends EdgeInsets {
  EdgeInsetsAll(AstNode value) : super(value, value, value, value);
}

class EdgeInsetsSymmetric extends EdgeInsets {
  EdgeInsetsSymmetric(AstNode? horizontal, AstNode? vertical)
      : super(vertical, horizontal, vertical, horizontal);
}

class EdgeInsetsOnly extends EdgeInsets {
  const EdgeInsetsOnly(super.top, super.right, super.bottom, super.left);
}

class MainAxisAlignment extends AstNode {
  const MainAxisAlignment();
}

class MainAxisAlignmentStart extends MainAxisAlignment {
  const MainAxisAlignmentStart();
}

class MainAxisAlignmentCenter extends MainAxisAlignment {
  const MainAxisAlignmentCenter();
}

class MainAxisAlignmentEnd extends MainAxisAlignment {
  const MainAxisAlignmentEnd();
}

class MainAxisAlignmentSpaceBetween extends MainAxisAlignment {
  const MainAxisAlignmentSpaceBetween();
}

class MainAxisAlignmentSpaceAround extends MainAxisAlignment {
  const MainAxisAlignmentSpaceAround();
}

class MainAxisAlignmentSpaceEvenly extends MainAxisAlignment {
  const MainAxisAlignmentSpaceEvenly();
}

class CrossAxisAlignment extends AstNode {
  const CrossAxisAlignment();
}

class CrossAxisAlignmentStart extends CrossAxisAlignment {
  const CrossAxisAlignmentStart();
}

class CrossAxisAlignmentCenter extends CrossAxisAlignment {
  const CrossAxisAlignmentCenter();
}

class CrossAxisAlignmentEnd extends CrossAxisAlignment {
  const CrossAxisAlignmentEnd();
}

class CrossAxisAlignmentStretch extends CrossAxisAlignment {
  const CrossAxisAlignmentStretch();
}

class CrossAxisAlignmentBaseline extends CrossAxisAlignment {
  const CrossAxisAlignmentBaseline();
}

class Color extends AstNode {
  final AstNode value;

  const Color(this.value);
}

class FontWeight extends AstNode {
  const FontWeight();
}

class FontWeightBold extends FontWeight {
  const FontWeightBold();
}

class FontWeightNormal extends FontWeight {
  const FontWeightNormal();
}

class TextStyle extends AstNode {
  final AstNode? fontFamily;
  final AstNode? fontSize;
  final AstNode? color;
  final FontWeight? fontWeight;

  const TextStyle(this.fontFamily, this.fontSize, this.color, this.fontWeight);
}

class Text extends AstWidget {
  final AstNode text;

  const Text(super.name, this.text);
}

class Column extends AstWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final AstNode children;

  const Column(
    super.name,
    this.children, [
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  ]);
}

class Row extends AstWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final AstNode children;

  const Row(
    super.name,
    this.children, [
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  ]);
}

class Container extends AstWidget {
  final AstWidget child;

  const Container(super.name, this.child);
}

class Image extends AstWidget {
  final AstNode url;

  const Image(super.name, this.url);
}

class Padding extends AstWidget {
  final EdgeInsets padding;
  final AstWidget child;

  const Padding(super.name, this.padding, this.child);
}

class Center extends AstWidget {
  final AstWidget child;

  const Center(super.name, this.child);
}

class SizedBox extends AstWidget {
  final AstNode? width;
  final AstNode? height;
  final AstWidget? child;

  const SizedBox(super.name, {this.width, this.height, this.child});
}

class Expanded extends AstWidget {
  final AstNode? flex;
  final AstWidget child;

  const Expanded(super.name, this.child, [this.flex]);
}

class ElevatedButton extends AstWidget {
  final AstWidget child;
  final FunctionDeclaration onPressed;

  const ElevatedButton(super.name, this.child, this.onPressed);
}

class Card extends AstWidget {
  final AstWidget child;
  final AstNode? elevation;

  const Card(super.name, this.child, [this.elevation]);
}

class ListView extends AstWidget {
  final AstNode children;

  const ListView(super.name, this.children);
}

class GridView extends AstWidget {
  final AstNode maxCrossAxisExtent;
  final AstNode children;

  const GridView(super.name, this.children, this.maxCrossAxisExtent);
}
