import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../config/theme/my_fonts.dart';
import '../../CrearTurno/views/turno_view.dart';
import '../../home/providers/calendar_providers.dart';
import '../../../data/model/turnoType.dart';
import '../controllers/crear_turno_controller.dart';
import 'widgets/input_field.dart';

class AddTurnoView extends GetView<CrearTurnoController> {
  const AddTurnoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Obx(() {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 26.sp,
                color: controller.turnoColor.value.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
              onPressed: () {
                Get.to(
                      () => const TurnoView(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 100),
                );
              },
            ),
            elevation: 0,
            centerTitle: false,
            backgroundColor: controller.turnoColor.value,
            title: Text(
              'Crear Turno',
              style: CustomTextStyle.appBarTitle(
                context: context,
              ).copyWith(
                color: controller.turnoColor.value.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 50.h, left: 15.w, right: 15.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Spacer(),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: 60.w,
                        child: TextField(
                          maxLength: 3,
                          controller: controller.titleValueController,
                          onChanged: (value) => controller.setTitle(value),
                          decoration: InputDecoration(
                            hintMaxLines: 2,
                            hintStyle: TextStyle(
                              fontSize: 6.sp,
                            ),
                            hintText: 'Abreviatura',
                            labelText: 'Abreviatura',
                            border: const OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.yellow),

                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                      Column(
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: MyColors.borderCellColor,
                                      width: 2),
                                  color: MyColors.backgroundLowAccent,
                                  borderRadius: BorderRadius.circular(5.r)),
                              child: SizedBox(
                                width: 50,
                                height: 90,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      child: const Text(
                                        '15',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  controller.turnoColor.value,
                                              width: 2),
                                          color: controller.turnoColor.value
                                              .withAlpha(600),
                                          borderRadius:
                                              BorderRadius.circular(5.r)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: controller.title.value.isEmpty
                                          ? Text(
                                              '        ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: controller
                                                      .turnoColor.value,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          : Text(
                                              controller.title.value
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: controller
                                                      .turnoColor.value,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                    ),
                                  ],
                                ),
                              )),
                          Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              "VISTA PREVIA"
                              "\nEN CALENDARIO",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.sp, color: MyColors.textDisable),
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: controller.descriptionValueController,
                    onChanged: (value) => controller.setDescription(value),
                    decoration: const InputDecoration(
                      hintText: 'Nombre del tipo de turno o dia creado',
                      labelText: 'Título',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                    maxLines: 1,
                    maxLength: 12,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: (MediaQuery.of(context).size.width) / 2.2,
                        child: InputField(
                          label: 'Inicio',
                          hintText: controller.startDate.value,
                          widget: IconButton(
                            onPressed: () async {
                              var pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                helpText: 'Selecciona hora de inicio',
                                cancelText: 'Cancelar',
                                confirmText: 'Ok',
                              );
                              controller.startDate(
                                pickedTime?.format(context) ??
                                    TimeOfDay.now().format(context),
                              );
                            },
                            icon: const Icon(Icons.access_time_rounded),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width) / 2.2,
                        child: InputField(
                          label: 'Fin',
                          hintText: controller.endDate.value,
                          widget: IconButton(
                            onPressed: () async {
                              //Todo rehacer showTimePicker
                              var _pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                helpText: 'Selecciona hora de fin',
                                cancelText: 'Cancelar',
                                confirmText: 'Ok',
                              );
                              /*[VERBOSE-2:dart_vm_initializer.cc(41)] Unhandled Exception: Null check operator used on a null value
                              #0      AddTurnoView.build.<anonymous closure>.<anonymous closure> (package:calendario2/app/modules/CrearTurno/views/add_turno_view.dart:190:61)
                              <asynchronous suspension>*/
                              if (_pickedTime != null) {
                                controller.endDate(_pickedTime.format(context));
                              }
                            },
                            icon: const Icon(Icons.access_time_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () async {
                      controller.colorPickerDialog(context);
                      // controller.getColor();
                    },
                    child: Material(
                      type: MaterialType.circle,
                      color: controller.turnoColor.value,
                      child: const SizedBox(
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Hero(
                    tag: "botonAddTurno",
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        onPressed: controller.isValidResponse()
                            ? () async {
                                final container = ProviderScope.containerOf(
                                  context,
                                  listen: false,
                                );
                                await container
                                    .read(turnoTypesProvider.notifier)
                                    .addTurno(
                                      TurnoType(
                                        title: controller.title.value,
                                        description: controller.description.value,
                                        startHour: controller.startDate.value,
                                        endHour: controller.endDate.value,
                                        color: controller.turnoColor.value.value
                                            .toRadixString(16),
                                      ),
                                    );
                                Get.back(closeOverlays: true);
                              }
                            : () {
                                MyCustomDialog.alertaError(
                                  duracion: 3,
                                  'Necesitas añadir un Título valido.'
                                  '\nAbreviatura puede ir vacio si no quieres mostrarla en el calendario',
                                );
                              },
                        child: Text(
                          'Añadir',
                          style: CustomTextStyle.button,
                        )),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
