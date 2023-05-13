import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/local/previusTaskDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/previousDatabase/previousTaskModel.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/taskModel.dart';
import '../views/widgets/taskCard.dart';

class NotasListController extends GetxController {
  CalendarController calendarController = CalendarController();
  TutorialController tutorialController = TutorialController();

  bool headerShouldHide = false;
  RxBool isFlagOn = false.obs;
  RxBool isSearchEmpty = true.obs;

  RxList<Task> notesList = <Task>[].obs;
  RxList<PreviousTask> notesList2 = <PreviousTask>[].obs;

  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool firstTime = false.obs;


  @override
  void onInit() async {
    // await setNotesFromDB2();

    setNotesFromDB();
    super.onInit();
    if (MySharedPref.getTutoTaskFirst()) {
      firstTime.value = true;
      tutorialController.firstInstall('task');
    }
  }


  @override
  void onClose() {
    searchController.value.clear();
    super.onClose();
  }

  ///Todo update notes sin cargar toda la base de datos
  setNotesFromDB() async {
    notesList.value = await DbProvider.instance.getNotesFromDB();
    update();
    return notesList;
  }



  // ///Todo update notes sin cargar toda la base de datos
  // setNotesFromDB2() async {
  //   notesList2.value = await PreviusDbProvider.instance.getNotesFromDB();
  //   print(notesList2.value.length);
  //
  //   print(notesList2[0].day);
  //
  //   update();
  //
  //   return notesList2;
  // }

  void gotoEditNote() {
    Get.toNamed('/add-notas');
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
  }

  openNoteToRead(Task noteData) async {
    headerShouldHide = true;
    Get.toNamed(
      '/notas-view',
      arguments: {'id': noteData.id!, 'noteData': noteData},
    );
    headerShouldHide = false;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setNotesFromDB();
      isSearchEmpty.value = false;
    } else {
      setNotesFromDB();
      isSearchEmpty.value = true;
    }
  }

  cancelSearch() {
    searchController.value.clear();
    isSearchEmpty.value = true;
    setNotesFromDB();
  }

  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return b.startTimeMilliseconds!.compareTo(a.startTimeMilliseconds as num);
    });
    if (searchController.value.text.isNotEmpty) {
      for (var note in notesList) {
        if (note.title!
                .toLowerCase()
                .contains(searchController.value.text.toLowerCase()) ||
            note.title!
                .toLowerCase()
                .contains(searchController.value.text.toLowerCase())) {
          noteComponentsList.add(TaskCard(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
        }
      }
      return noteComponentsList;
    }
    if (isFlagOn.value) {
      for (var note in notesList) {
        if (note.isImportant!) {
          noteComponentsList.add(TaskCard(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
        }
      }
    } else {
      for (var note in notesList) {
        noteComponentsList.add(TaskCard(
          noteData: note,
          onTapAction: openNoteToRead,
        ));
      }
    }
    return noteComponentsList;
  }



}
