import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../CrearTurno/views/turno_view.dart';
import '../controllers/crear_turno_controller.dart';

class AddTurnoView extends GetView<CrearTurnoController> {
  const AddTurnoView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 30.0,
          ),
          color: Theme.of(context).textTheme.titleLarge!.color,
          tooltip: "Color",
          onPressed: () {
            Get.to(() => const TurnoView());
          },
        ),
        elevation: 0.0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Crear Turno',
          style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.titleLarge?.color),
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
                      controller: controller.titlecontroller,
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
                              border:
                              Border.all(color: controller.color, width: 2),
                              color: controller.color.withAlpha(600),
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
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
                                    controller.titlecontroller!.text
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: controller.color,
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
                controller: controller.descriptioncontroller,
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
                  Container(
                    width: (MediaQuery.of(context).size.width) / 2.2,
                    child: TextField(
                      controller: controller.startcontroller,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15))),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () {
                            // dp.DatePicker.showTimePicker(context,
                            //     onConfirm: (time) {
                            //   setState(() {
                            //     _startcontroller!.text = format.format(time);
                            //   });
                            // },
                            //     // locale: LocaleType.es
                            // );
                          },
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width) / 2.2,
                    child: TextField(
                      controller: controller.endcontroller,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15))),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () {
                            // dp.DatePicker.showTimePicker(
                            //   context,
                            //   onConfirm: (time) {
                            //     setState(() {
                            //       _endcontroller!.text = format.format(time);
                            //     });
                            //   },
                            //   // locale: LocaleType.es,
                            // );
                          },
                        ),
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
                  controller.getColor();
                },
                child: Material(
                  type: MaterialType.circle,
                  color: controller.color,
                  child: Container(
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
                        borderRadius: new BorderRadius.circular(15.0),
                      ), // foreground (text) color
                    ),
                    child: const Text('Añadir'),
                    onPressed: () {
                      controller.addTurno();
                      Get.back(closeOverlays: true);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
