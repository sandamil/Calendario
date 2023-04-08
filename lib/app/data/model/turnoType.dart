class TurnoType {
  int? id;
  String? title;
  String? description;
  String? startHour;
  String? endHour;
  String? color;

  TurnoType({
    this.id,
    this.title,
    this.description,
    this.startHour,
    this.endHour,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startHour': startHour,
      'endHour': endHour,
      'color': color,
    };
  }

  factory TurnoType.fromMap(Map<String, dynamic> map) {
    return TurnoType(
      id: map['id'] as int,
      title: map['title'] as String?,
      description: map['description'] as String?,
      startHour: map['startHour'] as String?,
      endHour: map['endHour'] as String?,
      color: map['color'] as String?,
    );
  }
}
