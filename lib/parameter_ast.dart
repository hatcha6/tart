part of 'ast.dart';

class AstParameter extends AstNode {
  const AstParameter(super.tartType);
}

class EdgeInsets extends AstParameter {
  final AstNode? top;
  final AstNode? right;
  final AstNode? bottom;
  final AstNode? left;

  const EdgeInsets(
      super.tartType, this.top, this.right, this.bottom, this.left);
}

class EdgeInsetsAll extends EdgeInsets {
  const EdgeInsetsAll(AstNode value)
      : super('EdgeInsetsAll', value, value, value, value);
}

class EdgeInsetsSymmetric extends EdgeInsets {
  const EdgeInsetsSymmetric(AstNode? horizontal, AstNode? vertical)
      : super(
            'EdgeInsetsSymmetric', vertical, horizontal, vertical, horizontal);
}

class EdgeInsetsOnly extends EdgeInsets {
  const EdgeInsetsOnly(
      AstNode? top, AstNode? right, AstNode? bottom, AstNode? left)
      : super('EdgeInsetsOnly', top, right, bottom, left);
}

class MainAxisAlignment extends AstParameter {
  const MainAxisAlignment(super.tartType);
}

class MainAxisAlignmentStart extends MainAxisAlignment {
  const MainAxisAlignmentStart() : super('MainAxisAlignmentStart');
}

class MainAxisAlignmentCenter extends MainAxisAlignment {
  const MainAxisAlignmentCenter() : super('MainAxisAlignmentCenter');
}

class MainAxisAlignmentEnd extends MainAxisAlignment {
  const MainAxisAlignmentEnd() : super('MainAxisAlignmentEnd');
}

class MainAxisAlignmentSpaceBetween extends MainAxisAlignment {
  const MainAxisAlignmentSpaceBetween()
      : super('MainAxisAlignmentSpaceBetween');
}

class MainAxisAlignmentSpaceAround extends MainAxisAlignment {
  const MainAxisAlignmentSpaceAround() : super('MainAxisAlignmentSpaceAround');
}

class MainAxisAlignmentSpaceEvenly extends MainAxisAlignment {
  const MainAxisAlignmentSpaceEvenly() : super('MainAxisAlignmentSpaceEvenly');
}

class CrossAxisAlignment extends AstParameter {
  const CrossAxisAlignment(super.tartType);
}

class CrossAxisAlignmentStart extends CrossAxisAlignment {
  const CrossAxisAlignmentStart() : super('CrossAxisAlignmentStart');
}

class CrossAxisAlignmentCenter extends CrossAxisAlignment {
  const CrossAxisAlignmentCenter() : super('CrossAxisAlignmentCenter');
}

class CrossAxisAlignmentEnd extends CrossAxisAlignment {
  const CrossAxisAlignmentEnd() : super('CrossAxisAlignmentEnd');
}

class CrossAxisAlignmentStretch extends CrossAxisAlignment {
  const CrossAxisAlignmentStretch() : super('CrossAxisAlignmentStretch');
}

class CrossAxisAlignmentBaseline extends CrossAxisAlignment {
  const CrossAxisAlignmentBaseline() : super('CrossAxisAlignmentBaseline');
}

class Color extends AstParameter {
  final AstNode? r;
  final AstNode? g;
  final AstNode? b;
  final AstNode? a;

  const Color({this.r, this.g, this.b, this.a}) : super('Color');
}

class FontWeight extends AstParameter {
  const FontWeight(super.tartType);
}

class FontWeightBold extends FontWeight {
  const FontWeightBold() : super('FontWeightBold');
}

class FontWeightNormal extends FontWeight {
  const FontWeightNormal() : super('FontWeightNormal');
}

class TextStyle extends AstParameter {
  final AstNode? fontFamily;
  final AstNode? fontSize;
  final AstNode? color;
  final AstNode? fontWeight;

  const TextStyle({this.fontFamily, this.fontSize, this.color, this.fontWeight})
      : super('TextStyle');
}

class InputDecoration extends AstParameter {
  final AstNode? icon;
  final AstNode? iconColor;
  final AstNode? label;
  final AstNode? labelText;
  final AstNode? labelStyle;
  final AstNode? floatingLabelStyle;
  final AstNode? helperText;
  final AstNode? helperStyle;
  final AstNode? helperMaxLines;
  final AstNode? hintText;
  final AstNode? hintStyle;
  final AstNode? hintTextDirection;
  final AstNode? hintMaxLines;
  final AstNode? errorText;
  final AstNode? errorStyle;
  final AstNode? errorMaxLines;
  final AstNode? floatingLabelBehavior;
  final AstNode? isCollapsed;
  final AstNode? isDense;
  final AstNode? contentPadding;
  final AstNode? prefixIcon;
  final AstNode? prefixIconColor;
  final AstNode? prefix;
  final AstNode? prefixText;
  final AstNode? prefixStyle;
  final AstNode? suffixIcon;
  final AstNode? suffixIconColor;
  final AstNode? suffix;
  final AstNode? suffixText;
  final AstNode? suffixStyle;
  final AstNode? counterText;
  final AstNode? counterStyle;
  final AstNode? filled;
  final AstNode? fillColor;
  final AstNode? focusColor;
  final AstNode? hoverColor;
  final AstNode? errorBorder;
  final AstNode? focusedBorder;
  final AstNode? focusedErrorBorder;
  final AstNode? disabledBorder;
  final AstNode? enabledBorder;
  final AstNode? border;
  final AstNode? enabled;
  final AstNode? semanticCounterText;
  final AstNode? alignLabelWithHint;

  const InputDecoration({
    this.icon,
    this.iconColor,
    this.label,
    this.labelText,
    this.labelStyle,
    this.floatingLabelStyle,
    this.helperText,
    this.helperStyle,
    this.helperMaxLines,
    this.hintText,
    this.hintStyle,
    this.hintTextDirection,
    this.hintMaxLines,
    this.errorText,
    this.errorStyle,
    this.errorMaxLines,
    this.floatingLabelBehavior,
    this.isCollapsed,
    this.isDense,
    this.contentPadding,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefix,
    this.prefixText,
    this.prefixStyle,
    this.suffixIcon,
    this.suffixIconColor,
    this.suffix,
    this.suffixText,
    this.suffixStyle,
    this.counterText,
    this.counterStyle,
    this.filled,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.errorBorder,
    this.focusedBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.enabledBorder,
    this.border,
    this.enabled,
    this.semanticCounterText,
    this.alignLabelWithHint,
  }) : super('InputDecoration');
}

class Alignment extends AstParameter {
  const Alignment(super.tartType);
}

class AlignmentTopLeft extends Alignment {
  const AlignmentTopLeft() : super('AlignmentTopLeft');
}

class AlignmentTopCenter extends Alignment {
  const AlignmentTopCenter() : super('AlignmentTopCenter');
}

class AlignmentTopRight extends Alignment {
  const AlignmentTopRight() : super('AlignmentTopRight');
}

class AlignmentCenterLeft extends Alignment {
  const AlignmentCenterLeft() : super('AlignmentCenterLeft');
}

class AlignmentCenterRight extends Alignment {
  const AlignmentCenterRight() : super('AlignmentCenterRight');
}

class AlignmentBottomLeft extends Alignment {
  const AlignmentBottomLeft() : super('AlignmentBottomLeft');
}

class AlignmentBottomCenter extends Alignment {
  const AlignmentBottomCenter() : super('AlignmentBottomCenter');
}

class AlignmentBottomRight extends Alignment {
  const AlignmentBottomRight() : super('AlignmentBottomRight');
}

class AlignmentCenter extends Alignment {
  const AlignmentCenter() : super('AlignmentCenter');
}

class ScrollPhysics extends AstParameter {
  const ScrollPhysics(super.tartType);
}

class NeverScrollableScrollPhysics extends ScrollPhysics {
  const NeverScrollableScrollPhysics() : super('NeverScrollableScrollPhysics');
}

class AlwaysScrollableScrollPhysics extends ScrollPhysics {
  const AlwaysScrollableScrollPhysics()
      : super('AlwaysScrollableScrollPhysics');
}

class BouncingScrollPhysics extends ScrollPhysics {
  const BouncingScrollPhysics() : super('BouncingScrollPhysics');
}

class ClampingScrollPhysics extends ScrollPhysics {
  const ClampingScrollPhysics() : super('ClampingScrollPhysics');
}
