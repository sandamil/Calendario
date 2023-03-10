import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../CrearTurno/views/turno_view.dart';
import '../controllers/crear_turno_controller.dart';
import 'widgets/input_field.dart';

class AddTurnoView extends GetView<CrearTurnoController> {
  const AddTurnoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var logger = Logger();

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
            // color: Theme.of(context).textTheme.titleLarge!.color,
            tooltip: "Color",
            onPressed: () {
              Get.to(() => const TurnoView());
            },
          ),
          elevation: 0.0,
          backgroundColor: controller.turnoColor.value,
          title: Text(
            'Crear Turno',
            style: TextStyle(
              fontSize: 25.sp,
              // color: Theme.of(context).textTheme.titleLarge?.color
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Spacer(),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 40.w,
                      child: TextField(
                        maxLength: 3,
                        controller: controller.titleValueController,
                        onChanged: (value) => controller.setTitle(value),
                        decoration: const InputDecoration(
                          hintText:
                              'Letras que muestra el dia marcado en el calendario',
                          labelText: 'Abreviatura',
                          border: OutlineInputBorder(
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
                                    color: controller.turnoColor.value,
                                    width: 2),
                                color:
                                    controller.turnoColor.value.withAlpha(600),
                                borderRadius: BorderRadius.circular(15)),
                            child: SizedBox(
                              width: 70,
                              height: 60,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      '15',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .color,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      controller.title.value.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: controller.turnoColor.value,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "VISTA PREVIA",
                            style: Theme.of(context).primaryTextTheme.caption,
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
                            var _pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              helpText: 'Selecciona hora de fin',
                              cancelText: 'Cancelar',
                              confirmText: 'Ok',
                            );

                            controller.endDate(_pickedTime!.format(context));
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ), // foreground (text) color
                      ),
                      child: const Text('Añadir'),
                      onPressed: () {
                        logger.w("Warning log");

                        controller.addTurno();
                        Get.back(closeOverlays: true);
                      }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
