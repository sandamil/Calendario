import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/dateUtils.dart';
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
                fontSize: 32.sp,
              ),
              overflow: TextOverflow.visible,
              // softWrap: true,
            ),
            // centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: theme.primaryColor,
                  size: 32.sp,
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
                    padding: EdgeInsets.only(
                        left: 24.w, right: 24.w, top: 24.h, bottom: 16.h),
                    child: AnimatedOpacity(
                      opacity: controller.headerShouldShow.value ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      child: Text(
                        controller.currentNote.value.title!,
                        style: TextStyle(
                          fontFamily: 'ZillaSlab',
                          fontWeight: FontWeight.w700,
                          fontSize: 36.sp,
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
                      padding: EdgeInsets.only(left: 24.w),
                      child: Row(
                        children: <Widget>[
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(controller
                                    .currentNote.value.startTimeMilliseconds!)
                                .formatDateYMMMd
                                .toString(),
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600),
                          ),
                          const Spacer(),
                          Container(
                            padding:  EdgeInsets.only(right: 10.w),
                            child: controller.currentNote.value.site == null
                                ? Text(
                                    "No hay ubicación",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  )
                                : Text(
                                    "${controller.currentNote.value.site}",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(
                        left: 24.w, top: 36.h, bottom: 24.h, right: 24.w),
                    child: controller.isAlarmaCreated.value
                        ? const Text(
                      "No has añadido alarma",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    )
                        : Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.redAccent,),
                            SizedBox(width : 10.w),
                            Text(
                      "${controller.currentNote.value.alarmaActivadaString}",
                      style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                          ],
                        ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(
                        left: 24.w, top: 36.h, bottom: 24.h, right: 24.w),
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
