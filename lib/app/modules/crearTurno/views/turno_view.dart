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
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final turnosAsync = ref.watch(turnoTypesProvider);

                  return turnosAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No se pudieron cargar los tipos de días.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(turnoTypesProvider);
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (turnos) {
                      if (turnos.isEmpty) {
                        return const Center(
                          child: Text('No hay tipos de días creados.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: turnos.length,
                        itemBuilder: (context, index) {
                          final turno = turnos[index];

                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: HexColor(turno.color!),
                              border: Border.all(width: 0.8),
                              borderRadius: BorderRadius.circular(5.r),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(
                              top: 4.0,
                              left: 5.0,
                              right: 5.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turno.description ?? '',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .titleLarge
                                              ?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'De ${turno.startHour ?? ''} a ${turno.endHour ?? ''}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .titleLarge
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                  onPressed: () async {
                                    final turnoId = turno.id;
                                    if (turnoId == null) return;

                                    await controller.editEventsType(turnoId);
                                    if (controller.turnoType.value == null) {
                                      return;
                                    }

                                    controller.updateEditScreen();

                                    if (!context.mounted) return;

                                    Get.to(
                                      () => EditTurnoView(controller.turnoType),
                                      transition: Transition.fadeIn,
                                      duration:
                                          const Duration(milliseconds: 100),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                  onPressed: () async {
                                    final turnoId = turno.id;
                                    if (turnoId == null) return;

                                    await ref
                                        .read(turnoTypesProvider.notifier)
                                        .deleteById(turnoId);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
          heroTag: "botonAddTurno",
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
