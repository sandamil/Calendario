import 'package:alarm/alarm.dart';
import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotasController extends GetxController {
  TutorialController tutorialController = TutorialController();

  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;

  bool headerShouldHide = false;

/*  var _derece = 20.obs;
  int get derece => _derece.value;
  void setDerece(int value) {
    _derece.value = value;
  }*/

  TextEditingController title = TextEditingController();
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();
  Rx<DateTime> startTime = DateTime.now().obs;
  void setStartTime(value) {
    startTime.value = value;
  }

  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isImportant = false.obs;

  DateTime time = DateTime.now();

  var idGenerated;

  ///ALARMA
  AlarmSettings? alarmaCreadaNota;

  var _alarmaCreada = false.obs;
  bool get alarmaCreada => _alarmaCreada.value;
  void setAlarmaCreada(bool value) {
    _alarmaCreada.value = value;
  }

  RxBool firstTime = false.obs;

  @override
  void onInit() async {
    idGenerated = int.parse(randomIdGenerator());
    var dateTimeCalendar = Get.arguments;
    if (dateTimeCalendar != null) {
      startTime.value = dateTimeCalendar;
      endTime.value = dateTimeCalendar;
    }
    super.onInit();

    if (MySharedPref.getTutoAddTaskFirst()) {
      firstTime.value = true;
      tutorialController.firstInstall('taskAdd');
    }
    // textController.addListener(() {
    //   subtractTimeString.value = textController.text;
    // });

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    title.clear();
    site.clear();
    notes.clear();
    super.onClose();
  }

  void addTravelEvent() {
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
      events[time]?.add(Task(
        id: idGenerated,
        title: title,
        site: site,
        startTimeMilliseconds: startTime.millisecondsSinceEpoch,
        endTimeMilliseconds: endTime.millisecondsSinceEpoch,
        isImportant: isImportant,
      ));
    } else {
      events[time] = [
        Task(
          id: idGenerated,
          title: title,
          site: site,
          startTimeMilliseconds: startTime.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.millisecondsSinceEpoch,
          isImportant: isImportant,
        )
      ];
    }
  }



  saveNota() async {
    print('saveNota');
    print('');
    print('');
    print('');
    print(idGenerated);
    print(title.text);
    print(site.text);
    print(notes.text);
    print(isImportant.value);
    print( startTime.value.millisecondsSinceEpoch);
    print(endTime.value.millisecondsSinceEpoch);
    print( alarmaActivadaString.value);
    print(alarmaCreada);
    print('saveNota');
      await DbProvider.instance.insertNotas(
        Task(
          id: idGenerated,
          title: title.text,
          site: site.text,
          notes: notes.text,
          isImportant: isImportant.value,
          startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
          idAlarma: idGenerated,
          alarmaActivadaString: alarmaActivadaString.value,
          isAlarmaCreated: alarmaCreada,
          // time: Jiffy().format('yyyy-MM-dd h:mm:ss a')
        ),
    );
  }

  void markImportantAsDirty() {
    isImportant.value = !isImportant.value;
    update();
  }

  ///NOtificaciones
  ///

  RxString alarmaActivadaString = 'Sin recordatorio'.obs;





}
