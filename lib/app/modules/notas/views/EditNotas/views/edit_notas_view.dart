import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalLineBetween.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as dp;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/edit_notas_controller.dart';

class EditNotasView extends GetView<EditNotasController> {
  const EditNotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    AlarmasController alarmasController = AlarmasController();

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Editar Nota',
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                color: theme.primaryColor),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
          leading: IconButton(
              icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
              iconSize: 24.sp,
              onPressed: () {
                Get.offAllNamed('/notas');
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
              iconSize: 24.sp,
              padding: const EdgeInsets.only(right: 3),
              onPressed: () async {
                await controller.editNote();
                Get.offAllNamed('/notas');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
              // key: _formKey,
              child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                child: _buildGeneralFormField(
                    controller.title.value, 'Titulo del evento', 1),
              ),
              GeneralLineBetween(),
              TextButton(
                  onPressed: () {
                    dp.DatePicker.showDateTimePicker(Get.context!,
                        showTitleActions: true, onChanged: (DateTime date) {
                      if (controller.endTime.value.millisecondsSinceEpoch <
                          date.millisecondsSinceEpoch) {
                        controller.endTime.value = date;
                      }
                      controller.startTime.value = date;
                    },
                        onConfirm: (DateTime date) {},
                        currentTime: controller.startTime.value,
                        locale: dp.LocaleType.es);
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Hora de inicio',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${controller.startTime.value.formatDateYMD} ${controller.startTime.value.formatDateTime24H}',
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16.sp),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14.sp,
                            )
                          ],
                        )
                      ])),
              TextButton(
                  onPressed: () {
                    dp.DatePicker.showDateTimePicker(Get.context!,
                        showTitleActions: true, onChanged: (DateTime date) {
                      if (controller.endTime.value.millisecondsSinceEpoch <=
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
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${controller.endTime.value.formatDateYMD} ${controller.endTime.value.formatDateTime24H}',
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16.sp),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14.sp,
                            )
                          ],
                        )
                      ])),
              GeneralLineBetween(),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
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
                                          color: theme.scaffoldBackgroundColor,
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
                        Text(
                          'Recordatorio',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              controller.alarmaActivadaString.value,
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16.sp),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14.sp,
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
              GeneralLineBetween(),
              TextButton(
                  onPressed: controller.markImportantAsDirty,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Marcar como importante',
                          style: TextStyle(fontSize: 16.sp),
                        ),
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
              GeneralLineBetween(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                child: _buildGeneralFormField(
                    controller.site.value, 'Ubicación', 2),
              ),
              const SizedBox(
                height: 6,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                child: _buildGeneralFormField(
                    controller.notes.value, 'Observaciones', 8),
              ),
            ],
          )),
        ),
      );
    });
  }

  TextFormField _buildGeneralFormField(
      TextEditingController value, String hint, int lines) {
    final double radiusNum = 5.r;
    return TextFormField(
      controller: value,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.only(left: 20, top: 20),
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(radiusNum),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radiusNum),
            ),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2,
            )),
        hintText: hint,
      ),
      maxLines: lines,
    );
  }
}
