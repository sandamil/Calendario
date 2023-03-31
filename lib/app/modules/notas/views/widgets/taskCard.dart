import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../../Notas/views/NotasView/controllers/notas_view_controller.dart';

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
    Key? key,
  }) : super(key: key);

  final Task noteData;
  final Function(Task noteData) onTapAction;

  @override
  Widget build(BuildContext context) {
    NotasViewController notasViewController = NotasViewController();

    var date =
        DateTime.fromMillisecondsSinceEpoch(noteData.startTimeMilliseconds!);
    String neatDate = DateFormat('dd-MM-yyyy HH:mm').format(date);

    // print(noteData.endTimeMilliseconds);

    Color color =
        colorList.elementAt(noteData.title!.length % colorList.length);

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            label: 'Archive',
            backgroundColor: Colors.blue,
            icon: Icons.archive,
            onPressed: (context) {},
          ),
        ],
      ),
      endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black38, offset: Offset(1.0, 2.0))
                ],
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.indigo,
              ),
              child: SlidableAction(
                label: 'Compartir',
                backgroundColor: Colors.indigo.withOpacity(0.0),
                icon: Icons.share,
                onPressed: (context) {},
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black38, offset: Offset(1.0, 2.0))
                ],
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.red,
              ),
              child: SlidableAction(
                label: 'Delete',
                backgroundColor: Colors.red.withOpacity(0.0),
                icon: Icons.delete,
                onPressed: (context) {},
              ),
            ),
          ]),
      child: Container(
          margin: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [buildBoxShadow(color, context)],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).dialogBackgroundColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                onTapAction(noteData);
              },
              splashColor: color.withAlpha(20),
              highlightColor: color.withAlpha(10),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 8, left: 8),
                          child: Text(
                            noteData.title!.trim().length <= 20
                                ? noteData.title!.trim()
                                : noteData.title!.trim().substring(0, 20) +
                                    '...',
                            style: const TextStyle(
                                fontFamily: 'ZillaSlab',
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          noteData.isImportant!
                              ? Icons.star
                              : Icons.star_outline,
                          color:
                              noteData.isImportant! ? Colors.red : Colors.grey,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 4, left: 8),
                            child: Text(
                              noteData.notes!.trim().split('\n').first.length <=
                                      30
                                  ? noteData.notes!.trim().split('\n').first
                                  : '${noteData.notes!.trim().split('\n').first.substring(0, 30)}...',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade400),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(bottom: 4, right: 8),
                            child: Text(
                              neatDate,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade300,
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
    );
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    // if (Theme.of(context).brightness == Brightness.dark) {
    //   return BoxShadow(
    //       color: Colors.black.withAlpha(200),
    //       blurRadius: 8,
    //       offset: const Offset(0, 8));
    // }
    return BoxShadow(
        color: color.withAlpha(25), blurRadius: 8, offset: const Offset(0, 8));
  }
}
