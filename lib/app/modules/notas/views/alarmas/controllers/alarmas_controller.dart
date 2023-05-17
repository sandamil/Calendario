import 'package:alarm/alarm.dart';
import 'package:calendario2/app/components/custom_snackbar.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/controllers/add_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/views/add_notas_view.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/controllers/edit_notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/EditNotas/views/edit_notas_view.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/edit_alarm.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmasController extends GetxController {
  final addNotasController = Get.put(AddNotasController());


  RxList<AlarmSettings> alarms = <AlarmSettings>[].obs;

  late int id;
  var startTime;
  String? title;
  String? notes;

  AlarmSettings? alarmaCreada;

  // Rx<Task> currentNote = Task().obs;

  RxBool isEditing = false.obs;


  @override
  void onInit() {
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
        title = Get.arguments['title'];
        notes = Get.arguments['notes'];
        id = Get.arguments['id'];

      } else {
        startTime = Get.arguments['startTime'];
        title = Get.arguments['title'];
        notes = Get.arguments['notes'];
        id = Get.arguments['id'];
      }
      // startTime = Get.arguments['startTime'];
      // title = Get.arguments['title'];
      // notes = Get.arguments['notes'];
      // id = Get.arguments['id'];
    }

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

  Future<void> navigateToAlarmScreen(AlarmSettings? settings, context) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            child: ExampleAlarmEditScreen(alarmSettings: settings, isEditing: isEditing),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  loadAlarms() async {
    alarms.value = Alarm.getAlarms();
    // alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    // searchIdAlarma();
    update();
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

  RxString assetAudioPathAddNotas = ConstantData.nokiaAlarm.obs;

  bool showNotifOnRing = true;
  bool showNotifOnKill = true;
  bool isRinging = false;
  bool loopAudio = false;
  bool fadeVolume = false;

  Duration duracion = const Duration(microseconds: 2);

  setAlarmTime([bool enableNotif = true]) async {
    alarmTime = startTime.subtract(duracion);
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: alarmTime,
      assetAudioPath: assetAudioPathAddNotas.value,
      loopAudio: loopAudio,
      fadeDuration: fadeVolume ? 5.0 : 0.0,
      notificationTitle:
          showNotifOnRing && enableNotif ? 'Nota: $title' : null,
      notificationBody:
          showNotifOnRing && enableNotif ? 'Mensaje: $notes' : null,
      enableNotificationOnKill: showNotifOnKill,
    );

    Alarm.set(alarmSettings: alarmSettings);
    await Alarm.setNotificationOnAppKillContent(title ?? '', notes ?? '');
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
        ? await setAlarmTime()
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
    noRemind.value
        ? await setAlarmTime()
        : CustomSnackBar.showCustomSnackBar(
            title: 'No has añadido Alarma',
            message: ' Vuelve a entrar si queires añadir recordatorio');
    await loadAlarmCreada();
    await updatealarmaActivadaString();
    addNotasController.setAlarmaCreada(noRemind.value);
    await Get.to(() => AddNotasView());
  }

  loadAlarmCreada() {
      AddNotasController adNotasController = Get.find();
      AlarmSettings? alarm = Alarm.getAlarm(id);
      adNotasController.alarmaCreadaNota = alarm;
  }

  loadAlarmCreadaEdit() {
    EditNotasController editNotasController = Get.find();
    AlarmSettings? alarm = Alarm.getAlarm(id);
    editNotasController.alarmaCreadaNota = alarm;
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
