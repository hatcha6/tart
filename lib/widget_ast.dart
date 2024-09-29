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
  final Token name;

  const AstWidget(this.name);
}

class Text extends AstWidget {
  final AstNode text;
  final TextStyle? style;

  const Text(super.name, this.text, [this.style]);
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

class ListViewBuilder extends AstWidget {
  final FunctionDeclaration itemBuilder;
  final AstNode itemCount;

  const ListViewBuilder(super.name, this.itemBuilder, this.itemCount);
}

class GridViewBuilder extends AstWidget {
  final FunctionDeclaration itemBuilder;
  final AstNode itemCount;
  final AstNode maxCrossAxisExtent;

  const GridViewBuilder(
    super.name,
    this.itemBuilder,
    this.itemCount,
    this.maxCrossAxisExtent,
  );
}

class TextField extends AstWidget {
  final AstNode? decoration;
  final FunctionDeclaration? onSubmitted;
  final FunctionDeclaration? onChanged;

  const TextField(super.name,
      [this.decoration, this.onSubmitted, this.onChanged]);
}

class ListTile extends AstWidget {
  final AstNode? leading;
  final AstNode? title;
  final AstNode? subtitle;
  final AstNode? trailing;
  final FunctionDeclaration? onTap;

  const ListTile(super.name,
      [this.leading, this.title, this.subtitle, this.trailing, this.onTap]);
}

class Stack extends AstWidget {
  final AstNode children;
  final AstNode? alignment;

  const Stack(super.name, this.children, [this.alignment]);
}

class TextButton extends AstWidget {
  final AstWidget child;
  final FunctionDeclaration onPressed;

  const TextButton(super.name, this.child, this.onPressed);
}

class OutlinedButton extends AstWidget {
  final AstWidget child;
  final FunctionDeclaration onPressed;

  const OutlinedButton(super.name, this.child, this.onPressed);
}

class LinearProgressIndicator extends AstWidget {
  final AstNode? value;
  final AstNode? backgroundColor;
  final AstNode? color;
  const LinearProgressIndicator(super.name,
      [this.value, this.backgroundColor, this.color]);
}

class CircularProgressIndicator extends AstWidget {
  final AstNode? value;
  final AstNode? backgroundColor;
  final AstNode? color;
  const CircularProgressIndicator(super.name,
      [this.value, this.backgroundColor, this.color]);
}

class CustomAstWidget extends AstWidget {
  final Map<String, AstNode> params;

  const CustomAstWidget(super.name, this.params);
}
