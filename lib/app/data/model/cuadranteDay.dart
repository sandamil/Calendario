class CuadranteDay {
  int? id;
  String? cuadranteName;
  String? title;
  String? startHour;
  String? endHour;
  String? description;
  String? color;
  DateTime? dateTime;

  CuadranteDay(
      {this.id,
      this.cuadranteName,
      this.title,
      this.description,
      this.startHour,
      this.endHour,
      this.color,
      this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cuadranteName': cuadranteName,
      'title': title,
      'description': description,
      'startHour': startHour,
      'endHour': endHour,
      'color': color,
      'datetime': dateTime!.toIso8601String().substring(0, 10),
    };
  }

  factory CuadranteDay.fromMap(Map<String, dynamic> map) {
    return CuadranteDay(
      id: map['id'] as int,
      cuadranteName: map['cuadranteName'].toString(),
      title: map['title'] as String?,
      description: map['description'] as String?,
      startHour: map['startHour'] as String?,
      endHour: map['endHour'] as String?,
      color: map['color'] as String?,
      dateTime: DateTime.parse(map['datetime'].substring(0, 10)),
    );
  }
}
