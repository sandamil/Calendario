import 'package:flutter/foundation.dart';

class Cuadrante {
  int? id;
  String? title;
  String? startHour;
  String? endHour;
  String? description;
  String? color;
  DateTime? dateTime;

  Cuadrante({
      this.id,
      this.title,
      this.description,
      this.startHour,
      this.endHour,
      this.color,
      this.dateTime
  });





  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title': title,
      'description': description,
      'startHour': startHour,
      'endHour': endHour,
      'color': color,
      'datetime': dateTime?.toIso8601String(),
    };
  }

/*  Map<String, dynamic> toDb() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['starthour'] = this.startHour;
    data['endhour'] = this.endHour;
    data['color'] = this.color;
    data['datetime'] = this.dateTime?.toIso8601String();
    return data;
  }*/

/*  Cuadrante.fromDb(Map<String, dynamic> data)
      : this.id = data['id'],
        this.title = data['title'],
        this.description = data['description'],
        this.startHour = data['starthour'],
        this.endHour = data['endhour'],
        this.color = data['color'],
        this.dateTime = DateTime.tryParse(data['datetime']);*/



  factory Cuadrante.fromMap(Map<String, dynamic> map) {
    return Cuadrante(
      id: map['id'] as int,
      title: map['title'] as String?,
      description: map['description'] as String?,
      startHour: map['startHour'] as String?,
      endHour: map['endHour'] as String?,
      color: map['color'] as String?,
      dateTime: DateTime.tryParse(map['datetime']),
    );
  }
}
