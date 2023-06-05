
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditNotasController extends GetxController {
  // AlarmasController alarmasController = AlarmasController();

  RxBool important = false.obs;

  Rx<TextEditingController> title = TextEditingController().obs;
  Rx<TextEditingController> site = TextEditingController().obs;
  Rx<TextEditingController> notes = TextEditingController().obs;
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isImportant = false.obs;
  RxString alarmaActivadaString = ''.obs;



  Rx<Task> currentNote = Task().obs;
  late int id;

  // AlarmSettings? alarmaCreadaNota;


  DateTime alarmTime = DateTime.now();
  void setAlarmaTime(DateTime value) {
    alarmTime = value;
    alarmaHora.value = value.formatDateTime24H.toString();
  }
  RxString alarmaHora = ''.obs;

  RxBool alarmaCreada = false.obs;
  // bool get alarmaCreada => _alarmaCreada.value;
  void setAlarmaCreada(bool value) {
    alarmaCreada.value = value;
  }

  @override
  void onInit() async {
    if (Get.arguments != null) {
      // currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    currentNote.value = await NotasDB.instance.select(id);


    title.value.text = currentNote.value.title!;
    site.value.text = currentNote.value.site!;
    notes.value.text = currentNote.value.notes!;
    startTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.startTimeMilliseconds!);
    endTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.endTimeMilliseconds!);
    important.value = currentNote.value.isImportant!;
    alarmaCreada.value = currentNote.value.isAlarmaCreated!;
    alarmaActivadaString.value = currentNote.value.alarmaActivadaString!;
    alarmaHora.value = currentNote.value.alarmaHora!;
    super.onInit();
    // await loadAlarm(id);

  }



  @override
  void onClose() {
    title.value.clear();
    site.value.clear();
    notes.value.clear();
    super.onClose();
  }

  markImportantAsDirty() async {
    important.value = !important.value;
    currentNote.value.isImportant = !currentNote.value.isImportant!;
  }

  editNote() async {
    await NotasDB.instance.update(
      Task(
        id: currentNote.value.id,
        title: title.value.text,
        isImportant: currentNote.value.isImportant,
        site: site.value.text,
        notes: notes.value.text,
        startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
        endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
        idAlarma: id,
        alarmaActivadaString: alarmaActivadaString.value,
        isAlarmaCreated: alarmaCreada.value,
        // time: currentNote.value.time
      ),
    );
  }



  // loadAlarm(id) async {
  //   // alarmaCreadaNota = Alarm.getAlarm(id);
  //   // alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
  //   update();
  // }

}

