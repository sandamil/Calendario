import 'package:flutter/material.dart';

class TurnoType {
  int? id;
  String? title;
  String? description;
  String? startHour;
  String? endHour;
  String? color;


  TurnoType(
      {this.title,
      this.description,
      this.startHour,
      this.endHour,
      this.color,});

    TurnoType.shiftMorning()
      : this.title = 'Morning',
        this.description = 'Shift',
        this.startHour = '07:00',
        this.color = '#00ff00',
        this.endHour = '15:00';

  TurnoType.shiftAfternoon()
      : this.title = 'Afternoon',
        this.description = 'Shift',
        this.color = '#ffa500',
        this.startHour = '15:00',
        this.endHour = '23:00';

  TurnoType.shiftNight()
      : this.title = '',
        this.startHour = '',
        this.color = '#ffff00',
        this.description = '',
        this.endHour = '';

  Map<String, dynamic> toDb() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['starthour'] = this.startHour;
    data['endhour'] = this.endHour;
    data['color'] = this.color;
    return data;
  }

  TurnoType.fromDb(Map<String, dynamic> data)
      : this.id = data['id'],
        this.title = data['title'],
        this.description = data['description'],
        this.startHour = data['starthour'],
        this.endHour = data['endhour'],
        this.color = data['color'];
}
