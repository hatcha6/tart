class ClassToTart {
  final String name;
  final Map<String, Function> methods;
  final Map<String, dynamic> properties;

  ClassToTart(this.name, this.methods, this.properties);

  factory ClassToTart.fromMap({
    required String name,
    required Map<String, Function> methods,
    required Map<String, dynamic> properties,
  }) {
    return ClassToTart(name, methods, properties);
  }

  Map<String, dynamic> toTartObject() {
    return {
      name: {
        ...methods,
        ...properties,
      }
    };
  }
}

// Helper mixin to make classes easily convertible to Tart
mixin TartConvertible {
  Map<String, Function> get tartMethods;
  Map<String, dynamic> get tartProperties;
  String get tartName;

  Map<String, dynamic> toTartObject() {
    return ClassToTart(
      tartName,
      tartMethods,
      tartProperties,
    ).toTartObject();
  }
}
