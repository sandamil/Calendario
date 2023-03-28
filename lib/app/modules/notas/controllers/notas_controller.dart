import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/taskModel.dart';
import '../views/widgets/taskCard.dart';

class NotasListController extends GetxController {
  CalendarController calendarController = CalendarController();

  bool headerShouldHide = false;
  RxBool isFlagOn = false.obs;
  RxBool isSearchEmpty = true.obs;

  RxList<Task> notesList = <Task>[].obs;

  Rx<TextEditingController> searchController = TextEditingController().obs;

  @override
  void onInit() {
    setNotesFromDB();
    print('notesList.length =========' '${notesList.value.length}');
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

  ///todo update notes sin cargar toda la base de datos
  setNotesFromDB() async {
    notesList.value = await DbProvider.instance.getNotesFromDB();
    update();

    return notesList.value;
  }

  void gotoEditNote() {
    Get.toNamed('/add-notas');
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
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
    notesList.value.sort((a, b) {
      return b.startTimeMilliseconds!.compareTo(a.startTimeMilliseconds as num);
    });
    if (searchController.value.text.isNotEmpty) {
      notesList.value.forEach((note) {
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
      });
      return noteComponentsList;
    }
    if (isFlagOn.value) {
      notesList.value.forEach((note) {
        if (note.isImportant!) {
          noteComponentsList.add(TaskCard(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
        }
      });
    } else {
      notesList.value.forEach((note) {
        noteComponentsList.add(TaskCard(
          noteData: note,
          onTapAction: openNoteToRead,
        ));
      });
    }
    return noteComponentsList;
  }
}
