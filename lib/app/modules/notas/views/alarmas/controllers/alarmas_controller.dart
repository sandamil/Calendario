
import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/components/custom_snackbar.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/controllers/add_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/views/add_notas_view.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/controllers/edit_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/views/edit_notas_view.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/edit_alarm.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class AlarmasController extends GetxController {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();



  // RxList<AlarmSettings> alarms = <AlarmSettings>[].obs;

  late int id;
  var startTime;
  String? title;
  String? notes;

  // AlarmSettings? alarmaCreada;

  // Rx<Task> currentNote = Task().obs;

  RxBool isEditing = false.obs;

  RxList<ActiveNotification> pastNotifications = <ActiveNotification>[].obs;
  RxList<PendingNotificationRequest> pendingNotifications = <PendingNotificationRequest>[].obs;

  @override
   onInit()  async {

    if (Get.arguments != null) {
      if (Get.arguments['isEditing'] == true) {
        // currentNote.value = Get.arguments['currentNote'];
        isEditing.value = true;
        // startTime = DateTime.fromMillisecondsSinceEpoch(
        //     currentNote.value.startTimeMilliseconds!);
        // title = currentNote.value.title;
        // notes = currentNote.value.notes;
        // id = currentNote.value.id!;
        startTime = Get.arguments['startTime'];
        alarmTime = DateTime(2000);
        title = Get.arguments['title'];
        notes = Get.arguments['notes'];
        id = Get.arguments['id'];

      } else {
        startTime = Get.arguments['startTime'];
        alarmTime = DateTime(2000);
        title = Get.arguments['title'];
        notes = Get.arguments['notes'];
        id = Get.arguments['id'];
      }
      // startTime = Get.arguments['startTime'];
      // title = Get.arguments['title'];
      // notes = Get.arguments['notes'];
      // id = Get.arguments['id'];
    }

    tz.initializeTimeZones();
    // final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZone));

    super.onInit();
    textController.addListener(() {
      subtractTimeString.value = textController.text;
    });
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

  getPastNotification() async {
    pastNotifications.value =
        await flutterLocalNotificationsPlugin.getActiveNotifications();

    print(pastNotifications.value.length);

  }
  getPendingNotification() async {
    pendingNotifications.value =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    print(pendingNotifications.value.length);

  }



  RxString alarmaActivada = 'Sin recordatorio'.obs;

  updatealarmaActivadaString() {
    if (isEditing.value) {
      EditNotasController editNotasController = Get.find();
      editNotasController.alarmaActivadaString.value = alarmaActivada.value;

    } else {
      AddNotasController adNotasController = Get.find();
      adNotasController.alarmaActivadaString.value = alarmaActivada.value;
    }
     }

  String sinRecordatorio = 'Sin recordatorio';
  RxBool noRemind = false.obs;

  RxBool masOpcionesAlarma = false.obs;
  String masOpcionesAlarmaString = 'Personalizado';

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


  Duration duracion = const Duration(microseconds: 2);


  setNotification([bool enableNotif = true]) async {
    print('setNotification');
    alarmTime = startTime.subtract(duracion);

    print('alarmTime  ${alarmTime}');

    if (alarmTime.isBefore(DateTime.now())) {
      alarmaActivada.value = sinRecordatorio;
      print('alarmaActivada.value  ${alarmaActivada.value}');

      return;
    }
    var tzdatetime = tz.TZDateTime.from(alarmTime, tz.local);
    print('tzdatetime  ${tzdatetime}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Nota: $title',
        'Mensaje: $notes',
        tzdatetime,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);

    print('fin ==================');

  }

  String? selectedHMD;

  var duracionHMD = <String>['Minutos', 'Horas', 'Dias'];

  void onSelected(String value) {
    selectedHMD = value;
    update();
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
        duracion = const Duration(minutes: 0);
        break;
    }
  }

  goToEditingNotas() async {
    final editNotasController = Get.find<EditNotasController>();
    noRemind.value
        ? await setNotification()
        : CustomSnackBar.showCustomSnackBar(
            title: 'No has añadido Alarma',
            message: ' Vuelve a entrar si queires añadir recordatorio');
    // await loadAlarmCreada();
    await updatealarmaActivadaString();
    await loadAlarmCreadaEdit();

    editNotasController.setAlarmaCreada(noRemind.value);
    await Get.to(() => EditNotasView());
  }

  goToAddNotas() async {
    final addNotasController = Get.put(AddNotasController());

    noRemind.value
        ? await setNotification()
        : CustomSnackBar.showCustomSnackBar(
            title: 'No has añadido Alarma',
            message: ' Vuelve a entrar si queires añadir recordatorio');
    await loadAlarmCreada();
    await updatealarmaActivadaString();
    addNotasController.setAlarmaCreada(noRemind.value);
    print('goToAddNotas ========= noRemind.value  ${noRemind.value}');

    addNotasController.setAlarmaTime(alarmTime);
    await Get.to(() => AddNotasView());
  }

  loadAlarmCreada() {
      AddNotasController adNotasController = Get.find();
      // AlarmSettings? alarm = Alarm.getAlarm(id);
      // adNotasController.alarmaCreadaNota = alarm;
  }

  loadAlarmCreadaEdit() {
    EditNotasController editNotasController = Get.find();
    // AlarmSettings? alarm = Alarm.getAlarm(id);
    // editNotasController.alarmaCreadaNota = alarm;
  }

  Future<void> noti() async {

    print('=============== prueba ==================');
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
    print('=============== prueba ==================');

  }

// searchIdAlarma() {
//   AddNotasController adNotasController = Get.find();
//   for (var alarm in alarms.value) {
//     if (alarm.id == adNotasController.idGenerated) {
//       adNotasController.alarmaCreadaNota = alarm;
//     }
//   }
// }
}
