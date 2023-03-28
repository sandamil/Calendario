import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import '../controllers/notas_view_controller.dart';

class NotasView extends GetView<NotasViewController> {
  const NotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Notas',
              style: TextStyle(
                color: theme.primaryColor,
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 32,
              ),
              overflow: TextOverflow.visible,
              // softWrap: true,
            ),
            // centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: theme.primaryColor,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            actions: <Widget>[
              const Spacer(),
              Obx(() {
                return IconButton(
                  icon: Icon(controller.important.value
                      ? Icons.flag
                      : Icons.outlined_flag),
                  color: controller.important.value ? Colors.red : Colors.grey,
                  onPressed: () {
                    controller.markImportantAsDirty();
                  },
                );
              }),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.primaryColor,
                ),
                onPressed: controller.handleDelete,
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: theme.primaryColor,
                ),
                onPressed: controller.handleShare,
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: theme.primaryColor,
                ),
                onPressed: controller.handleEdit,
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 10.0, bottom: 16),
                    child: AnimatedOpacity(
                      opacity: controller.headerShouldShow.value ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      child: Text(
                        controller.currentNote.value.title!,
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
                    opacity: controller.headerShouldShow.value ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(
                        children: <Widget>[
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(controller
                                    .currentNote.value.startTimeMilliseconds!)
                                .formatDateYMMMd
                                .toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.only(right: 6),
                            child: controller.currentNote.value.site == null
                                ? Text(
                                    "No hay ubicación",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500),
                                  )
                                : Text(
                                    "${controller.currentNote.value.site}",
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
                    child: controller.currentNote.value.notes == null
                        ? const Text(
                            "No has añadido descripción",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          )
                        : Text(
                            "${controller.currentNote.value.notes}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                  )
                ],
              ),
            ],
          ));
    });
  }
}
