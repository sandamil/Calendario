import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/modules/notas/views/add_notas_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../data/model/taskModel.dart';

class NotasController extends GetxController {
  bool headerShouldHide = false;
  RxBool isFlagOn = false.obs;
  RxBool isSearchEmpty = true.obs;

  List<Task> notesList = [];

  TextEditingController searchController = TextEditingController();

  TextEditingController title = TextEditingController();
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();

  late DateTime startTime;
  late DateTime endTime;
  bool isImportant = false;

  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;
  DateTime time = DateTime.now();

  bool noWarn = false;

  static var warnDefaultt = 'Al principio';

  @override
  void onInit() {
    startTime = DateTime.now();
    endTime = DateTime.now();
    setNotesFromDB();
    print('notesList.length =========' '${notesList.length}');
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

  setNotesFromDB() async {
    notesList = await DbProvider.instance.getNotesFromDB();
    update();

    return notesList;
  }

  void gotoEditNote() {
    Get.to(() => const AddNotasView(),
        duration: const Duration(milliseconds: 100),
        transition: Transition.leftToRight);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => AddTaskPage(widget.time!, widget.events ),
    //     ));
  }

  openNoteToRead(Task noteData) async {
    headerShouldHide = true;

    await Future.delayed(const Duration(milliseconds: 230), () {});
    // Navigator.push(
    //     Get.context,
    //     FadeRoute(
    //         page: TaskView(
    //             id: noteData.id!, triggerRefetch: refetchNotesFromDB, currentNote: noteData
    //         )));
    await Future.delayed(const Duration(milliseconds: 300), () {});

    headerShouldHide = false;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      isSearchEmpty.value = false;
    } else {
      isSearchEmpty.value = true;
    }
  }

  void cancelSearch() {
    searchController.clear();
    isSearchEmpty.value = true;
  }

  /// =========================    AddNtasView

  void addTravelEvent() {
    final int daysNum = endTime.difference(startTime).inDays;
    if (0 == daysNum) {
      final DateTime time =
          DateTime(startTime.year, startTime.month, startTime.day);
      setTravelEvent(
        time,
        title.text,
        site.text,
        startTime,
        endTime,
        isImportant,
      );
    } else {
      for (int i = 0; i <= daysNum; i++) {
        DateTime _time =
            DateTime(startTime.year, startTime.month, startTime.day + i);
        if (0 == i) {
          setTravelEvent(_time, title.text, site.text, startTime,
              DateTime(0, 0, 0, 24), isImportant);
        } else if (i == daysNum) {
          setTravelEvent(time, title.text, site.text, DateTime(0, 0, 0, 0),
              endTime, isImportant);
        } else {
          setTravelEvent(_time, title.text, site.text, DateTime(0, 0, 0, 0),
              DateTime(0, 0, 0, 24), isImportant);
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
      await DbProvider.instance.insert(
        Task(
            title: title.text,
            site: site.text,
            notes: notes.text,
            isImportant: isImportant,
            startTimeMilliseconds: startTime.millisecondsSinceEpoch,
            endTimeMilliseconds: endTime.millisecondsSinceEpoch,
            time: Jiffy().format('yyyy-MM-dd h:mm:ss a')),
      ),
    );
  }

  void markImportantAsDirty() {
    isImportant = !isImportant;
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
}
