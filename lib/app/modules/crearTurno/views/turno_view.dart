import 'dart:io';

import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../config/theme/my_fonts.dart';
import '../../../../config/util/hexColor.dart';
import '../../home/providers/calendar_providers.dart';
import '../controllers/crear_turno_controller.dart';
import 'add_turno_view.dart';
import 'edit_turno_view.dart';

class TurnoView extends GetView<CrearTurnoController> {
  const TurnoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          adcontroller.staticHomeAd.load();
          Get.offAllNamed('/home');
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
              icon: Icon(
                Icons.home,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              onPressed: () {
                adcontroller.staticHomeAd.load();
                Get.offAllNamed('/home');
              }),

          title: Text(
            'Tipos de Días',
            style: CustomTextStyle.appBarTitle(context: context),

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
                itemCount: controller.turnoTypeList.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: HexColor(controller.turnoTypeList[index].color!),
                        border: Border.all(width: 0.8),
                        borderRadius: BorderRadius.circular(5.r),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 3),
                        ]),
                    margin:
                        const EdgeInsets.only(top: 4.0, left: 5.0, right: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              controller.turnoTypeList[index].description!,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.color),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            // controller.turnoType[index].startHour != null &&
                            //         controller.turnoType[index].endHour != null &&
                            //         controller.turnoType[index].startHour != '' &&
                            //         controller.turnoType[index].endHour != ''
                            //     ?
                            Text(
                                    'De ${controller.turnoTypeList[index].startHour} a ${controller.turnoTypeList[index].endHour}',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.color),
                            )
                                // : Container()
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .color),
                          onPressed: () async {
                            await controller.editEventsType(index);
                            await controller.updateEditScreen();
                            await Future.delayed(Duration(milliseconds: 200));
                            Get.to(
                                  () =>  EditTurnoView(controller.turnoType),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 100),
                              // arguments: controller.turnoType
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .color),
                          onPressed: () async {
                            await controller.deleteEventsType(index);
                            final container = ProviderScope.containerOf(
                              context,
                              listen: false,
                            );
                            container.invalidate(turnoTypesProvider);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),        heroTag: "botonAddTurno",
          onPressed: () {
            Get.to(
              () => const AddTurnoView(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 100),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Añadir'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
