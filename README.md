<p align="center">
  <img src="https://raw.githubusercontent.com/hatcha6/tart/main/assets/logo.svg" alt="Tart Logo" width="200"/>
</p>

# 🍋 Tart

Tiny Dart, Big Impact! 🚀
**Note:** Tart is currently in the early stages of development and is not yet ready for production use.

[![Pub Version](https://img.shields.io/pub/v/tart_dev.svg)](https://pub.dev/packages/tart_dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/hatcha6/tart/graph/badge.svg?token=4H96A1D475)](https://codecov.io/gh/hatcha6/tart)

## 🌟 Features

- 🎯 Lightweight Dart parser with Flutter widget support
- 🧩 Modular and extensible design with asynchronous parsing
- 🚦 Comprehensive token handling and caching
- 🌳 Abstract Syntax Tree (AST) generation for Dart and Flutter widgets
- 🚀 Asynchronous lexing and parsing for improved performance
- 🧪 Thoroughly tested with benchmarking capabilities
- 🔄 Dynamic code execution in Flutter applications
- 🖼️ Flutter widget creation from Tart code
- 🔍 Detailed error reporting and synchronization

## 🚀 Getting Started

Add `tart_dev` to your `pubspec.yaml`:

```yaml
dependencies:
    tart_dev: ^0.0.3
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
  final tart = Tart();
  final source = 'var x = 42; print(x);';
  
  final (result, _) = tart.run(source);
  print('Result: $result');

  // With benchmarking
  final (result, benchmarks) = tart.run(source, benchmark: true);
  print('Benchmark Result: $result');
  print('Lexer time: ${benchmarks?.lexerTime}s');
  print('Parser time: ${benchmarks?.parserTime}s');
  print('Evaluator time: ${benchmarks?.evaluatorTime}s');

  return runApp(result)
}
```

For more examples, check out the `/example` folder in our GitHub repository.

## 🛠️ API Reference

Tart provides the following main classes:

- `Lexer`: Tokenizes the input source code
- `Parser`: Generates an AST from tokens
- `Token`: Represents individual lexical units
- `AST`: Various AST node classes for different language constructs
- `Evaluator`: Executes the parsed AST
- `Tart`: Main class for running Tart code
- `TartProvider`: Flutter widget for providing Tart instance
- `TartStatefulWidget`: Flutter widget for rendering Tart code

For detailed API documentation, visit our [API reference page](https://pub.dev/documentation/tart_dev/latest/).

## Why Tart?

Tart offers several advantages for Flutter development:

- **Flutter-focused**: Optimized specifically for Flutter applications
- **Familiar syntax**: Nearly identical to Dart, minimizing learning curve
- **Performance**: Designed for efficiency in Flutter-specific use cases
- **Developer experience**: Intuitive API and enhanced tooling support
- **Faster development**: Enables quicker iterations on dynamic code
- **Improved debugging**: Detailed, Flutter-specific error messages
- **Smaller footprint**: Minimal impact on overall app size
- **Focused feature set**: Polished core functionalities for common Flutter scenarios

Tart provides a specialized, Flutter-centric solution for dynamic code execution, offering improved performance and an enhanced developer experience.

## 🤝 Contributing

We welcome contributions! Please see our [contributing guide](CONTRIBUTING.md) for more details.

## 📄 License

Tart is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## 💖 Support

If you find Tart helpful, consider giving it a star on GitHub and sharing it with others!

---

Made with 🍋 by the Tart Dev team
