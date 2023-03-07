class Task {
   int? id;
   String? title;
   String? site;
   String? notes;
   int? startTimeMilliseconds;
   int? endTimeMilliseconds;
   String? time;
   bool? isImportant;

  Task(
      {this.id,
      this.title,
      this.site,
      this.notes,
      this.startTimeMilliseconds,
      this.endTimeMilliseconds,
      this.time,
      this.isImportant});

  Map<dynamic , dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'site': site,
      'notes': notes,
      'startTimeMilliseconds': startTimeMilliseconds,
      'endTimeMilliseconds': endTimeMilliseconds,
      'time': time,
      'isImportant': this.isImportant == true ? 1 : 0,
    };
  }

  Task.fromMap(Map<dynamic, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.site = map['site'];
    this.notes = map['notes'];
    this.startTimeMilliseconds = map['startTimeMilliseconds'];
    this.endTimeMilliseconds = map['endTimeMilliseconds'];
    this.time = map['time'];
    this.isImportant = map['isImportant'] == 1 ? true : false;
  }

  @override
  String toString() {
    return 'Travel {id: $id, title: $title, site: $site, notes: $notes, startTimeMilliseconds: $startTimeMilliseconds, endTimeMilliseconds: $endTimeMilliseconds}, time: $time}';
  }
}
