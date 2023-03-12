import 'package:calendario2/app/modules/CrearTurno/views/widgets/input_field.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../home/views/home_view.dart';
import '../controllers/crear_cuadrante_controller.dart';

class CrearCuadranteView extends GetView<CrearCuadranteController> {
  const CrearCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CrearCuadranteController());
    var theme = Theme.of(context);

    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.home,
                color: theme.primaryColor,
              ),
              color: theme.primaryColor,
              onPressed: () {
                Get.to(const HomeView(),
                    duration: const Duration(milliseconds: 100),
                    transition: Transition.leftToRight);
              },
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Crear Cuadrante',
              style: TextStyle(
                fontSize: MyFonts.headline3TextSize,
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: controller.submit()
                    ? () async {
                        print(controller.inicialDate.value!.toString());

                        //Todo await para que se cargue mientras se pasa

                        Navigator.of(context).pushReplacementNamed('/home');

                        await controller.Rotation(
                            DateTime.parse(controller.inicialDate.value!
                                .toString()
                                .substring(0,10)),
                            DateTime.parse(controller.endDate.value!
                                .toString()
                                .substring(0,10)));
                      }
                    : () => controller.alertDialog(context),
                icon: controller.submit()
                    ? Icon(
                        Icons.done,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.done_outline,
                        color: Theme.of(context).iconTheme.color,
                      ),
                // key: keyButton5,
              )
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 1.h,
              ),
              Column(

                children: <Widget>[
                  Container(
                    // width: 280.w,
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment:  MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                                child: Text(
                              "Pulsa aqui para ver como crear cuadrante.",
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            )),
                            IconButton(
                              icon: const Icon(Icons.info,
                                  color: Colors.redAccent),
                              tooltip: '',
                              onPressed: () {
                                print(controller.inicialDate.value);
                                // showTutorial();
                              },
                            ),
                          ],

                        ),
                        // Row(
                        //   children: <Widget>[
                        //     Text(
                        //       "Repetir cuadrante en todo el calendario",
                        //       style: TextStyle(
                        //         fontSize: 12.sp,
                        //       ),
                        //     ),
                        //     Switch(
                        //         value: controller.isSwitched.value,
                        //         onChanged: (value) {
                        //           controller.addYear();
                        //           controller.isSwitched.value = value;
                        //         },
                        //       // key: keyButton3,
                        //       // value: controller.bol,
                        //       // onChanged: (value) {
                        //       //   if (controller.isSwitched = value) {
                        //       //     controller.bol = false;
                        //       //     print(controller.bol);
                        //       //     controller.endDate.value!
                        //       //           .add(const Duration(days: 365))
                        //       //           .subtract(const Duration(hours: 2))
                        //       //           .toIso8601String()
                        //       //           .substring(0, 10);
                        //       //     } else {
                        //       //       controller.bol = true;
                        //       //   }
                        //       // },
                        //
                        //       activeTrackColor: Colors.lightGreenAccent,
                        //       activeColor: Colors.green,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: (MediaQuery.of(context).size.width) / 2.2,
                        child: InputField(
                          label: 'Inicio',
                          hintText: controller.inicialDate.value!
                              .toIso8601String()
                              .substring(0, 10),
                          widget: IconButton(
                            onPressed: () async {
                              controller.inicialDate(
                                await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 364))),
                              )!;
                            },
                            icon: const Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width) / 2.2,
                        child: InputField(
                          label: 'Fin',
                          hintText: controller.endDate.value!
                              .toIso8601String()
                              .substring(0, 10),
                          widget: IconButton(
                            onPressed: () async {
                              controller.endDate(await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 364))))!;
                            },
                            icon: const Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5),
                  itemCount: controller.list.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: HexColor(controller.list[index].color!),
                          border: Border.all(width: 0.8),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 3),
                          ]),
                      margin: const EdgeInsets.all(2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              controller.list[index].title!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            onTap: () async {
                              controller.list.remove(controller.list[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await controller.showPopUp(context);
            },
            child: const Icon(Icons.add),
            // key: keyButton4,
          ));
    });
  }
}
