import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class EditNotasController extends GetxController {

  bool headerShouldHide = false;
  RxBool important = false.obs;

  Rx<TextEditingController> title = TextEditingController().obs;
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isImportant = false.obs;


  bool noWarn = false;
  static var warnDefaultt = 'Al principio';
  RxString warn = warnDefaultt.obs;


  Rx<Task> currentNote = Task().obs;
  late int id;

  @override
  void onInit() async {
    if (Get.arguments != null) {
      currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    print(currentNote.value.title);
    title.value.text =  currentNote.value.title!;
    site.text =  currentNote.value.site!;
    notes.text =  currentNote.value.notes!;
    startTime.value = DateTime.fromMillisecondsSinceEpoch(currentNote.value.startTimeMilliseconds!);
    endTime.value = DateTime.fromMillisecondsSinceEpoch(currentNote.value.endTimeMilliseconds!);
    important.value = currentNote.value.isImportant!;
    super.onInit();
  }

  @override
  void onReady() {
    print(currentNote.value.title);

    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  markImportantAsDirty() async {
    print(currentNote.value.isImportant);
    important.value = !important.value!;
    currentNote.value.isImportant = !currentNote.value.isImportant!;
    print(currentNote.value.isImportant);
  }

   editNote() async {
    await DbProvider.instance.update(
      Task(
          id: currentNote.value.id,
          title: currentNote.value.title,
          isImportant: currentNote.value.isImportant,
          site: currentNote.value.site,
          notes: currentNote.value.notes,
          startTimeMilliseconds: currentNote.value.startTimeMilliseconds,
          endTimeMilliseconds: currentNote.value.endTimeMilliseconds,
          time: currentNote.value.time),
    );
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