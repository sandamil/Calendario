//
// import 'package:calendario2/app/modules/notas/views/AddNotas/controllers/add_notas_controller.dart';
// import 'package:calendario2/app/modules/notas/views/EditNotas/controllers/edit_notas_controller.dart';
// import 'package:calendario2/config/util/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class AlarmSettingsScreen extends StatefulWidget {
//   // final AlarmSettings? alarmSettings;
//   // final RxBool isEditing;
//
//   const AlarmSettingsScreen(
//       {Key? key, this.alarmSettings,
//         // required this.isEditing
//       })
//       : super(key: key);
//
//   @override
//   State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
// }
//
// class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
//   late bool creating;
//   late bool isEditing;
//
//   late TimeOfDay selectedTime;
//   late bool loopAudio;
//   late bool vibrate;
//   late bool showNotification;
//   late String assetAudio;
//
//   @override
//   void initState() {
//     super.initState();
//     // creating = widget.alarmSettings == null;
//     // isEditing = widget.isEditing.value;
//
//     // if (creating) {
//     //   final dt = DateTime.now().add(const Duration(minutes: 1));
//     //   selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
//     //   loopAudio = true;
//     //   vibrate = true;
//     //   showNotification = true;
//     //   assetAudio = ConstantData.mozartAlarm;
//     // }
//     // else {
//     //   // selºectedTime = TimeOfDay(
//     //     // hour: widget.alarmSettings!.dateTime.hour,
//     //     // minute: widget.alarmSettings!.dateTime.minute,
//     //   );
//     //   // loopAudio = widget.alarmSettings!.loopAudio;
//     //   // vibrate = widget.alarmSettings!.vibrate;
//     //   // showNotification = widget.alarmSettings!.notificationTitle != null &&
//     //   //     widget.alarmSettings!.notificationTitle!.isNotEmpty &&
//     //   //     widget.alarmSettings!.notificationBody != null &&
//     //   //     widget.alarmSettings!.notificationBody!.isNotEmpty;
//     //   // assetAudio = widget.alarmSettings!.assetAudioPath;
//     // }
//   }
//
//   Future<void> pickTime() async {
//     final res = await showTimePicker(
//
//       initialTime: selectedTime,
//       context: context,
//       errorInvalidText: 'Formato no válido',
//       helpText: "SELECCIONA HORA",
//       confirmText: "OK",
//       cancelText: "CANCELAR",
//       hourLabelText: 'Horas',
//       minuteLabelText: 'Minutos'
//     );
//     if (res != null) setState(() => selectedTime = res);
//   }
//
//   // AlarmSettings buildAlarmSettings() {
//   //   final now = DateTime.now();
//   //   final id = creating
//   //       ? DateTime.now().millisecondsSinceEpoch % 100000
//   //       : widget.alarmSettings!.id;
//   //
//   //   DateTime dateTime = DateTime(
//   //     now.year,
//   //     now.month,
//   //     now.day,
//   //     selectedTime.hour,
//   //     selectedTime.minute,
//   //     0,
//   //     0,
//   //   );
//   //   if (dateTime.isBefore(DateTime.now())) {
//   //     dateTime = dateTime.add(const Duration(days: 1));
//   //   }
//   //
//   //   final alarmSettings = AlarmSettings(
//   //     id: id,
//   //     dateTime: dateTime,
//   //     loopAudio: loopAudio,
//   //     vibrate: vibrate,
//   //     notificationTitle: showNotification ? 'Alarma' : null,
//   //     notificationBody:
//   //         showNotification ? 'Tu alarma ($id) esta sonando' : null,
//   //     assetAudioPath: assetAudio,
//   //   );
//   //   return alarmSettings;
//   // }
//   //
//   // void saveAlarm() {
//   //   Alarm.set(alarmSettings: buildAlarmSettings())
//   //       .then((_) => Navigator.pop(context, true));
//   // }
//   //
//   // Future<void> deleteAlarm() async {
//   //   Alarm.stop(widget.alarmSettings!.id).then((_) {
//   //     updateNotaAddOrEdit();
//   //     Navigator.pop(context, true);
//   //   });
//   // }
//
//   updateNotaAddOrEdit() {
//     isEditing ? updateNotaAdd() : updateNotaEdit();
//   }
//
//   updateNotaAdd() {
//     var addNotasController = Get.put(AddNotasController());
//     // addNotasController.alarmaCreadaNota = null;
//     addNotasController.update();
//   }
//
//   updateNotaEdit() {
//     var editNotasController = Get.put(EditNotasController());
//     editNotasController.alarmaCreadaNota = null;
//     editNotasController.update();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text(
//                   "Cancelar",
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge!
//                       .copyWith(color: Colors.blueAccent),
//                 ),
//               ),
//               TextButton(
//                 // onPressed: saveAlarm,
//                 child: Text(
//                   "Guardar",
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge!
//                       .copyWith(color: Colors.blueAccent),
//                 ),
//               ),
//             ],
//           ),
//           // RawMaterialButton(
//           //   onPressed: pickTime,
//           //   fillColor: Colors.grey[200],
//           //   child: Container(
//           //     margin: const EdgeInsets.all(20),
//           //     child: Text(
//           //       selectedTime.format(context),
//           //       style: Theme.of(context)
//           //           .textTheme
//           //           .displayMedium!
//           //           .copyWith(color: Colors.blueAccent),
//           //     ),
//           //   ),
//           // ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Loop alarma audio',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: loopAudio,
//                 onChanged: (value) => setState(() => loopAudio = value),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Vibración',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: vibrate,
//                 onChanged: (value) => setState(() => vibrate = value),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Mostrar notificación',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: showNotification,
//                 onChanged: (value) => setState(() => showNotification = value),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Sonido',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               DropdownButton(
//                 value: assetAudio,
//                 items: const [
//                   DropdownMenuItem<String>(
//                     value: ConstantData.mozartAlarm,
//                     child: Text('Mozart'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: ConstantData.nokiaAlarm,
//                     child: Text('Nokia'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: ConstantData.onepieceAlarm,
//                     child: Text('One Piece'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: ConstantData.starwarsAlarm,
//                     child: Text('Star Wars'),
//                   ),
//                 ],
//                 onChanged: (value) => setState(() => assetAudio = value!),
//               ),
//             ],
//           ),
//           if (!creating)
//             TextButton(
//               onPressed: deleteAlarm,
//               child: Text(
//                 'Borar Alarma',
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium!
//                     .copyWith(color: Colors.red)
//                     .copyWith(fontWeight: FontWeight.bold),
//               ),
//             ),
//           const SizedBox(),
//         ],
//       ),
//     );
//   }
// }
