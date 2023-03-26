// import 'dart:ui';
//
// import 'package:calendario2/app/components/toast.dart';
// import 'package:calendario2/app/data/local/taskDatabase.dart';
// import 'package:calendario2/app/data/model/taskModel.dart';
// import 'package:flutter/cupertino.dart';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
//
//
//
//
//
// class TaskView extends StatefulWidget {
//   int id;
//
//   late Function() triggerRefetch;
//   late Task currentNote;
//
//   TaskView({
//     Key? key,
//     Function()? triggerRefetch,
//     Task? currentNote,
//     required this.id,
//   }) : super(key: key) {
//     this.triggerRefetch = triggerRefetch!;
//     this.currentNote = currentNote!;
//   }
//
//   @override
//   _TaskViewState createState() => _TaskViewState();
// }
//
// class _TaskViewState extends State<TaskView> {
//   List _warnList = [
//     {
//       'name': 'Al Principio',
//       'select': false,
//       'time': (DateTime time) => time,
//       'id': 0
//     },
//     {
//       'name': '5 minutos de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(minutes: 5)),
//       'id': 1
//     },
//     {
//       'name': '10 minutos de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(minutes: 10)),
//       'id': 2
//     },
//     {
//       'name': '15 minutos de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(minutes: 15)),
//       'id': 3
//     },
//     {
//       'name': '30 minutos de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(minutes: 30)),
//       'id': 4
//     },
//     {
//       'name': '1 hora de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(hours: 1)),
//       'id': 5
//     },
//     {
//       'name': '1 día de antelación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(days: 1)),
//       'id': 6
//     },
//     {
//       'name': '2 días de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(days: 2)),
//       'id': 7
//     },
//     {
//       'name': '1 semana de anticipación',
//       'select': false,
//       'time': (DateTime time) => time.subtract(const Duration(days: 7)),
//       'id': 8
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     showHeader();
//     setNotesFromDB();
//   }
//
//   setNotesFromDB() async {
//     widget.currentNote = await DbProvider.instance.select(widget.id);
//     setState(() {});
//
//   }
//
//   void showHeader() async {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       setState(() {
//         headerShouldShow = true;
//       });
//     });
//   }
//
//   bool headerShouldShow = false;
//
//   @override
//
//   void handleSave() async {
//
//     DbProvider.instance.update(
//       Task(
//           id: widget.currentNote.id,
//           title: widget.currentNote.title,
//           isImportant: widget.currentNote.isImportant,
//           site: widget.currentNote.site,
//           notes: widget.currentNote.notes,
//           startTimeMilliseconds: widget.currentNote.startTimeMilliseconds,
//           endTimeMilliseconds: widget.currentNote.endTimeMilliseconds,
//           time: widget.currentNote.time),
//     );
//
//     Toast.toast(context, msg: "Editado! ", showTime: 3000);
//     DbProvider.instance.close();
//
//   }
//
//   void markImportantAsDirty() {
//     setState(() {
//       widget.currentNote.isImportant = !widget.currentNote.isImportant!;
//     });
//     handleSave();
//   }
//
//   void handleEdit() {
//     Navigator.pop(context);
//     // Navigator.push(
//     //     context,
//     //     CupertinoPageRoute(
//     //         builder: (context) => EditTaskPage(widget.currentNote, _warnList)));
//   }
// ///todo share
//   void handleShare() {
//   //   Share.share(
//   //       '${widget.currentNote.title!.trim()}\n(On: ${widget.currentNote.startTimeMilliseconds.toString().substring(0, 10)})\n\n${widget.currentNote.title}');
//    }
//
//   void handleBack() {
//     Navigator.pop(context);
//   }
//
//   void handleDelete() async {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             title: const Text('Borrar nota'),
//             content: const Text('Se borrará permanentemente'),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('BORRAR',
//                     style: TextStyle(
//                         color: Colors.red.shade300,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 1)),
//                 onPressed: () {
//                   Navigator.of(context).pop(true); //关闭对话框
//           // DbProvider.instance.delete( widget.currentNote.id);
//
//                     //删除本次提醒
//                     // for (int i = 0; i < 10; i++) {
//                     //   push.cancelNotifications(widget.currentNote.id * 10 + i);
//                     // }
//
//                     Navigator.pushReplacementNamed(context, '/home');
//                     Toast.toast(context, msg: "Eliminado exitosamente!");
//           DbProvider.instance.close();
//
//                 },
//               ),
//               TextButton(
//                 child: Text('CANCELAR',
//                     style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 1)),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               )
//             ],
//           );
//
//
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }
