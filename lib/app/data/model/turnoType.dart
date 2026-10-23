class TurnoType {
  int? id;
  String? title;
  String? description;
  String? startHour;
  String? endHour;
  String? color;
  bool reminderEnabled;
  int reminderMinutesBefore;

  TurnoType({
    this.id,
    this.title,
    this.description,
    this.startHour,
    this.endHour,
    this.color,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startHour': startHour,
      'endHour': endHour,
      'color': color,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderMinutesBefore': reminderMinutesBefore,
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
      reminderEnabled: (map['reminderEnabled'] as num?)?.toInt() == 1,
      reminderMinutesBefore:
          (map['reminderMinutesBefore'] as num?)?.toInt() ?? 0,
    );
  }
}
