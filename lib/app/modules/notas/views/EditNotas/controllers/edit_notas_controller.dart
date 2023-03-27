import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class EditNotasController extends GetxController {

  bool headerShouldHide = false;

  TextEditingController title = TextEditingController();
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
  void onInit() {
    if (Get.arguments != null) {
      currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    title = new TextEditingController(text: '');
    site = new TextEditingController(text: '');
    notes = new TextEditingController(text: '');

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

  void markImportantAsDirty() {
    isImportant.value = !isImportant.value;
    update();
  }

  void editNote() {
    //Eliminar este recordatorio
    for (int i = 0; i < 10; i++) {
      final int _id = id! * 10 + i;
      // push.cancelNotifications(_id);
    }

    DbProvider.instance.init().then((db) async {


      DbProvider.instance.update(
        Task(
            id: currentNote.value.id,
            title: title.text,
            site: site.text,
            notes: notes.text,
            isImportant: isImportant.value,
            startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
            endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
            time: Jiffy().format('yyyy-MM-dd h:mm:ss a')),
      );

      // Task item = await DbProvider.instance.select( notelist.id!);
      // warnList.forEach((e) {
      //   if (e['select']) {
      //     // push.setOneTime(_item.id * 10 + e['id'], title, notes,
      //     //     e['time'](_startTime));
      //   }
      // });
     Get.offAndToNamed('/notas');
      // Navigator.pushNamed(context, '/hoGet.tome');
      Toast.toast(Get.context!, msg: "Editado! ", showTime: 3000);
    });
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