import 'package:alarm/alarm.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/edit_alarm.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotasController extends GetxController {
  AlarmasController alarmasController = AlarmasController();

  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;

  bool headerShouldHide = false;

  var _derece = 20.obs;

  int get derece => _derece.value;

  void updateDerece(int value) {
    _derece.value = value;
  }

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

  @override
  void onInit() {
    alarmasController.loadAlarms();
    idGenerated = int.parse(randomIdGenerator());
    print(idGenerated);
    var dateTimeCalendar = Get.arguments;
    if (dateTimeCalendar != null) {
      startTime.value = dateTimeCalendar;
      endTime.value = dateTimeCalendar;
    }

    super.onInit();

    // textController.addListener(() {
    //   subtractTimeString.value = textController.text;
    // });
  }

  @override
  void onReady() {
    print('        ________________________________________onReady');
    super.onReady();
  }

  @override
  void onClose() {
    title.clear();
    site.clear();
    notes.clear();
    super.onClose();
    // alPrincipio(false);
    // minutos5(false);
    // minutos30(false);
    // horas1(false);
    // dias1(false);
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
      print('if (events 1 =========' '${title}');
      events[time]?.add(Task(
        id: idGenerated,
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

  addEvent() async {
    Task _item = await DbProvider.instance.select(
      await DbProvider.instance.insertNotas(
        Task(
          id: idGenerated,
          title: title.text,
          site: site.text,
          notes: notes.text,
          isImportant: isImportant.value,
          startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
          // time: Jiffy().format('yyyy-MM-dd h:mm:ss a')
        ),
      ),
    );
    print('addEvent' '${title.text}');
    print('addEvent' '${idGenerated}');
    // remindList.forEach((e) {
    //   if (e['select']) {
    //     push.setOneTime(_item.id! * 10 + e['id'], title, notes,
    //         e['time'](startTime.value));
    //   }
    // });
  }

  void markImportantAsDirty() {
    isImportant.value = !isImportant.value;
    update();
  }

  ///NOtificaciones
  ///


  String alarmaActivada = 'Sin recordatorio';
  //
  // String sinRecordatorio = 'Sin recordatorio';
  // RxBool noRemind = false.obs;
  //
  // RxBool masOpcionesAlarma = false.obs;
  //
  // String alPrincipioString = 'Al Principio';
  // RxBool alPrincipio = false.obs;
  // String minutos5String = '5 minutos de anticipación';
  // RxBool minutos5 = false.obs;
  // String minutos30String = '30 minutos de anticipación';
  // RxBool minutos30 = false.obs;
  // String horas1String = '1 hora de anticipación';
  // RxBool horas1 = false.obs;
  // String dias1String = '1 día de antelación';
  // RxBool dias1 = false.obs;
  //
  // late DateTime alarmTime;
  // final textController = TextEditingController();
  // RxString subtractTimeString = ''.obs;
  // // RxInt subtractTime = 0.obs;
  //
  // RxString assetAudioPathAddNotas = ConstantData.nokiaAlarm.obs;
  //
  // bool showNotifOnRing = true;
  // bool showNotifOnKill = true;
  // bool isRinging = false;
  // bool loopAudio = false;
  // bool fadeVolume = false;
  //
  // late Duration duracion;
  //
  // setAlarmTime([bool enableNotif = true]) async {
  //   alarmTime = startTime.value.subtract(duracion);
  //   final alarmSettings = AlarmSettings(
  //     id: idGenerated,
  //     dateTime: alarmTime,
  //     assetAudioPath: assetAudioPathAddNotas.value,
  //     loopAudio: loopAudio,
  //     fadeDuration: fadeVolume ? 5.0 : 0.0,
  //     notificationTitle:
  //         showNotifOnRing && enableNotif ? 'Nota: ${title.text}' : null,
  //     notificationBody:
  //         showNotifOnRing && enableNotif ? 'Mensaje: ${notes.text}' : null,
  //     enableNotificationOnKill: showNotifOnKill,
  //   );
  //
  //   Alarm.set(alarmSettings: alarmSettings);
  //   // await Alarm.setNotificationOnAppKillContent(
  //   //     title.text, notes.text);
  // }
  //
  // String? selectedHMD;
  //
  // var duracionHMD = <String>['Minutos', 'Horas', 'Dias'];
  //
  // void onSelected(String value) {
  //   selectedHMD = value;
  //   update();
  //   print(selectedHMD);
  //   changeHMD(selectedHMD);
  // }
  //
  // changeHMD(String? selectedHMD) {
  //   switch (selectedHMD) {
  //     case 'Minutos':
  //       duracion = Duration(minutes: int.parse(subtractTimeString.value));
  //       break;
  //     case 'Horas':
  //       duracion = Duration(hours: int.parse(subtractTimeString.value));
  //       break;
  //     case 'Dias':
  //       duracion = Duration(days: int.parse(subtractTimeString.value));
  //       break;
  //     default:
  //       duracion = Duration(minutes: 0);
  //       break;
  //   }
  // }
}
