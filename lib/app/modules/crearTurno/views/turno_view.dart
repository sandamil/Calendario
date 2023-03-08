import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../config/theme/my_fonts.dart';
import '../../../../config/util/hexColor.dart';
import '../../home/views/home_view.dart';
import '../controllers/crear_turno_controller.dart';
import 'add_turno_view.dart';

class TurnoView extends GetView<CrearTurnoController> {
  const TurnoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
          'Tipos de Días',
          style: TextStyle(
            fontSize: MyFonts.headline3TextSize,
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 5.0,
          ),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.turnoType.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: HexColor(controller.turnoType[index].color!),
                      border: Border.all(width: 0.8),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 3),
                      ]),
                  margin: const EdgeInsets.only(
                      top: 4.0, left: 5.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            controller.turnoType[index].description!,
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          controller.turnoType[index].startHour != null &&
                              controller.turnoType[index].endHour != null &&
                              controller.turnoType[index].startHour != '' &&
                              controller.turnoType[index].endHour != ''
                              ? Text(
                            'De ${controller.turnoType[index].startHour
                                .toString()} a ${controller.turnoType[index]
                                .endHour.toString()}',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .titleLarge
                                    ?.color),
                          )
                              : Container()
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Theme
                                .of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .color),
                        onPressed: () async {
                          controller.deleteEventsType(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "botonAddTurno",
        onPressed: () {
          Get.to(() => AddTurnoView());
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
