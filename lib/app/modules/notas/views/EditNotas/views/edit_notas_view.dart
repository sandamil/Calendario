import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../controllers/ads_controller.dart';
import '../controllers/edit_notas_controller.dart';

class EditNotasView extends GetView<EditNotasController> {
   EditNotasView({Key? key}) : super(key: key);

  final adcontroller = Get.find<AdsController>();


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    AlarmasController alarmasController = AlarmasController();

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Editar Nota',
            style: CustomTextStyle.appBarTitle(context: context),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
          leading: IconButton(
              icon: Icon(
                Icons.clear,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              onPressed: () {
                adcontroller.loadNotesListBannerAd();

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
                adcontroller.loadNotesListBannerAd();

                await controller.editNote();
                Get.offAllNamed('/notas');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
                // key: _formKey,
                child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildGeneralFormField(
                      controller.title.value, 'Titulo del evento', 1),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(Get.context!,
                          theme: DatePickerTheme(
                              cancelStyle: TextStyle(
                                  color: Colors.redAccent.shade200,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              doneStyle: TextStyle(
                                  color: MyColors.textColorPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              itemStyle: TextStyle(
                                  color: MyColors.textColorPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              backgroundColor: MyColors.cellColor),
                          showTitleActions: true, onChanged: (DateTime date) {
                        if (controller.endTime.value.millisecondsSinceEpoch <
                            date.millisecondsSinceEpoch) {
                          controller.endTime.value = date;
                        }
                        controller.startTime.value = date;
                      },
                          onConfirm: (DateTime date) {},
                          currentTime: controller.startTime.value,
                          locale: LocaleType.es);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Hora de inicio',
                              style: CustomTextStyle.rowButomText),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                        ])),
                TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(Get.context!,
                          theme: DatePickerTheme(
                              cancelStyle: TextStyle(
                                  color: Colors.redAccent.shade200,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              doneStyle: TextStyle(
                                  color: MyColors.textColorPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              itemStyle: TextStyle(
                                  color: MyColors.textColorPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                              backgroundColor: MyColors.cellColor),
                          showTitleActions: true, onChanged: (DateTime date) {
                        if (controller.endTime.value.millisecondsSinceEpoch <=
                            date.millisecondsSinceEpoch) {
                          controller.endTime.value = date;
                        }
                      },
                          onConfirm: (DateTime date) {},
                          currentTime: controller.endTime.value,
                          locale: LocaleType.es);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Hora final',
                              style: CustomTextStyle.rowButomText),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                'Tienes una alarma creada, para modificarla o borrarla accede a las opciones pulsando en ella.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                              // Get.toNamed('/add-notas', arguments: selectedDate);
                                            },
                                            child: const Text("Aceptar"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                          : Get.toNamed('/alarmas', arguments: {
                              'currentNote': controller.currentNote.value,
                              'isEditing': true,
                            });
                    },
                    child: Row(
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
                controller.alarmaCreadaNota != null
                    ? ExampleAlarmTile(
                        key: Key(controller.alarmaCreadaNota!.id.toString()),
                        title: TimeOfDay(
                          hour: controller.alarmaCreadaNota!.dateTime.hour,
                          minute: controller.alarmaCreadaNota!.dateTime.minute,
                        ).format(context),
                        onPressed: () {
                          null;
                          // alarmasController.navigateToAlarmScreen(
                          //     controller.alarmaCreadaNota, context);
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
                                controller.important.value
                                    ? Icons.flag
                                    : Icons.outlined_flag,
                                color: controller.important.value
                                    ? Colors.red
                                    : Colors.black45,
                              )
                            ],
                          )
                        ])),
                SizedBox(
                  height: 4.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildGeneralFormField(
                      controller.site.value, 'Ubicación', 2),
                ),
                SizedBox(
                  height: 4.h,
                ),
                _buildGeneralFormField(
                    controller.notes.value, 'Observaciones', 8),
              ],
            )),
          ),
        ),
      );
    });
  }

  TextFormField _buildGeneralFormField(TextEditingController value, String hint, int lines) {
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
          hintStyle: CustomTextStyle.hintText),
      maxLines: lines,
    );
  }
}
