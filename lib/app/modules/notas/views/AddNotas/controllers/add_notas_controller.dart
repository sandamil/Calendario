import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class AddNotasController extends GetxController {

  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;


  bool headerShouldHide = false;
  bool noWarn = false;

  TextEditingController title = TextEditingController();
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isImportant = false.obs;

  DateTime time = DateTime.now();

  static var warnDefaultt = 'Al principio';


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void addTravelEvent() {
    print('addTravelEvent' '$startTime');
    final int daysNum = endTime.value.difference(startTime.value).inDays;
    if (0 == daysNum) {
      final DateTime time = DateTime(
          startTime.value.year, startTime.value.month, startTime.value.day);
      setTravelEvent(
        time,
        title.text,
        site.text,
        startTime.value,
        endTime.value,
        isImportant.value,
      );
    } else {
      for (int i = 0; i <= daysNum; i++) {
        DateTime _time = DateTime(startTime.value.year, startTime.value.month,
            startTime.value.day + i);
        if (0 == i) {
          setTravelEvent(_time, title.text, site.text, startTime.value,
              DateTime(0, 0, 0, 24), isImportant.value);
        } else if (i == daysNum) {
          setTravelEvent(time, title.text, site.text, DateTime(0, 0, 0, 0),
              endTime.value, isImportant.value);
        } else {
          setTravelEvent(_time, title.text, site.text, DateTime(0, 0, 0, 0),
              DateTime(0, 0, 0, 24), isImportant.value);
        }
      }
    }
  }

  void setTravelEvent(DateTime time, String title, String site,
      DateTime startTime, DateTime endTime, bool isImportant) async {
    if (events[time] != null) {
      print('if (events 1 =========' '${title}');
      events[time]?.add(Task(
        title: title,
        site: site,
        startTimeMilliseconds: startTime.millisecondsSinceEpoch,
        endTimeMilliseconds: endTime.millisecondsSinceEpoch,
        isImportant: isImportant,
      ));
    } else {
      print('if (events 2 =========' '${title}');
      events[time] = [
        Task(
          title: title,
          site: site,
          startTimeMilliseconds: startTime.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.millisecondsSinceEpoch,
          isImportant: isImportant,
        )
      ];
    }
  }

  addEvent() async {
    Task _item = await DbProvider.instance.select(
      await DbProvider.instance.insertNotas(
        Task(
            title: title.text,
            site: site.text,
            notes: notes.text,
            isImportant: isImportant.value,
            startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
            endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
            time: Jiffy().format('yyyy-MM-dd h:mm:ss a')),
      ),
    );
    print('addEvent' '${title.text}');
  }

  void markImportantAsDirty() {
    isImportant.value = !isImportant.value;
    update();
  }

  List warnList = [
    {
      'name': warnDefaultt,
      'select': true,
      'time': (DateTime time) => time,
      'id': 0
    },
    {
      'name': '5 minutos de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(minutes: 5)),
      'id': 1
    },
    {
      'name': '10 minutos de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(minutes: 10)),
      'id': 2
    },
    {
      'name': '15 minutos de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(minutes: 15)),
      'id': 3
    },
    {
      'name': '30 minutos de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(minutes: 30)),
      'id': 4
    },
    {
      'name': '1 hora de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(hours: 1)),
      'id': 5
    },
    {
      'name': '1 día de antelación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(days: 1)),
      'id': 6
    },
    {
      'name': '2 días de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(days: 2)),
      'id': 7
    },
    {
      'name': '1 semana de anticipación',
      'select': false,
      'time': (DateTime time) => time.subtract(const Duration(days: 7)),
      'id': 8
    },
  ];

  // List<Widget> buildNoteComponentsList() {
  //   List<Widget> noteComponentsList = [];
  //   notesList.value.sort((a, b) {
  //     return b.startTimeMilliseconds!.compareTo(a.startTimeMilliseconds as num);
  //   });
  //   if (searchController.value.text.isNotEmpty) {
  //     notesList.value.forEach((note) {
  //       if (note.title!
  //           .toLowerCase()
  //           .contains(searchController.value.text.toLowerCase()) ||
  //           note.title!
  //               .toLowerCase()
  //               .contains(searchController.value.text.toLowerCase())) {
  //         noteComponentsList.add(TaskCard(
  //           noteData: note,
  //           onTapAction: openNoteToRead,
  //         ));
  //       }
  //     });
  //     return noteComponentsList;
  //   }
  //   if (isFlagOn.value) {
  //     notesList.value.forEach((note) {
  //       if (note.isImportant!) {
  //         noteComponentsList.add(TaskCard(
  //           noteData: note,
  //           onTapAction: openNoteToRead,
  //         ));
  //       }
  //     });
  //   } else {
  //     notesList.value.forEach((note) {
  //       noteComponentsList.add(TaskCard(
  //         noteData: note,
  //         onTapAction: openNoteToRead,
  //       ));
  //     });
  //   }
  //   return noteComponentsList;
  // }
}
