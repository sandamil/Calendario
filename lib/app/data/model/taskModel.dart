class Task {
  int? id;
  String? title;
  String? site;
  String? notes;
  int? startTimeMilliseconds;
  int? endTimeMilliseconds;
  // String? time;
  bool? isImportant;
  int? idAlarma;
  String? alarmaHora;
  String? alarmaActivadaString;
  bool? isAlarmaCreated;

  Task(
      {this.id,
      this.title,
      this.site,
      this.notes,
      this.startTimeMilliseconds,
      this.endTimeMilliseconds,
      // this.time,
      this.isImportant,
      this.idAlarma,
      this.alarmaHora,
      this.alarmaActivadaString,
      this.isAlarmaCreated
      });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'site': site,
      'notes': notes,
      'startTimeMilliseconds': startTimeMilliseconds,
      'endTimeMilliseconds': endTimeMilliseconds,
      // 'time': time,
      'isImportant': isImportant == true ? 1 : 0,
      'idAlarma': idAlarma,
      'alarmaHora': alarmaHora,
      'alarmaActivadaString': alarmaActivadaString,
      'isAlarmaCreated': isAlarmaCreated == true ? 1 : 0,
    };
  }

  Task.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    title = map['title'];
    site = map['site'];
    notes = map['notes'];
    startTimeMilliseconds = map['startTimeMilliseconds'];
    endTimeMilliseconds = map['endTimeMilliseconds'];
    // this.time = map['time'];
    isImportant = map['isImportant'] == 1 ? true : false;
    idAlarma = map['idAlarma'] ?? '';
    alarmaHora = map['alarmaHora'];
    alarmaActivadaString = map['alarmaActivadaString'];
    isAlarmaCreated = map['isAlarmaCreated'] == 1 ? true : false;
  }

  @override
  String toString() {
    return 'Travel '
        '{id: $id, '
        'title: $title, '
        'site: $site, '
        'notes: $notes, '
        'startTimeMilliseconds: $startTimeMilliseconds, '
        'endTimeMilliseconds: $endTimeMilliseconds, '
        'isImportant: $isImportant, '
        'idAlarma: $idAlarma, '
        'alarmaHora: $alarmaHora, '
        'alarmaActivadaString: $alarmaActivadaString, '
        'isAlarmaCreated: $isAlarmaCreated}, '
        '';
  }
}
