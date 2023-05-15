import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/notas_view_controller.dart';

class NotasView extends GetView<NotasViewController> {
  const NotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Notas',
              style: CustomTextStyle.appBarTitle(context: context),
              overflow: TextOverflow.visible,
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: PRIMARY_COLOR,
                  size: 26.sp,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            actions: <Widget>[
              const Spacer(),
              Obx(() {
                return IconButton(
                  icon: Icon(
                      size: 26.sp,
                      controller.important.value
                          ? Icons.flag
                          : Icons.outlined_flag),
                  color:
                      controller.important.value ? Colors.red : Colors.black45,
                  onPressed: () {
                    controller.markImportantAsDirty();
                  },
                );
              }),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: PRIMARY_COLOR,
                  size: 26.sp,
                ),
                onPressed: controller.handleDelete,
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: PRIMARY_COLOR,
                  size: 26.sp,
                ),
                onPressed: controller.shareApp,
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: PRIMARY_COLOR,
                  size: 26.sp,
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
                          fontWeight: FontWeight.w900,
                          fontSize: 36.sp,
                        ),
                        // overflow: TextOverflow.visible,
                        // softWrap: true,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: controller.headerShouldShow.value ? 1 : 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.w),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: Text(
                                    "Inicio:",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  )),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(controller
                                        .currentNote
                                        .value
                                        .startTimeMilliseconds!)
                                    .formatDateTime24H
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(controller
                                        .currentNote
                                        .value
                                        .startTimeMilliseconds!)
                                    .formatDateYMMMd
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600),
                              ),
                              const Spacer(),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: Text(
                                    "Fin:    ",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600),
                                  )),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(controller
                                        .currentNote.value.endTimeMilliseconds!)
                                    .formatDateTime24H
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(controller
                                        .currentNote.value.endTimeMilliseconds!)
                                    .formatDateYMMMd
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 24.w, top: 16.h, bottom: 14.h, right: 24.w),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: PRIMARY_COLOR,
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.only(right: 10.w),
                          child: controller.currentNote.value.site == null
                              ? Text(
                                  "No hay ubicación",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600),
                                )
                              : Text(
                                  "${controller.currentNote.value.site}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 24.w, top: 16.h, bottom: 14.h, right: 24.w),
                    child: !controller.isAlarmaCreated.value
                        ? const Text(
                            "No has añadido alarma",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          )
                        : Row(
                            children: [
                              const Icon(
                                Icons.alarm,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "${controller.currentNote.value.alarmaActivadaString}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
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
