# 🍋 Tart

Tiny Dart, Big Impact! 🚀

[![Pub Version](https://img.shields.io/pub/v/tart_dev.svg)](https://pub.dev/packages/tart_dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## 🌟 Features

- 🎯 Lightweight Dart parser
- 🧩 Modular and extensible design
- 🚦 Comprehensive token handling
- 🌳 Abstract Syntax Tree (AST) generation
- 🧪 Thoroughly tested

## 🚀 Getting Started

Add `tart_dev` to your `pubspec.yaml`:

```yaml
dependencies:
    tart_dev: ^0.0.1
```

then run:

```bash
dart pub get
```


## 📚 Usage

Here's a quick example of how to use Tart:

```dart
import 'package:tart_dev/tart.dart';
void main() {
    final source = 'var x = 42;';
    final lexer = Lexer(source);
    final tokens = lexer.scanTokens();
    final parser = Parser(tokens);
    final ast = parser.parse();
    print('Tokens: $tokens');
    print('AST: $ast');
}
```


For more examples, check out the `/example` folder in our GitHub repository.

## 🛠️ API Reference

Tart provides the following main classes:

- `Lexer`:  Tokenizes the input source code
- `Parser`: Generates an AST from tokens
- `Token`:  Represents individual lexical units
- `AST`:    Various AST node classes for different language constructs

For detailed API documentation, visit our [API reference page](https://pub.dev/documentation/tart_dev/latest/).

## 🤝 Contributing

We welcome contributions! Please see our [contributing guide](CONTRIBUTING.md) for more details.

## 📄 License

Tart is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## 💖 Support

If you find Tart helpful, consider giving it a star on GitHub and sharing it with others!

---

Made with 🍋 by the Tart Dev team
