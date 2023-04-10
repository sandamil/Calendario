import 'package:alarm/alarm.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotasController extends GetxController {
  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;

  bool headerShouldHide = false;

  TextEditingController title = TextEditingController();
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;
  RxBool isImportant = false.obs;

  DateTime time = DateTime.now();

  @override
  void onInit() {
    var dateTimeCalendar = Get.arguments;
    if (dateTimeCalendar != null) {
      startTime.value = dateTimeCalendar;
      endTime.value = dateTimeCalendar;
    }

    super.onInit();
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
    alPrincipio(false);
    item2(false);
    item3(false);
    item4(false);
    item5(false);
  }

  void addTravelEvent() {
    print('addTravelEvent' '$startTime');
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

  RxString alarmaActivada = 'Sin recordatorio'.obs;

  String sinRecordatorio = 'Sin recordatorio';
  RxBool noRemind = false.obs;

  RxBool masOpcionesAlarma = false.obs;

  String alPrincipioString = 'Al Principio';
  RxBool alPrincipio = false.obs;
  int alPrincipioInt = 0;

  RxBool item2 = false.obs;
  RxBool item3 = false.obs;
  RxBool item4 = false.obs;
  RxBool item5 = false.obs;

  late DateTime alarmTime;
  RxInt subtractTime = 0.obs;
  RxString assetAudioPathAddNotas = ConstantData.nokiaAlarm.obs;

  bool showNotifOnRing = true;
  bool showNotifOnKill = true;
  bool isRinging = false;
  bool loopAudio = false;
  bool fadeVolume = false;

  setAlarmTime([bool enableNotif = true]) async {
    alarmTime = startTime.value.subtract(Duration(minutes: subtractTime.value));
    print(alarmTime.millisecondsSinceEpoch ~/ 46755);

    final alarmSettings = AlarmSettings(
      id: alarmTime.millisecondsSinceEpoch ~/ 46755,
      dateTime: alarmTime,
      assetAudioPath: assetAudioPathAddNotas.value,
      loopAudio: loopAudio,
      fadeDuration: fadeVolume ? 5.0 : 0.0,
      notificationTitle:
          showNotifOnRing && enableNotif ? 'Nota: ${title.text}' : null,
      notificationBody:
          showNotifOnRing && enableNotif ? 'Mensaje: ${notes.text}' : null,
      enableNotificationOnKill: showNotifOnKill,
    );

    Alarm.set(alarmSettings: alarmSettings);
    // await Alarm.setNotificationOnAppKillContent(
    //     title.text, notes.text);

    print(alarmTime);
  }

  String? selectedHMD;

  var duracionHMD = <String>['Minutos', 'Horas', 'Dias'];

  void onSelected(String value) {
    selectedHMD = value;
    update();
    print(selectedHMD);
    changeHMD(selectedHMD);
  }

  changeHMD(String? selectedHMD) {
    switch (selectedHMD) {
      case 'Minutos':
        // Get.updateLocale(Locale('en_US'));
        print('Minutos');
        break;
      case 'Horas':
        // Get.updateLocale(Locale('en_US'));
        print('Horas');
        break;
      case 'Dias':
        // Get.updateLocale(Locale('en_US'));
        print('Dias');
        break;
      default:
        // Get.updateLocale(Locale('en_US'));
        print('Fallback to Minutos');
        break;
    }
  }

  // String selectedBus1 = "";
  // switch(newValue) {
  // case "M100010":{
  // selectedBus1 = buisnessLine2_02;
  // break;
  // }
  // case "M100011":{
  // selectedBus1 = buisnessLine2_03;
  // break;
  // }
  // case "M100012":{
  // selectedBus1 = buisnessLine2_04;
  // break;
  // }
  // case "M100013":{
  // selectedBus1 = buisnessLine2_05;
  // break;
  // }
  // default: {
  // selectedBus1 = buisnessLine2_default;
  // }
  // }

  //
  // String remind = warnDefaultt;
  //
  // RxList remindList = [
  //   {
  //     'name': warnDefaultt,
  //     'select': true,
  //     'time': (DateTime time) => time,
  //     'id': 0
  //   },
  //   {
  //     'name': '5 minutos de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(minutes: 5)),
  //     'id': 1
  //   },
  //   {
  //     'name': '10 minutos de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(minutes: 10)),
  //     'id': 2
  //   },
  //   {
  //     'name': '15 minutos de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(minutes: 15)),
  //     'id': 3
  //   },
  //   {
  //     'name': '30 minutos de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(minutes: 30)),
  //     'id': 4
  //   },
  //   {
  //     'name': '1 hora de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(hours: 1)),
  //     'id': 5
  //   },
  //   {
  //     'name': '1 día de antelación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(days: 1)),
  //     'id': 6
  //   },
  //   {
  //     'name': '2 días de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(days: 2)),
  //     'id': 7
  //   },
  //   {
  //     'name': '1 semana de anticipación',
  //     'select': false,
  //     'time': (DateTime time) => time.subtract(Duration(days: 7)),
  //     'id': 8
  //   },
  // ].obs;
  //
  //
  // List selectWarnList = [];
}
