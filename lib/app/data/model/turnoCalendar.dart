import 'package:flutter/foundation.dart';

class Cuadrante {
  int? id;
  String? title;
  String? startHour;
  String? endHour;
  String? description;
  String? color;
  DateTime? dateTime;
  String? site;
  String? notes;
  int? startTimeMilliseconds;
  int? endTimeMilliseconds;
  String? time;
  bool? isImportant;
  bool? isCuadrante;

  Cuadrante(
      {
        this.id,
        this.title,
      this.description,
      this.startHour,
      this.endHour,
      this.color,
      this.dateTime,
      this.site,
      this.notes,
      this.startTimeMilliseconds,
      this.endTimeMilliseconds,
      this.time,
      this.isImportant,
      this.isCuadrante});

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
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['starthour'] = this.startHour;
    data['endhour'] = this.endHour;
    data['color'] = this.color;
    data['datetime'] = this.dateTime?.toIso8601String();
    data['site'] = this.site;
    data['notes'] = this.notes;
    data['startTimeMilliseconds']= this.startTimeMilliseconds;
    data['endTimeMilliseconds']= this.endTimeMilliseconds;
    data['time']= this.time;
    data['isImportant']= this.isImportant == true ? 1 : 0;
    data['isCuadrante']= this.isCuadrante == true ? 1 : 0;

    return data;
  }

  Cuadrante.fromDb(Map<dynamic, dynamic> data)
      : this.id = data['id'],
        this.title = data['title'],
        this.description = data['description'],
        this.startHour = data['starthour'],
        this.endHour = data['endhour'],
        this.color = data['color'],
        this.site = data['site'],
        this.notes = data['notes'],
        this.startTimeMilliseconds = data['startTimeMilliseconds'],
        this.endTimeMilliseconds = data['endTimeMilliseconds'],
        this.time = data['time'],
        this.isImportant = data['isImportant'] == 1 ? true : false,
        this.isCuadrante = data['isCuadrante'] == 1 ? true : false,
        this.dateTime = DateTime.tryParse(data['datetime'],
        );
}
