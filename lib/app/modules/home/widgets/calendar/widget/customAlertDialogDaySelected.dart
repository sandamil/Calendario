
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';

//
// class DialogLongPress extends StatelessWidget {
//   CalendarController calendarController = CalendarController();
//
//   DialogLongPress(
//     BuildContext context,{
//     super.key,
//     required this.task,
//     required this.turno,
//     required this.selectedDate,
//     required this.deleteTurnoCuadrante,
//     required this.getCuadrante,  required this.currentX, required this.currentY,
//   });
//
//   final List<CuadranteDay> turno;
//    final List<Task> task;
//   final DateTime selectedDate;
//   final int currentX;
//   final int currentY;
//   final HomeCallback deleteTurnoCuadrante;
//   final HomeCallback2 getCuadrante;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: Get.height,
//       width: Get.width - 20.w,
//       child: Stack(
//         children: [
//           Positioned(
//             // left: x,
//             top: currentY - 40.h,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10.w),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                     height: 30,
//                     width: Get.width - 20.w,
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           left: currentX - 20.w,
//                           child: CustomPaint(
//                               size: const Size(35, 35),
//                               painter: DrawTriangle()),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 220,
//                     width: Get.width - 20.w,
//                     padding: EdgeInsets.symmetric(horizontal: 10.w),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: PRIMARY_COLOR),
//                       color: MyColors.backgroundColor,
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(5.r),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(height: 2.h),
//                         Container(
//                           color: MyColors.backgroundColor,
//                           height: 150,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 turno.isEmpty
//                                     ? Container()
//                                     : ListView.builder(
//                                         shrinkWrap: true,
//                                         itemCount: calendarController
//                                             .selectedDayTurnos.length,
//                                         itemBuilder: (context, index) {
//                                           return Slidable(
//                                             endActionPane: ActionPane(
//                                               motion: const DrawerMotion(),
//                                               extentRatio: 0.3,
//                                               children: [
//                                                 SlidableAction(
//                                                   label: 'Eliminar',
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(5.r)),
//                                                   backgroundColor:
//                                                       Colors.redAccent,
//                                                   // icon: Icons.send,
//                                                   onPressed: (context) {
//                                                     deleteTurnoCuadrante(
//                                                         calendarController
//                                                             .selectedDayTurnos[
//                                                                 index]
//                                                             .id!,
//                                                         selectedDate);
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Container(
//                                               height: 22.h,
//                                               padding: EdgeInsets.symmetric(
//                                                   vertical: 1.h,
//                                                   horizontal: 2.w),
//                                               decoration: BoxDecoration(
//                                                 color: HexColor(
//                                                     calendarController
//                                                         .selectedDayTurnos[
//                                                             index]
//                                                         .color!),
//                                                 border:
//                                                     Border.all(width: 0.8.r),
//                                                 borderRadius:
//                                                     BorderRadius.circular(5.r),
//                                               ),
//                                               margin: EdgeInsets.symmetric(
//                                                   horizontal: 2.w,
//                                                   vertical: 2.h),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   // FittedBox(
//                                                   //   child: Text(
//                                                   //     '${calendarController.selectedEvents.value[index].dateTime.toString().substring(8, 10)}-${calendarController.selectedEvents.value[index].dateTime.toString().substring(5, 7)}-${calendarController.selectedEvents.value[index].dateTime.toString().substring(0, 4)}',
//                                                   //     style: TextStyle(
//                                                   //         fontSize: 14.sp,
//                                                   //         color: HexColor(calendarController.selectedEvents
//                                                   //                         .value[index].color!)
//                                                   //                     .computeLuminance() >
//                                                   //                 0.5
//                                                   //             ? Colors.black
//                                                   //             : Colors.white),
//                                                   //   ),
//                                                   // ),
//                                                   // SizedBox(
//                                                   //   width: 20.w,
//                                                   // ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 6.0),
//                                                     child: FittedBox(
//                                                       child: Text(
//                                                         calendarController
//                                                             .selectedDayTurnos[
//                                                                 index]
//                                                             .description!,
//                                                         style: TextStyle(
//                                                             height: 1.2.h,
//                                                             fontSize: 14.sp,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: HexColor(calendarController
//                                                                             .selectedDayTurnos[index]
//                                                                             .color!)
//                                                                         .computeLuminance() >
//                                                                     0.5
//                                                                 ? Colors.black
//                                                                 : Colors.white),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   // SizedBox(
//                                                   //   width: 20.w,
//                                                   // ),
//                                                   calendarController
//                                                                   .selectedDayTurnos[
//                                                                       index]
//                                                                   .startHour !=
//                                                               null &&
//                                                           calendarController
//                                                                   .selectedDayTurnos[
//                                                                       index]
//                                                                   .endHour !=
//                                                               null
//                                                       ? Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   left: 15.w),
//                                                           child: FittedBox(
//                                                             child: Text(
//                                                               'de ${calendarController.selectedDayTurnos[index].startHour.toString()} a ${calendarController.selectedDayTurnos[index].endHour.toString()}',
//                                                               style: TextStyle(
//                                                                   height: 1.2.h,
//                                                                   fontSize:
//                                                                       14.sp,
//                                                                   color: HexColor(calendarController.selectedDayTurnos[index].color!)
//                                                                               .computeLuminance() >
//                                                                           0.5
//                                                                       ? Colors
//                                                                           .black
//                                                                       : Colors
//                                                                           .white),
//                                                             ),
//                                                           ),
//                                                         )
//                                                       : Container(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   right: 20.w),
//                                                         ),
//                                                   Spacer(),
//                                                   Icon(
//                                                     Icons.arrow_back,
//                                                     size: 16,
//                                                     color: MyColors.textColor,
//                                                   ),
//                                                   Icon(
//                                                     Icons.delete_forever,
//                                                     size: 18,
//                                                     color: MyColors.textColor,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                 SizedBox(
//                                   height: 3.h,
//                                 ),
//                                 ...calendarController.selectedDayNotas
//                                     .map((nota) => Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               vertical: 1.h, horizontal: 2.w),
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               MyCustomDialog.mostrarTask(
//                                                   nota, context);
//                                             },
//                                             child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 4.w),
//                                                 decoration: BoxDecoration(
//                                                   color: MyColors
//                                                       .cellSelectedColor,
//                                                   border: Border.all(
//                                                       color: MyColors
//                                                           .borderAccentLine,
//                                                       width: 1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           3.r),
//                                                 ),
//                                                 height: 22.h,
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   children: [
//                                                     SizedBox(
//                                                       width: 4.w,
//                                                     ),
//                                                     SizedBox(
//                                                       width: 40.w,
//                                                       child: Text(
//                                                         DateTime.fromMillisecondsSinceEpoch(
//                                                                 nota.startTimeMilliseconds!)
//                                                             .formatDateTime24H,
//                                                         style: TextStyle(
//                                                             height: 1.2.h,
//                                                             fontSize: 14.sp,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w600),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 4.w,
//                                                     ),
//                                                     SizedBox(
//                                                       width: 90.w,
//                                                       child: Text(
//                                                         nota.title!
//                                                             .toUpperCase(),
//                                                         style: TextStyle(
//                                                             height: 1.2.h,
//                                                             fontSize: 14.sp,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w600),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 4.w,
//                                                     ),
//                                                     SizedBox(
//                                                       width: 170.w,
//                                                       child: Text(
//                                                         nota.notes!,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style: TextStyle(
//                                                             height: 1.2.h,
//                                                             fontSize: 14.sp,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w600),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 )),
//                                           ),
//                                         )),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 2.h),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.all(2.h),
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     await calendarController.fetchTurno();
//
//                                     Navigator.pop(context);
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         // adcontroller.staticHomeAd.dispose();
//                                         return Align(
//                                           alignment: Alignment.center,
//                                           child: Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 10.w),
//                                             child: Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: <Widget>[
//                                                 Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       horizontal: 10.w),
//                                                   decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color: PRIMARY_COLOR),
//                                                     // color: theme.scaffoldBackgroundColor,
//                                                     borderRadius:
//                                                         BorderRadius.all(
//                                                       Radius.circular(5.r),
//                                                     ),
//                                                   ),
//                                                   child: SingleChildScrollView(
//                                                     child: Wrap(
//                                                       alignment: WrapAlignment
//                                                           .spaceAround,
//                                                       // runSpacing: 1.h,
//                                                       children: <Widget>[
//                                                         ...calendarController
//                                                             .turno
//                                                             .map((m) {
//                                                           return Padding(
//                                                             padding: EdgeInsets
//                                                                 .symmetric(
//                                                                     horizontal:
//                                                                         2.w),
//                                                             child:
//                                                                 ElevatedButton(
//                                                               style:
//                                                                   ElevatedButton
//                                                                       .styleFrom(
//                                                                 side: BorderSide(
//                                                                     width:
//                                                                         0.8.r),
//                                                                 shape:
//                                                                     RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.r),
//                                                                 ),
//                                                                 backgroundColor:
//                                                                     HexColor(m
//                                                                         .color!),
//                                                               ),
//                                                               child: Container(
//                                                                 alignment:
//                                                                     Alignment
//                                                                         .center,
//                                                                 height: 20.h,
//                                                                 width: 75.w,
//                                                                 child: Text(
//                                                                   m.description!,
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           12.sp,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       color: HexColor(m.color!).computeLuminance() >
//                                                                               0.5
//                                                                           ? Colors
//                                                                               .black
//                                                                           : Colors
//                                                                               .white),
//                                                                 ),
//                                                               ),
//                                                               onPressed:
//                                                                   () async {
//                                                                 await CalendarioDB
//                                                                     .db
//                                                                     .addCuadranteItem(
//                                                                   CuadranteDay(
//                                                                     cuadranteName:
//                                                                         'Turnos sueltos',
//                                                                     dateTime: DateTime.parse(selectedDate
//                                                                         .toString()
//                                                                         .substring(
//                                                                             0,
//                                                                             10)),
//                                                                     color:
//                                                                         m.color,
//                                                                     description:
//                                                                         m.description,
//                                                                     endHour: m
//                                                                         .endHour,
//                                                                     startHour: m
//                                                                         .startHour,
//                                                                     title:
//                                                                         m.title,
//                                                                   ),
//                                                                 );
//                                                                 // await calendarController.getCuadrante();
//                                                                 // adcontroller.staticHomeAd.load();
//                                                                 await getCuadrante;
//
//                                                                 // setState(() =>
//                                                                 //     _focusedDay.value =
//                                                                 //         selectedDate);
//
//                                                                 Navigator.pop(
//                                                                     context); // Get.offAllNamed('/home');
//                                                               },
//                                                             ),
//                                                           );
//                                                         }),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: const Text("Añade Turno"),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 2.w),
//                             Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.all(2.h),
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Get.toNamed('/add-notas',
//                                         arguments: selectedDate
//                                             .millisecondsSinceEpoch);
//                                   },
//                                   child: const Text("Añade Nota"),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
class DrawTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, Paint()..color = PRIMARY_COLOR);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClipperStack extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0.0, 0.0);
    path.lineTo(0.0, size.height - 10);
    path.lineTo((size.width / 2) - 5, size.height - 10);

    path.lineTo(size.width / 2, size.height);

    path.lineTo((size.width / 2) + 5, size.height - 10);
    path.lineTo(size.width, size.height - 10);

    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
