import 'package:calendario2/app/components/custom_snackbar.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/controllers/add_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/views/add_notas_view.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/controllers/edit_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/views/edit_notas_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmasController extends GetxController {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Rx<Task> currentNote = Task().obs;

  // RxList<AlarmSettings> alarms = <AlarmSettings>[].obs;

  late int id;
  var startTime;
  String? title;
  String? notes;

  // AlarmSettings? alarmaCreada;

  // Rx<Task> currentNote = Task().obs;

  RxBool isEditing = false.obs;

  RxList<ActiveNotification> pastNotifications = <ActiveNotification>[].obs;
  RxList<PendingNotificationRequest> pendingNotifications =
      <PendingNotificationRequest>[].obs;

  @override
  onInit() async {
    print('        ${Get.arguments['isEditing']}');
    print('        ${Get.arguments['currentNota']}');

    if (Get.arguments != null) {
      if (Get.arguments['isEditing'] == true) {
        final editNotasController = Get.find<EditNotasController>();

        // currentNote.value = Get.arguments['currentNote'];
        isEditing.value = true;
        // startTime = DateTime.fromMillisecondsSinceEpoch(
        //     currentNote.value.startTimeMilliseconds!);
        // title = currentNote.value.title;
        // notes = currentNote.value.notes;
        // id = currentNote.value.id!;

        currentNote.value = editNotasController.currentNote.value;

        id = currentNote.value.id!;
        title = currentNote.value.title;
        notes = currentNote.value.notes;
        startTime = DateTime.fromMillisecondsSinceEpoch(
            currentNote.value.startTimeMilliseconds!);

        // Recuperar la configuración guardada sin modificar notificaciones.
        alarmTime = currentNote.value.alarmaTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(
                currentNote.value.alarmaTimestamp!)
            : startTime;

        noRemind.value = currentNote.value.isAlarmaCreated ?? false;
        alarmaActivada.value =
            currentNote.value.alarmaActivadaString ?? sinRecordatorio;

        // Restaurar la duración y la selección al editar una alarma existente.
        if (noRemind.value) {
          duracion = startTime.difference(alarmTime);

          alPrincipio.value = false;
          minutos5.value = false;
          minutos30.value = false;
          horas1.value = false;
          dias1.value = false;

          masOpcionesAlarma.value = false;
          selectedHMD = null;

          if (duracion == const Duration(minutes: 0)) {
            alPrincipio.value = true;
          } else if (duracion == const Duration(minutes: 5)) {
            minutos5.value = true;
          } else if (duracion == const Duration(minutes: 30)) {
            minutos30.value = true;
          } else if (duracion == const Duration(hours: 1)) {
            horas1.value = true;
          } else if (duracion == const Duration(days: 1)) {
            dias1.value = true;
          } else {
            // Duración personalizada: restaurar unidad y cantidad.
            masOpcionesAlarma.value = true;

            int cantidad;
            if (duracion.inDays > 0 &&
                duracion.inHours == duracion.inDays * 24 &&
                duracion.inMinutes == duracion.inDays * 1440) {
              selectedHMD = 'Dias';
              cantidad = duracion.inDays;
            } else if (duracion.inHours > 0 &&
                duracion.inMinutes == duracion.inHours * 60) {
              selectedHMD = 'Horas';
              cantidad = duracion.inHours;
            } else {
              selectedHMD = 'Minutos';
              cantidad = duracion.inMinutes;
            }

            textController.text = cantidad.toString();
            subtractTimeString.value = cantidad.toString();
          }

          update();
        }

        if (noRemind.value && alarmTime.isBefore(DateTime.now())) {
          alarmaActivada.value = sinRecordatorio;
        }
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
    print(duracion);
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
      id: id,
      title: 'Nota: $title',
      body: 'Mensaje: $notes',
      scheduledDate: tzdatetime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

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

    if (!noRemind.value) {
      CustomSnackBar.showCustomSnackBar(
        title: 'No has añadido Alarma',
        message: 'Vuelve a entrar si quieres añadir recordatorio',
      );
    }

    await updatealarmaActivadaString();

    editNotasController.setAlarmaCreada(noRemind.value);
    if (noRemind.value) {
      if (duracion != const Duration(microseconds: 2)) {
        alarmTime = startTime.subtract(duracion);
      }
      editNotasController.setAlarmaTime(alarmTime);
    }

    await Get.to(() => EditNotasView());
  }

    goToAddNotas() async {
    final addNotasController = Get.put(AddNotasController());

    if (!noRemind.value) {
      CustomSnackBar.showCustomSnackBar(
        title: 'No has añadido Alarma',
        message: 'Vuelve a entrar si quieres añadir recordatorio',
      );
    }

    await updatealarmaActivadaString();

    addNotasController.setAlarmaCreada(noRemind.value);
    if (noRemind.value) {
      if (duracion != const Duration(microseconds: 2)) {
        alarmTime = startTime.subtract(duracion);
      }
      addNotasController.setAlarmaTime(alarmTime);
    }

    await Get.to(() => AddNotasView());
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
