class CustomShitTemplate {
  int? id;
  int? day;
  int? month;
  int? year;
  int? position;
  String? alarm;

  CustomShitTemplate({
    this.id,
    this.day,
    this.month,
    this.year,
    this.position,
    this.alarm,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'day': day,
      'month': month,
      'year': year,
      'shift': position,
      'alarm': alarm,
    };
  }

  CustomShitTemplate.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    day = map['day'];
    month = map['month'];
    year = map['year'];
    position = map['shift'];
    alarm = map['alarm'];
  }

  @override
  String toString() {
    return 'NotasBkp '
        '{id: $id, '
        'day: $day, '
        'month: $month, '
        'year: $year, '
        'position: $position, '
        'alarm: $alarm, '
        '';
  }
}
