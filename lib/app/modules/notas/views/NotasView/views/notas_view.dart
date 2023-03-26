import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import '../controllers/notas_view_controller.dart';

class NotasView extends GetView<NotasViewController> {
  const NotasView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
//    var dateEdnd = new DateTime.fromMillisecondsSinceEpoch(
//        widget.currentNote.endTimeMilliseconds);
//    String neatDateEnd = DateFormat('dd-MM-yyyy HH:mm').format(date);
    if (controller.currentNote == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading..."),
        ),
      );
    } else {
      var date = DateTime.fromMillisecondsSinceEpoch(
          controller.currentNote.startTimeMilliseconds!);
      String neatDate = DateFormat('dd-MM-yyyy HH:mm').format(date);
      return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            title: const Text('Ver'),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  // color: Theme.of(context).primaryColorDark,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            actions: <Widget>[
              const Spacer(),
              IconButton(
                icon: Icon(controller.currentNote.isImportant!
                    ? Icons.flag
                    : Icons.outlined_flag),
                color: controller.currentNote.isImportant!
                    ? Colors.red
                    : Theme.of(context).primaryColorDark,
                onPressed: () {
                  controller.markImportantAsDirty();
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).primaryColorDark),
                onPressed: controller.handleDelete,
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: controller.handleShare,
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: controller.handleEdit,
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              ListView(
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 10.0, bottom: 16),
                    child: AnimatedOpacity(
                      opacity: controller.headerShouldShow ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      child: Text(
                        controller.currentNote.title!,
                        style: const TextStyle(
                          fontFamily: 'ZillaSlab',
                          fontWeight: FontWeight.w700,
                          fontSize: 36,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: controller.headerShouldShow ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(
                        children: <Widget>[
                          Text(
                            neatDate,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.only(right: 6),
                            child: controller.currentNote.site == null
                                ? Text(
                                    "No hay ubicación",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500),
                                  )
                                : Text(
                                    "${controller.currentNote.site}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, top: 36, bottom: 24, right: 24),
                    child: controller.currentNote.notes == null
                        ? const Text(
                            "No has añadido descripción",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          )
                        : Text(
                            "${controller.currentNote.notes}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                  )
                ],
              ),
            ],
          ));
    }
  }
}
