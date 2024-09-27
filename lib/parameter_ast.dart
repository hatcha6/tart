part of 'ast.dart';

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
  final AstNode? r;
  final AstNode? g;
  final AstNode? b;
  final AstNode? a;

  const Color({this.r, this.g, this.b, this.a});
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
  final AstNode? fontWeight;

  const TextStyle(
      {this.fontFamily, this.fontSize, this.color, this.fontWeight});
}
