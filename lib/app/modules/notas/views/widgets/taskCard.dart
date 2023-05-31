import 'dart:math';

import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../notas/views/NotasView/controllers/notas_view_controller.dart';

List<Color> colorList = [
  Colors.blue,
  Colors.green,
  Colors.indigo,
  Colors.red,
  Colors.cyan,
  Colors.teal,
  Colors.amber.shade900,
  Colors.deepOrange
];

class TaskCard extends StatelessWidget {

  const TaskCard({
    required this.noteData,
    required this.onTapAction,
    required this.routeToNotas,
    Key? key,
  }) : super(key: key);

  final Task noteData;
  final Function(Task noteData) onTapAction;
  final bool routeToNotas;

  @override
  Widget build(BuildContext context) {
    NotasViewController notasViewController = NotasViewController();

    var date =
        DateTime.fromMillisecondsSinceEpoch(noteData.startTimeMilliseconds!);
    String neatDate = DateFormat('dd-MM-yyyy HH:mm').format(date);

    Color color =
    colorList.elementAt(Random().nextInt(colorList.length));

    return Container(
      // padding: EdgeInsets.only(left: 4.w, right: 4.w),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [buildBoxShadow(color, context)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  label: 'Compartir',
                  icon: Icons.share,
                  backgroundColor: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(5.r)),
                  onPressed: (context) {
                    Share.share(''
                        'Titulo: ${noteData.title}'
                        '\nNota: ${noteData.notes}'
                        '\nInicio: ${DateTime.fromMillisecondsSinceEpoch(noteData.startTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(noteData.startTimeMilliseconds!).formatDateYMMMd}'
                        '\nFin: ${DateTime.fromMillisecondsSinceEpoch(noteData.endTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(noteData.endTimeMilliseconds!).formatDateYMMMd}'
                    );
                  },
                ),
                SlidableAction(
                  label: 'Eliminar',
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(5.r)),
                  onPressed: (context) {
                    notasViewController.handleDeleteCalendar(noteData.id, routeToNotas);
                  },
                ),
              ]),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              height: 56.h,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [buildBoxShadow(color, context)],
              ),
              child: Material(
                borderRadius: BorderRadius.circular(5.r),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).cardColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5.r),
                  onTap: () {
                    onTapAction(noteData);
                  },
                  splashColor: color.withAlpha(20),
                  highlightColor: color.withAlpha(10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 6.h, left: 6.w),
                              child: Text(
                                noteData.title!.trim().length <= 20
                                    ? noteData.title!.trim()
                                    : '${noteData.title!.trim().substring(0, 20)}...',
                                style: TextStyle(
                                    // fontFamily: 'ZillaSlab',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Icon(
                                noteData.isImportant!
                                    ? Icons.flag
                                    : Icons.flag_outlined,
                                color: noteData.isImportant!
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 4.h, left: 6.w),
                                child: Text(
                                  noteData.notes!
                                              .trim()
                                              .split('\n')
                                              .first
                                              .length <=
                                          30
                                      ? noteData.notes!.trim().split('\n').first
                                      : '${noteData.notes!.trim().split('\n').first.substring(0, 30)}...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: 3.h, right: 4.w),
                                child: Text(
                                  neatDate,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      // color: Colors.grey.shade300,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    return BoxShadow(
        color: color.withAlpha(8), blurRadius: 8, offset: const Offset(1, 1));
  }
}
