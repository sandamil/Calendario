import 'package:alarm/alarm.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmasController extends GetxController {
  late int id;
  var startTime;
  var title;
  var notes;


  @override
  void onInit() {
    if (Get.arguments != null) {
      startTime = Get.arguments['startTime'];
      title = Get.arguments['title'];
      notes = Get.arguments['notes'];
      id = Get.arguments['id'];
    }

    super.onInit();
    textController.addListener(() {
      subtractTimeString.value = textController.text;
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    alPrincipio(false);
    minutos5(false);
    minutos30(false);
    horas1(false);
    dias1(false);
  }

  RxString alarmaActivada = 'Sin recordatorio'.obs;

  String sinRecordatorio = 'Sin recordatorio';
  RxBool noRemind = false.obs;

  RxBool masOpcionesAlarma = false.obs;

  String alPrincipioString = 'Al Principio';
  RxBool alPrincipio = false.obs;
  String minutos5String = '5 minutos de anticipación';
  RxBool minutos5 = false.obs;
  String minutos30String = '30 minutos de anticipación';
  RxBool minutos30 = false.obs;
  String horas1String = '1 hora de anticipación';
  RxBool horas1 = false.obs;
  String dias1String = '1 día de antelación';
  RxBool dias1 = false.obs;

  late DateTime alarmTime;
  final textController = TextEditingController();
  RxString subtractTimeString = ''.obs;
  // RxInt subtractTime = 0.obs;

  RxString assetAudioPathAddNotas = ConstantData.nokiaAlarm.obs;

  bool showNotifOnRing = true;
  bool showNotifOnKill = true;
  bool isRinging = false;
  bool loopAudio = false;
  bool fadeVolume = false;

  late Duration duracion;

  setAlarmTime([bool enableNotif = true]) async {
    alarmTime = startTime.subtract(duracion);
    final alarmSettings = AlarmSettings(
      id: id,
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
    await Alarm.setNotificationOnAppKillContent(
        title.text, notes.text);
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
        duracion = Duration(minutes: int.parse(subtractTimeString.value));
        break;
      case 'Horas':
        duracion = Duration(hours: int.parse(subtractTimeString.value));
        break;
      case 'Dias':
        duracion = Duration(days: int.parse(subtractTimeString.value));
        break;
      default:
        duracion = Duration(minutes: 0);
        break;
    }
  }
}

