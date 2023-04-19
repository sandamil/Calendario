import 'package:alarm/alarm.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as dp;

import 'package:get/get.dart';

import '../controllers/add_notas_controller.dart';

class AddNotasView extends GetView<AddNotasController> {
  const AddNotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    AlarmasController alarmasController = AlarmasController();
    // print(
    //     'AddNotasView  build alarms length ${alarmasController.alarms.value.length}');
    // print('AddNotasView  build  ${controller.alarmaCreadaNota.id}');

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Añadir Nota',
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                color: theme.primaryColor),
          ),
          leading: IconButton(
              icon: Icon(Icons.clear, color: theme.primaryColor),
              onPressed: () {
                Get.offAllNamed('/notas');
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check, color: theme.primaryColor),
              padding: const EdgeInsets.only(right: 3),
              onPressed: () async {
                controller.addTravelEvent();
                await controller.addEvent();
                Get.offAllNamed('/notas');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    child: _buildGeneralFormField(
                        controller.title, 'Titulo del evento', 1),key: controller.keyButton13,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Column(
                    key: controller.keyButton14,
                    children: <Widget>[
                      Container(
                          child: TextButton(
                              onPressed: () {
                                dp.DatePicker.showDateTimePicker(Get.context!,
                                    showTitleActions: true,
                                    onChanged: (DateTime date) {
                                  if (controller
                                          .endTime.value.millisecondsSinceEpoch <
                                      date.millisecondsSinceEpoch) {
                                    controller.endTime.value = date;
                                  }
                                  controller.startTime.value = date;
                                }, onConfirm: (DateTime date) {
                                  controller.setStartTime(date);
                                },
                                    currentTime: controller.startTime.value,
                                    locale: dp.LocaleType.es);
                              },
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Hora de inicio',
                                      style: TextStyle(
                                          color: MyColors.textButtom,
                                          fontSize: 14.sp),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${controller.startTime.value.formatDateYMD} ${controller.startTime.value.formatDateTime24H}',
                                          style: TextStyle(
                                              color: MyColors.textButtom,
                                              fontSize: 14.sp),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14.sp,
                                          color: PRIMARY_COLOR,
                                        )
                                      ],
                                    )
                                  ]))),
                      Container(
                        child: TextButton(
                            onPressed: () {
                              dp.DatePicker.showDateTimePicker(Get.context!,
                                  showTitleActions: true,
                                  onChanged: (DateTime date) {
                                if (controller
                                        .endTime.value.millisecondsSinceEpoch <=
                                    date.millisecondsSinceEpoch) {
                                  controller.endTime.value = date;
                                }
                              },
                                  onConfirm: (DateTime date) {},
                                  currentTime: controller.endTime.value,
                                  locale: dp.LocaleType.es);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Hora final',
                                    style: TextStyle(
                                        color: MyColors.textButtom,
                                        fontSize: 14.sp),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${controller.endTime.value.formatDateYMD} ${controller.endTime.value.formatDateTime24H}',
                                        style: TextStyle(
                                            color: MyColors.textButtom,
                                            fontSize: 14.sp),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14.sp,
                                        color: PRIMARY_COLOR,
                                      )
                                    ],
                                  )
                                ])),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 2.h,
                  ),
                  LineWidget(),
                  TextButton(
                      onPressed: () async {
                        controller.alarmaCreadaNota != null
                            ? Get.dialog(Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w),
                                        decoration: BoxDecoration(
                                          color: theme.scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.r),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.h),
                                              child: Icon(
                                                Icons.info,
                                                color: Colors.redAccent,
                                                size: 38.sp,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(6.h),
                                              color:
                                                  theme.scaffoldBackgroundColor,
                                              height: 100.h,
                                              child: Padding(
                                                padding: EdgeInsets.all(4.h),
                                                child: Text(
                                                  'Si continuas se borrara la esta alarma preestablecida para las: ${TimeOfDay(
                                                    hour: controller
                                                        .alarmaCreadaNota!
                                                        .dateTime
                                                        .hour,
                                                    minute: controller
                                                        .alarmaCreadaNota!
                                                        .dateTime
                                                        .minute,
                                                  ).format(context)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      // Get.toNamed('/add-notas', arguments: selectedDate);
                                                    },
                                                    child: const Text("Cancelar"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                Expanded(
                                                    child: ElevatedButton(
                                                  onPressed: () {
                                                    Alarm.stop(controller
                                                            .alarmaCreadaNota!.id)
                                                        .then((_) =>
                                                            alarmasController
                                                                .loadAlarms());
                                                    controller.alarmaCreadaNota =
                                                        null;
                                                    Get.toNamed('/alarmas',
                                                        arguments: {
                                                          'id': controller
                                                              .idGenerated!,
                                                          'startTime': controller
                                                              .startTime.value,
                                                          'notes': controller
                                                              .notes.value,
                                                          'title': controller
                                                              .title.value
                                                        });
                                                  },
                                                  child: const Text("Borrar"),
                                                )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                            : Get.toNamed(
                                '/alarmas',
                                arguments: {
                                  'isEditing': false,
                                  'id': controller.idGenerated!,
                                  'startTime': controller.startTime.value,
                                  'notes': controller.notes.value.text,
                                  'title': controller.title.value.text
                                },
                              );
                        // alarmasController.refresh();
                        // Get.to(AlarmasPage());
                      },
                      child: Row(key: controller.keyButton15,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Recordatorio',
                              style: TextStyle(
                                  color: MyColors.textButtom, fontSize: 14.sp),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  controller.alarmaActivadaString,
                                  style: TextStyle(
                                      color: MyColors.textButtom,
                                      fontSize: 14.sp),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.sp,
                                  color: PRIMARY_COLOR,
                                )
                              ],
                            )
                          ])),

                  // Container(
                  //   height: 200.h,
                  //   child: alarmasController.alarms.value.isNotEmpty
                  //       ? ListView.builder(
                  //         physics: const NeverScrollableScrollPhysics(),
                  //         shrinkWrap: true,
                  //         itemCount: alarmasController.alarms.value.length,
                  //         itemBuilder: (context, index) {
                  //           return Column(
                  //             mainAxisSize: MainAxisSize.max,
                  //             children: [
                  //               alarmasController.alarms[index].id ==
                  //                       controller.idGenerated
                  //                   ? ExampleAlarmTile(
                  //                       key: Key(alarmasController
                  //                           .alarms.value[index].id
                  //                           .toString()),
                  //                       title: TimeOfDay(
                  //                         hour: alarmasController.alarms
                  //                             .value[index].dateTime.hour,
                  //                         minute: alarmasController.alarms
                  //                             .value[index].dateTime.minute,
                  //                       ).format(context),
                  //                       onPressed: () => alarmasController
                  //                           .navigateToAlarmScreen(
                  //                               alarmasController
                  //                                   .alarms.value[index]),
                  //                       onDismissed: () {
                  //                         Alarm.stop(alarmasController
                  //                                 .alarms.value[index].id)
                  //                             .then((_) => alarmasController
                  //                                 .loadAlarms());
                  //                       },
                  //                     )
                  //                   : Container()
                  //             ],
                  //           );
                  //         },
                  //         // Center(
                  //         //     child: Text(
                  //         //       "No alarms set",
                  //         //       style: Theme
                  //         //           .of(context)
                  //         //           .textTheme
                  //         //           .titleMedium,
                  //         //     ));
                  //         // },
                  //       )
                  //       : Center(
                  //           child: Text(
                  //           "No alarms set",
                  //           style: Theme.of(context).textTheme.titleMedium,
                  //         )),
                  // ),
                  controller.alarmaCreadaNota != null
                      ? ExampleAlarmTile(
                          key: Key(controller.alarmaCreadaNota!.id.toString()),
                          title: TimeOfDay(
                            hour: controller.alarmaCreadaNota!.dateTime.hour,
                            minute: controller.alarmaCreadaNota!.dateTime.minute,
                          ).format(context),
                          onPressed: () {
                            alarmasController.navigateToAlarmScreen(
                                controller.alarmaCreadaNota, context);
                          },
                          // onDismissed: () {
                          //   Alarm.stop(alarmasController
                          //       .alarmaCreada!.id)
                          //       .then((_) => alarmasController
                          //       .loadAlarms());
                          // },
                        )
                      : Container(),
                  LineWidget(),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextButton(
                      key: controller.keyButton16,
                      onPressed: controller.markImportantAsDirty,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Marcar como importante',
                              style: TextStyle(
                                  color: MyColors.textButtom, fontSize: 14.sp),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  controller.isImportant.value
                                      ? Icons.flag
                                      : Icons.outlined_flag,
                                  color: controller.isImportant.value
                                      ? Colors.red
                                      : Colors.black,
                                )
                              ],
                            )
                          ])),
                  SizedBox(
                    height: 4.h,
                  ),
                  Column(
                    key: controller.keyButton17,

                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGeneralFormField(controller.site, 'Ubicación', 2),
                      SizedBox(
                        height: 4.h,
                      ),
                      _buildGeneralFormField(controller.notes, 'Observaciones', 8),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.only(left: 8.0, top: 16),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Pulsa aqui si necesitas ayuda para crear notas.",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        IconButton(
                          key: controller.keyNotasAyuda,
                          icon: const Icon(Icons.info, color: Colors.redAccent),
                          tooltip: '',
                          onPressed: () {
                            controller.showTutorial(context);

                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  TextFormField _buildGeneralFormField(
      TextEditingController value, String hint, int lines) {
    final double _radiusNum = 5.r;
    return TextFormField(
      // onTapOutside: (event){
      //   FocusManager.instance.primaryFocus?.unfocus();
      // },
      controller: value,
      decoration: InputDecoration(
        // hintStyle: TextStyle(
        //   color: MyColors.hintText
        // ),
        filled: true,
        contentPadding: EdgeInsets.only(left: 10.w, top: 20.h),
        fillColor: MyColors.cellColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(_radiusNum),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(_radiusNum),
            ),
            borderSide: BorderSide(
              color: MyColors.borderCellColor,
              width: 2.w,
            )),
        hintText: hint,
      ),
      maxLines: lines,
    );
  }
}
