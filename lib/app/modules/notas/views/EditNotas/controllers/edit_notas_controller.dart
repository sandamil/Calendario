
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
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

  var _alarmaCreada = false.obs;

  DateTime alarmTime = DateTime.now();
  void setAlarmaTime(DateTime value) {
    alarmTime = value;
    alarmaHora = value.formatDateTime24H.toString();
  }
  late String alarmaHora;


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
    print( 'onInit()');
    print( 'onInit()');
    print( 'onInit()');
    print( currentNote.value.alarmaHora);
    print( 'onInit()');
    print( 'onInit()');
    print( 'onInit()');

    title.value.text = currentNote.value.title!;
    site.value.text = currentNote.value.site!;
    notes.value.text = currentNote.value.notes!;
    startTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.startTimeMilliseconds!);
    endTime.value = DateTime.fromMillisecondsSinceEpoch(
        currentNote.value.endTimeMilliseconds!);
    important.value = currentNote.value.isImportant!;
    alarmaActivadaString.value = currentNote.value.alarmaActivadaString!;
    alarmaHora = currentNote.value.alarmaHora!;
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
        isAlarmaCreated: alarmaCreada,
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

