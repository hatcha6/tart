part of 'ast.dart';

/// Represents an abstract syntax tree node for a Flutter widget.
///
/// To add a new widget:
/// 1. Create a new subclass of [AstWidget] in this file.
/// 2. In [Parser], add a new case to the [flutterWidgetDeclaration] method
///    to parse the new widget type.
/// 3. In [Evaluator], add a new case to the [_evaluateWidget] method
///    to evaluate and create the corresponding Flutter widget.
///
/// Example:
/// ```dart
/// class MyNewWidget extends AstWidget {
///   final AstNode someProperty;
///   const MyNewWidget(Token name, this.someProperty) : super(name);
/// }
/// ```
sealed class AstWidget extends AstNode {
  const AstWidget(super.tartType);
}

class Text extends AstWidget {
  final AstNode text;
  final TextStyle? style;

  const Text(this.text, [this.style]) : super('Text');
}

class Column extends AstWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final AstNode children;

  const Column(
    this.children, [
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  ]) : super('Column');
}

class Row extends AstWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final AstNode children;

  const Row(
    this.children, [
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  ]) : super('Row');
}

class Container extends AstWidget {
  final AstNode? width;
  final AstNode? height;
  final AstNode? color;
  final AstWidget? child;

  const Container([this.child, this.width, this.height, this.color])
      : super('Container');
}

class Image extends AstWidget {
  final AstNode url;

  const Image(this.url) : super('Image');
}

class Padding extends AstWidget {
  final EdgeInsets padding;
  final AstWidget child;

  const Padding(this.padding, this.child) : super('Padding');
}

class Center extends AstWidget {
  final AstWidget child;

  const Center(this.child) : super('Center');
}

class SizedBox extends AstWidget {
  final AstNode? width;
  final AstNode? height;
  final AstWidget? child;

  const SizedBox({this.width, this.height, this.child}) : super('SizedBox');
}

class Expanded extends AstWidget {
  final AstNode? flex;
  final AstWidget child;

  const Expanded(this.child, [this.flex]) : super('Expanded');
}

class ElevatedButton extends AstWidget {
  final AstWidget child;
  final AstNode onPressed;

  const ElevatedButton(this.child, this.onPressed) : super('ElevatedButton');
}

class Card extends AstWidget {
  final AstWidget child;
  final AstNode? elevation;

  const Card(this.child, [this.elevation]) : super('Card');
}

class ListView extends AstWidget {
  final AstNode children;
  final AstNode? shrinkWrap;
  final AstNode? physics;

  const ListView(this.children, [this.shrinkWrap, this.physics])
      : super('ListView');
}

class GridView extends AstWidget {
  final AstNode maxCrossAxisExtent;
  final AstNode children;
  final AstNode? shrinkWrap;
  final AstNode? physics;

  const GridView(this.children, this.maxCrossAxisExtent,
      [this.shrinkWrap, this.physics])
      : super('GridView');
}

class ListViewBuilder extends AstWidget {
  final AstNode itemBuilder;
  final AstNode itemCount;
  final AstNode? shrinkWrap;
  final AstNode? physics;

  const ListViewBuilder(this.itemBuilder, this.itemCount,
      [this.shrinkWrap, this.physics])
      : super('ListViewBuilder');
}

class GridViewBuilder extends AstWidget {
  final AstNode itemBuilder;
  final AstNode itemCount;
  final AstNode maxCrossAxisExtent;
  final AstNode? shrinkWrap;
  final AstNode? physics;

  const GridViewBuilder(
    this.itemBuilder,
    this.itemCount,
    this.maxCrossAxisExtent,
    this.shrinkWrap,
    this.physics,
  ) : super('GridViewBuilder');
}

class TextField extends AstWidget {
  final AstNode? decoration;
  final AstNode? onSubmitted;
  final AstNode? onChanged;

  const TextField([this.decoration, this.onSubmitted, this.onChanged])
      : super('TextField');
}

class ListTile extends AstWidget {
  final AstNode? leading;
  final AstNode? title;
  final AstNode? subtitle;
  final AstNode? trailing;
  final AstNode? onTap;

  const ListTile(
      [this.leading, this.title, this.subtitle, this.trailing, this.onTap])
      : super('ListTile');
}

class Stack extends AstWidget {
  final AstNode children;
  final AstNode? alignment;

  const Stack(this.children, [this.alignment]) : super('Stack');
}

class TextButton extends AstWidget {
  final AstWidget child;
  final AstNode onPressed;

  const TextButton(this.child, this.onPressed) : super('TextButton');
}

class OutlinedButton extends AstWidget {
  final AstWidget child;
  final AstNode onPressed;

  const OutlinedButton(this.child, this.onPressed) : super('OutlinedButton');
}

class LinearProgressIndicator extends AstWidget {
  final AstNode? value;
  final AstNode? backgroundColor;
  final AstNode? color;
  const LinearProgressIndicator([this.value, this.backgroundColor, this.color])
      : super('LinearProgressIndicator');
}

class CircularProgressIndicator extends AstWidget {
  final AstNode? value;
  final AstNode? backgroundColor;
  final AstNode? color;
  const CircularProgressIndicator(
      [this.value, this.backgroundColor, this.color])
      : super('CircularProgressIndicator');
}

class CustomAstWidget extends AstWidget {
  final Token name;
  final Map<String, AstNode> params;

  const CustomAstWidget(this.name, this.params) : super('CustomAstWidget');
}

class SingleChildScrollView extends AstWidget {
  final AstWidget child;

  const SingleChildScrollView(this.child) : super('SingleChildScrollView');
}

class MaterialApp extends AstWidget {
  final AstWidget home;

  const MaterialApp(this.home) : super('MaterialApp');
}

class Scaffold extends AstWidget {
  final AstWidget? appBar;
  final AstWidget? body;
  final AstWidget? floatingActionButton;

  const Scaffold(this.appBar, this.body, this.floatingActionButton)
      : super('Scaffold');
}

class FloatingActionButton extends AstWidget {
  final AstWidget child;
  final AstNode onPressed;

  const FloatingActionButton(this.child, this.onPressed)
      : super('FloatingActionButton');
}

class AppBar extends AstWidget {
  final AstNode title;
  final AstNode? leading;
  final AstNode? actions;

  const AppBar(this.title, [this.leading, this.actions]) : super('AppBar');
}

class Icon extends AstWidget {
  final AstNode icon;

  const Icon(this.icon) : super('Icon');
}

class Positioned extends AstWidget {
  final AstNode? left;
  final AstNode? top;
  final AstNode? right;
  final AstNode? bottom;
  final AstWidget? child;

  const Positioned([this.left, this.top, this.right, this.bottom, this.child])
      : super('Positioned');
}

class StatefulBuilder extends AstWidget {
  final AstNode builder;

  const StatefulBuilder(this.builder) : super('StatefulBuilder');
}
