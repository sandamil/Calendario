class CuadranteName {
  String name;

  CuadranteName({
    required this.name,
  });

  factory CuadranteName.fromJson(Map<String, String> parsedJson) {
    return CuadranteName(
        name: parsedJson['name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
    };
  }
}
