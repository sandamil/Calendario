import 'package:flutter/foundation.dart';

class Cuadrante {
  int? id;
  String? title;
  String? startHour;
  String? endHour;
  String? description;
  String? color;
  DateTime? dateTime;

  Cuadrante(
      {this.title,
      this.description,
      this.startHour,
      this.endHour,
      this.color,
      this.dateTime});

  Cuadrante.shiftMorning({@required this.dateTime})
      : this.title = 'Morning',
        this.description = 'Shift',
        this.startHour = '07:00',
        this.color = '#00ff00',
        this.endHour = '15:00';

  Cuadrante.shiftAfternoon({@required this.dateTime})
      : this.title = 'Afternoon',
        this.description = 'Shift',
        this.color = '#ffa500',
        this.startHour = '15:00',
        this.endHour = '23:00';

  Cuadrante.shiftNight({@required this.dateTime})
      : this.title = 'Night',
        this.startHour = '23:00',
        this.color = '#ff0000',
        this.description = 'Shift',
        this.endHour = '07:00';

  Map<String, dynamic> toDb() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['starthour'] = this.startHour;
    data['endhour'] = this.endHour;
    data['color'] = this.color;
    data['datetime'] = this.dateTime?.toIso8601String();
    return data;
  }

  Cuadrante.fromDb(Map<String, dynamic> data)
      : this.id = data['id'],
        this.title = data['title'],
        this.description = data['description'],
        this.startHour = data['starthour'],
        this.endHour = data['endhour'],
        this.color = data['color'],
        this.dateTime = DateTime.tryParse(data['datetime']);
}
