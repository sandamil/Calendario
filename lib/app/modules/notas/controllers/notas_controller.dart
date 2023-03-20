import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/modules/notas/views/add_notas_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/taskModel.dart';

class NotasController extends GetxController {

  bool headerShouldHide = false;
  RxBool isFlagOn = false.obs;
  RxBool isSearchEmpty = true.obs;

  List<Task> notesList = [];

  TextEditingController searchController = TextEditingController();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _site = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  late DateTime _startTime;
  late DateTime _endTime;
  bool isImportant = false;




  final count = 0.obs;
  @override
  void onInit() {
    setNotesFromDB();
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

  void increment() => count.value++;

  void gotoEditNote() {
    Get.offAll(const AddNotasView(),
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

    await Future.delayed(Duration(milliseconds: 230), () {});
    // Navigator.push(
    //     Get.context,
    //     FadeRoute(
    //         page: TaskView(
    //             id: noteData.id!, triggerRefetch: refetchNotesFromDB, currentNote: noteData
    //         )));
    await Future.delayed(Duration(milliseconds: 300), () {});

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
    final int daysNum = _endTime.difference(_startTime).inDays;
    if (0 == daysNum) {
      final DateTime _time =
      DateTime(_startTime.year, _startTime.month, _startTime.day);
      setTravelEvent(
        _time,
        _title.text,
        _site.text,
        _startTime,
        _endTime,
        isImportant,
      );
    } else {
      for (int i = 0; i <= daysNum; i++) {
        DateTime _time =
        DateTime(_startTime.year, _startTime.month, _startTime.day + i);
        if (0 == i) {
          setTravelEvent(_time, _title.text, _site.text, _startTime,
              DateTime(0, 0, 0, 24), isImportant);
        } else if (i == daysNum) {
          setTravelEvent(_time, _title.text, _site.text, DateTime(0, 0, 0, 0),
              _endTime, isImportant);
        } else {
          setTravelEvent(_time, _title.text, _site.text, DateTime(0, 0, 0, 0),
              DateTime(0, 0, 0, 24), isImportant);
        }
      }
    }
  }


  void setTravelEvent(DateTime time, String title, String site,
      DateTime startTime, DateTime endTime, bool isImportant) {

    if (events[time] != null) {
      events[time]?.add({
        'title': title,
        'site': site,
        'startTime': startTime,
        'isImportant': isImportant,
        'endTime': endTime
      });
    } else {
      events[time] = [
        {
          'title': title,
          'site': site,
          'startTime': startTime,
          'isImportant': isImportant,
          'endTime': endTime
        }
      ];
    }
  }
}
