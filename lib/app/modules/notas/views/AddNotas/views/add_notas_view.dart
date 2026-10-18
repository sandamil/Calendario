import 'dart:io';

import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AddNotasView extends ConsumerStatefulWidget {
  const AddNotasView({super.key});

  @override
  ConsumerState<AddNotasView> createState() => _AddNotasViewState();
}

class _AddNotasViewState extends ConsumerState<AddNotasView> {
  bool _tutorialStartScheduled = false;
  final adcontroller = Get.find<AdsController>();

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is DateTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addNotaProvider.notifier).setInitialDate(arguments);
        }
      });
    } else if (arguments is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(arguments);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addNotaProvider.notifier).setInitialDate(date);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notaState = ref.watch(addNotaProvider);
    final notaNotifier = ref.read(addNotaProvider.notifier);

    var theme = Theme.of(context);
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    if (!_tutorialStartScheduled && MySharedPref.getTutoAddTaskFirst()) {
      _tutorialStartScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        notaNotifier.setFirstTime(true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          tutorialController.firstInstall(
            'taskAdd',
            context: context,
            onFinished: () => notaNotifier.setFirstTime(false),
          );
        });
      });
    }

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

                await notaNotifier.saveNota(
                  id: notaState.idGenerated,
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
                    key: notaState.firstTime
                        ? tutorialController.keyButton13
                        : null,
                    child: _buildGeneralFormField(
                        notaNotifier.title, 'Titulo del evento', 1),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Column(
                    key: notaState.firstTime
                        ? tutorialController.keyButton17
                        : null,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGeneralFormField(notaNotifier.site, 'Ubicación', 2),
                      SizedBox(
                        height: 4.h,
                      ),
                      _buildGeneralFormField(
                          notaNotifier.notes, 'Observaciones', 8),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Column(
                    key: notaState.firstTime
                        ? tutorialController.keyButton14
                        : null,
                    children: <Widget>[
                      TextButton(
                          onPressed: () async {
                            final initial = notaState.startTime;
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initial),
                            );
                            if (!context.mounted || selectedTime == null)
                              return;

                            final date = DateTime(
                              initial.year,
                              initial.month,
                              initial.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            notaNotifier.setStartTime(date);
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
                                          '${notaState.startTime.formatDateYMD} ${notaState.startTime.formatDateTime24H}',
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
                            final initial = notaState.endTime;
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initial),
                            );
                            if (!context.mounted || selectedTime == null)
                              return;

                            var date = DateTime(
                              initial.year,
                              initial.month,
                              initial.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            if (date.isBefore(notaState.startTime)) {
                              date = date.add(const Duration(days: 1));
                            }

                            notaNotifier.setEndTime(date);
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
                                      '${notaState.endTime.formatDateYMD} ${notaState.endTime.formatDateTime24H}',
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
                        notaState.alarmaCreada
                            ? buildDialogAlarma(theme, notaState, notaNotifier)
                            : Get.toNamed(
                                '/alarmas',
                                arguments: {
                                  'isEditing': false,
                                  'id': notaState.idGenerated,
                                  'startTime': notaState.startTime,
                                  'notes': notaNotifier.notes.text,
                                  'title': notaNotifier.title.text
                                },
                              );
                        // Get.to(AlarmasPage());
                      },
                      child: Row(
                          key: notaState.firstTime
                              ? tutorialController.keyButton15
                              : null,
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
                                  notaState.alarmaActivadaString,
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
                  notaState.alarmaCreada
                      ? ExampleAlarmTile(
                          key: Key(notaState.alarmTime.toString()),
                          title: TimeOfDay(
                            hour: notaState.alarmTime.hour,
                            minute: notaState.alarmTime.minute,
                          ).format(context),
                          onPressed: () {
                            null;
                            // navigateToAlarmScreen(
                            //     notaState.alarmaCreadaNota, context);
                          },
                        )
                      : Container(),
                  // : Container(child: Text(notaState.alarmTime.toString()),),
                  LineWidget(),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextButton(
                      key: notaState.firstTime
                          ? tutorialController.keyButton16
                          : null,
                      onPressed: notaNotifier.toggleImportant,
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
                                  notaState.isImportant
                                      ? Icons.flag
                                      : Icons.outlined_flag,
                                  color: notaState.isImportant
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
                          key: notaState.firstTime
                              ? tutorialController.keyNotasAyuda
                              : null,
                          icon: const AppIcon(AppIcons.informacion,
                              color: Colors.green),
                          tooltip: '',
                          onPressed: () {
                            notaNotifier.setFirstTime(true);
                            tutorialController.showTutorial(
                              context,
                              'taskAdd',
                              onFinished: () =>
                                  notaNotifier.setFirstTime(false),
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

  Future<dynamic> buildDialogAlarma(
      ThemeData theme, AddNotaState notaState, AddNotaNotifier notaNotifier) {
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
                        '${notaState.alarmaHora}'
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
                          // La alarma se gestiona desde /alarmas.
                          Get.toNamed('/alarmas', arguments: {
                            'id': notaState.idGenerated,
                            'startTime': notaState.startTime,
                            'notes': notaNotifier.notes.text,
                            'title': notaNotifier.title.text
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
