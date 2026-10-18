import 'dart:io';

import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/theme/my_styles.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dp;

import 'package:get/get.dart';

import '../../../../../../config/util/app_icons.dart';
import '../../../../../controllers/ads_controller.dart';
import '../controllers/add_notas_controller.dart';

class AddNotasView extends GetView<AddNotasController> {
  AddNotasView({Key? key}) : super(key: key);

  bool _tutorialStartScheduled = false;
  final adcontroller = Get.find<AdsController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    if (!_tutorialStartScheduled && MySharedPref.getTutoAddTaskFirst()) {
      _tutorialStartScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        controller.firstTime.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          tutorialController.firstInstall(
            'taskAdd',
            context: context,
            onFinished: () => controller.firstTime.value = false,
          );
        });
      });
    }

    AlarmasController alarmasController = AlarmasController();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Añadir Nota',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.clear,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              onPressed: () async {
                // adcontroller.loadNotesListBannerAd();

                Get.offAllNamed('/notas');
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              padding: EdgeInsets.only(right: 3.w),
              onPressed: () async {
                // adcontroller.loadNotesListBannerAd();

                // controller.addTravelEvent();
                final notaNotifier = ProviderScope.containerOf(
                  context,
                  listen: false,
                ).read(addNotaProvider.notifier);

                // Sincronizar los campos que todavía gestiona el controlador
                // antiguo mientras terminamos la migración de la vista.
                notaNotifier.title.text = controller.title.text;
                notaNotifier.site.text = controller.site.text;
                notaNotifier.notes.text = controller.notes.text;
                notaNotifier.setStartTime(controller.startTime.value);
                notaNotifier.setEndTime(controller.endTime.value);
                notaNotifier.setImportant(controller.isImportant.value);
                notaNotifier.setAlarmaCreada(controller.alarmaCreada);
                notaNotifier.setAlarmaTime(controller.alarmTime);
                notaNotifier.setAlarmaActivadaString(
                  controller.alarmaActivadaString.value,
                );

                await notaNotifier.saveNota(
                  id: controller.idGenerated as int?,
                );
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
                  Container(
                    key: controller.firstTime.value
                        ? tutorialController.keyButton13
                        : key,
                    child: _buildGeneralFormField(
                        controller.title, 'Titulo del evento', 1),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Column(
                    key: controller.firstTime.value
                        ? tutorialController.keyButton17
                        : key,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGeneralFormField(controller.site, 'Ubicación', 2),
                      SizedBox(
                        height: 4.h,
                      ),
                      _buildGeneralFormField(
                          controller.notes, 'Observaciones', 8),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Column(
                    key: controller.firstTime.value
                        ? tutorialController.keyButton14
                        : key,
                    children: <Widget>[
                      TextButton(
                          onPressed: () async {
                            final initial = controller.startTime.value;
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initial),
                            );
                            if (!context.mounted || selectedTime == null) return;

                            final date = DateTime(
                              initial.year,
                              initial.month,
                              initial.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            controller.setStartTime(date);
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 6.h,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Hora de inicio',
                                        style: CustomTextStyle.rowButomText),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${controller.startTime.value.formatDateYMD} ${controller.startTime.value.formatDateTime24H}',
                                          style: TextStyle(
                                              color: MyColors.textButtomBlack,
                                              fontSize: 16.sp),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16.sp,
                                          color: PRIMARY_COLOR,
                                        )
                                      ],
                                    )
                                  ]),
                            ],
                          )),
                      TextButton(
                          onPressed: () async {
                            final initial = controller.endTime.value;
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initial),
                            );
                            if (!context.mounted || selectedTime == null) return;

                            var date = DateTime(
                              initial.year,
                              initial.month,
                              initial.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            if (date.isBefore(controller.startTime.value)) {
                              date = date.add(const Duration(days: 1));
                            }

                            controller.endTime.value = date;
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('Hora final',
                                    style: CustomTextStyle.rowButomText),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${controller.endTime.value.formatDateYMD} ${controller.endTime.value.formatDateTime24H}',
                                      style: TextStyle(
                                          color: MyColors.textButtomBlack,
                                          fontSize: 16.sp),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.sp,
                                      color: PRIMARY_COLOR,
                                    )
                                  ],
                                )
                              ])),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  LineWidget(),
                  TextButton(
                      onPressed: () async {
                        controller.alarmaCreada
                            ? buildDialogAlarma(theme)
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
                      child: Row(
                          key: controller.firstTime.value
                              ? tutorialController.keyButton15
                              : key,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('Recordatorio',
                                style: CustomTextStyle.rowButomText),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  controller.alarmaActivadaString.value,
                                  style: TextStyle(
                                      color: MyColors.textButtomBlack,
                                      fontSize: 16.sp),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.sp,
                                  color: PRIMARY_COLOR,
                                )
                              ],
                            )
                          ])),
                  controller.alarmaCreada
                      // || alarmasController.pendingNotifications.contains(id: '${controller.idGenerated}')
                      ? ExampleAlarmTile(
                          key: Key(controller.alarmTime.toString()),
                          title: TimeOfDay(
                            hour: controller.alarmTime.hour,
                            minute: controller.alarmTime.minute,
                          ).format(context),
                          onPressed: () {
                            null;
                            // alarmasController.navigateToAlarmScreen(
                            //     controller.alarmaCreadaNota, context);
                          },
                        )
                      : Container(),
                  // : Container(child: Text(controller.alarmTime.toString()),),
                  LineWidget(),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextButton(
                      key: controller.firstTime.value
                          ? tutorialController.keyButton16
                          : key,
                      onPressed: controller.markImportantAsDirty,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('Marcar como importante',
                                style: CustomTextStyle.rowButomText),
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
                                      : Colors.black45,
                                )
                              ],
                            )
                          ])),
                  Container(
                    padding: EdgeInsets.only(left: 8.w, top: 16.h),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Pulsa aqui si necesitas ayuda para crear notas.",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        IconButton(
                          key: controller.firstTime.value
                              ? tutorialController.keyNotasAyuda
                              : key,
                          icon: const AppIcon(AppIcons.informacion,
                              color: Colors.green),
                          tooltip: '',
                          onPressed: () {
                            controller.firstTime.value = true;
                            tutorialController.showTutorial(
                              context,
                              'taskAdd',
                              onFinished: () =>
                                  controller.firstTime.value = false,
                            );
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

  Future<dynamic> buildDialogAlarma(ThemeData theme) {
    return Get.dialog(Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                    child: AppIcon(
                      AppIcons.informacion,
                      color: Colors.green,
                      size: 38.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.h),
                    color: theme.scaffoldBackgroundColor,
                    height: 100.h,
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        'Tienes una alarma creada en esta nota para las: '
                        '${controller.alarmaHora}'
                        //     '${TimeOfDay(
                        //   hour: controller
                        //       .alarmaCreadaNota!
                        //       .dateTime
                        //       .hour,
                        //   minute: controller
                        //       .alarmaCreadaNota!
                        //       .dateTime
                        //       .minute,
                        // ).format(context)}'
                        ''
                        ', quieres borrarla?',
                        style: Theme.of(Get.context!).textTheme.headlineSmall,
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
                        onPressed: () async {
                          // controller.alarmTime = DateTime(2020);
                          Get.toNamed('/alarmas', arguments: {
                            'id': controller.idGenerated!,
                            'startTime': controller.startTime.value,
                            'notes': controller.notes.value,
                            'title': controller.title.value
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
    ));
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
          fillColor: MyColors.backgroundLowAccent,
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
          hintStyle: CustomTextStyle.hintText),
      maxLines: lines,
    );
  }
}
