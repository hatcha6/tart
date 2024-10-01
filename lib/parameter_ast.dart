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

class InputDecoration extends AstNode {
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
  });
}

class Alignment extends AstNode {
  const Alignment();
}

class AlignmentTopLeft extends Alignment {
  const AlignmentTopLeft();
}

class AlignmentTopCenter extends Alignment {
  const AlignmentTopCenter();
}

class AlignmentTopRight extends Alignment {
  const AlignmentTopRight();
}

class AlignmentCenterLeft extends Alignment {
  const AlignmentCenterLeft();
}

class AlignmentCenterRight extends Alignment {
  const AlignmentCenterRight();
}

class AlignmentBottomLeft extends Alignment {
  const AlignmentBottomLeft();
}

class AlignmentBottomCenter extends Alignment {
  const AlignmentBottomCenter();
}

class AlignmentBottomRight extends Alignment {
  const AlignmentBottomRight();
}

class AlignmentCenter extends Alignment {
  const AlignmentCenter();
}

class ScrollPhysics extends AstNode {
  const ScrollPhysics();
}

class NeverScrollableScrollPhysics extends ScrollPhysics {
  const NeverScrollableScrollPhysics();
}

class AlwaysScrollableScrollPhysics extends ScrollPhysics {
  const AlwaysScrollableScrollPhysics();
}

class BouncingScrollPhysics extends ScrollPhysics {
  const BouncingScrollPhysics();
}

class ClampingScrollPhysics extends ScrollPhysics {
  const ClampingScrollPhysics();
}

class Icons extends AstNode {
  const Icons();
}

class IconsArrowForward extends Icons {
  const IconsArrowForward();
}

class IconsArrowBack extends Icons {
  const IconsArrowBack();
}

class IconsInfo extends Icons {
  const IconsInfo();
}

class IconsAdd extends Icons {
  const IconsAdd();
}

class IconsRemove extends Icons {
  const IconsRemove();
}

class IconsEdit extends Icons {
  const IconsEdit();
}

class IconsDelete extends Icons {
  const IconsDelete();
}

class IconsSave extends Icons {
  const IconsSave();
}

class IconsCancel extends Icons {
  const IconsCancel();
}

class IconsSearch extends Icons {
  const IconsSearch();
}

class IconsClear extends Icons {
  const IconsClear();
}

class IconsClose extends Icons {
  const IconsClose();
}

class IconsShoppingBag extends Icons {
  const IconsShoppingBag();
}

class IconsAttractions extends Icons {
  const IconsAttractions();
}

class IconsRestaurant extends Icons {
  const IconsRestaurant();
}

class IconsStar extends Icons {
  const IconsStar();
}
