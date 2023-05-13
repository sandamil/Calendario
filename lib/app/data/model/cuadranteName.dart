class CuadranteName {
  String name;

  CuadranteName({
    required this.name,
  });

  factory CuadranteName.fromJson(Map<String, dynamic> parsedJson) {
    return CuadranteName(
        name: parsedJson['name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
    };
  }
}
