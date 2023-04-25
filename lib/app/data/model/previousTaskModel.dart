class PreviousTask {
  int? id;
  int? day;
  int? month;
  int? year;
  String? note;
  String? alarm;

  PreviousTask({
    this.id,
    this.day,
    this.month,
    this.year,
    this.note,
    this.alarm,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'day': day,
      'month': month,
      'year': year,
      'note': note,
      'alarm': alarm,
    };
  }

  PreviousTask.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    day = map['day'];
    month = map['month'];
    year = map['year'];
    note = map['note'];
    alarm = map['alarm'];
  }

  @override
  String toString() {
    return 'Travel '
        '{id: $id, '
        'day: $day, '
        'month: $month, '
        'year: $year, '
        'note: $note, '
        'alarm: $alarm, '
        '';
  }
}
