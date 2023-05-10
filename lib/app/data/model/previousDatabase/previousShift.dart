class PreviousShift {
  int? id;
  String? title;
  String? shortTitle;
  String? timeFrom;
  String? timeTo;
  String? color;
  String? location;
  String? alarm;

  PreviousShift({
    this.id,
    this.title,
    this.shortTitle,
    this.timeFrom,
    this.timeTo,
    this.color,
    this.location,
    this.alarm,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'short': shortTitle,
      'timeFrom': timeFrom,
      'timeTo': timeTo,
      'color': color,
      'location': location,
      'alarm': alarm,
    };
  }

  PreviousShift.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    title = map['title'];
    shortTitle = map['short'];
    timeFrom = map['timeFrom'];
    timeTo = map['timeTo'];
    color = map['color'];
    location = map['location'];
    alarm = map['alarm'];
  }

  @override
  String toString() {
    return 'NotasBkp '
        '{id: $id, '
        'title: $title, '
        'shortTitle: $shortTitle, '
        'timeFrom: $timeFrom, '
        'timeTo: $timeTo, '
        'color: $color, '
        'location: $location, '
        'alarm: $alarm, '
        '';
  }
}
