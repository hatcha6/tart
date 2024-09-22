part of 'ast.dart';

sealed class AstWidget extends AstNode {
  final Token name;

  const AstWidget(this.name);
}

class EdgeInsets extends AstNode {
  final double top;
  final double right;
  final double bottom;
  final double left;

  EdgeInsets(this.top, this.right, this.bottom, this.left);
}

class EdgeInsetsAll extends EdgeInsets {
  EdgeInsetsAll(double value) : super(value, value, value, value);
}

class EdgeInsetsSymmetric extends EdgeInsets {
  EdgeInsetsSymmetric(double horizontal, double vertical)
      : super(vertical, horizontal, vertical, horizontal);
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
  final int value;

  Color(this.value);
}

class FontWeight extends AstNode {
  FontWeight();
}

class FontWeightBold extends FontWeight {
  FontWeightBold();
}

class FontWeightNormal extends FontWeight {
  FontWeightNormal();
}

class TextStyle extends AstNode {
  final String? fontFamily;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  TextStyle(this.fontFamily, this.fontSize, this.color, this.fontWeight);
}

class Text extends AstWidget {
  final String text;

  Text(super.name, this.text);
}

class Column extends AstWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<AstWidget> children;

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
  final List<AstWidget> children;

  Row(
    super.name,
    this.children, [
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  ]);
}

class Container extends AstWidget {
  final AstWidget child;

  Container(super.name, this.child);
}

class Image extends AstWidget {
  final String url;

  Image(super.name, this.url);
}

class Padding extends AstWidget {
  final EdgeInsets padding;
  final AstWidget child;

  Padding(super.name, this.padding, this.child);
}

class Center extends AstWidget {
  final AstWidget child;

  Center(super.name, this.child);
}

class SizedBox extends AstWidget {
  final double? width;
  final double? height;
  final AstWidget? child;

  SizedBox(super.name, {this.width, this.height, this.child});
}

class Expanded extends AstWidget {
  final int flex;
  final AstWidget child;

  Expanded(super.name, this.child, {this.flex = 1});
}

class ElevatedButton extends AstWidget {
  final AstWidget child;
  final FunctionDeclaration onPressed;

  ElevatedButton(super.name, this.child, this.onPressed);
}
