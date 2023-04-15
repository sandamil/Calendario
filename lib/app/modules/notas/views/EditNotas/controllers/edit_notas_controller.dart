import 'package:alarm/alarm.dart';
import 'package:alarm/service/storage.dart';
import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditNotasController extends GetxController {
  AlarmasController alarmasController = AlarmasController();

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

  AlarmSettings? alarmaCreadaNota;

  var _alarmaCreada = false.obs;
  bool get alarmaCreada => _alarmaCreada.value;
  void setAlarmaCreada(bool value) {
    _alarmaCreada.value = value;
  }

  @override
  void onInit() async {
    if (Get.arguments != null) {
      currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }

    title.value.text = currentNote.value.title!;
    site.value.text = currentNote.value.site!;
    notes.value.text = currentNote.value.notes!;
    startTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.startTimeMilliseconds!);
    endTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.endTimeMilliseconds!);
    important.value = currentNote.value.isImportant!;
    alarmaActivadaString.value = currentNote.value.alarmaActivadaString!;

    super.onInit();
    await loadAlarm(id);

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    title.value.clear();
    site.value.clear();
    notes.value.clear();
    super.onClose();
  }

  markImportantAsDirty() async {
    print(currentNote.value.isImportant);
    important.value = !important.value;
    currentNote.value.isImportant = !currentNote.value.isImportant!;
    print(currentNote.value.isImportant);
  }

  editNote() async {
    await DbProvider.instance.update(
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
        isAlarmaCreated: alarmaCreada,
        // time: currentNote.value.time
      ),
    );
  }



  loadAlarm(id) async {
    alarmaCreadaNota = Alarm.getAlarm(id);
    // alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    update();
  }

}

