import 'dart:io';

import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/modules/CrearTurno/views/widgets/input_field.dart';
import 'package:calendario2/app/modules/crearCuadrante/widgets/beautifulAlertDialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../../config/util/app_icons.dart';
import '../controllers/crear_cuadrante_controller.dart';
import '../providers/crear_cuadrante_provider.dart';
import '../../home/providers/calendar_providers.dart';

class AddCuadranteView extends GetView<CrearCuadranteController> {
  const AddCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          adcontroller.staticHomeAd.load();
          Get.offAllNamed('/home');
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          /*This method here will hide the soft keyboard.*/
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(crearCuadranteProvider);
            final notifier = ref.read(crearCuadranteProvider.notifier);

            // Iniciar el tutorial cuando la pantalla y sus botones ya estén montados.
            if (!state.firstTime && MySharedPref.getTutoCuadranteFirst()) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!context.mounted || !MySharedPref.getTutoCuadranteFirst()) {
                  return;
                }

                // Puede haber varios callbacks pendientes por reconstrucciones.
                // Solo el primero debe iniciar el tutorial.
                if (ref.read(crearCuadranteProvider).firstTime) {
                  return;
                }

                notifier.setFirstTime(true);
                await tutorialController.firstInstall(
                  'cuadrante',
                  context: context,
                  onCuadranteTutorialFinished: () {
                    notifier.setFirstTime(false);
                  },
                );
              });
            }

            return Scaffold(
              appBar: AppBar(
                elevation: 0,
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
                  },
                ),
                title: Text(
                  'Crear Cuadrante',
                  style: CustomTextStyle.appBarTitle(context: context),
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: state.canSubmit
                        ? () async {
                            if (state.cuadranteName.isEmpty) {
                              MyCustomDialog.alertaError(
                                  'Es necesario añadir nombre al cuadrante');
                              return;
                            }
                            //Todo carcgar primera pagina de calendario
                            showAlertLoadingDialog(context);
                            await notifier.cuadranteLoad();
                          }
                        : () => alertDialog(context),
                    icon: state.canSubmit
                        ? Icon(
                            Icons.done,
                            color: Colors.green,
                            size: 24.sp,
                          )
                        : Icon(
                            Icons.done_outline,
                            color: PRIMARY_COLOR.withOpacity(0.4),
                            size: 24.sp,
                          ),
                    key: state.firstTime ? tutorialController.keyButton5 : key,
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 1.h,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Pulsa aqui para ver como crear cuadrante.",
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                            IconButton(
                              icon: const AppIcon(AppIcons.informacion,
                                  color: Colors.green),
                              tooltip: '',
                              onPressed: () {
                                notifier.setFirstTime(true);

                                tutorialController
                                    .showTutorial(context, 'cuadrante',
                                        onCuadranteTutorialFinished: () {
                                  notifier.setFirstTime(false);
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.h),
                          child: TextField(
                            // inputFormatters: [
                            //   FilteringTextInputFormatter.deny(
                            //     RegExp("[0-9]"),
                            //   ),
                            // ],
                            controller: controller.cuadranteName,
                            onChanged: notifier.setCuadranteName,
                            decoration: const InputDecoration(
                              hintText: 'Nombre del cuadrante creado',
                              labelText: 'Nombre del Cuadrante',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            ),
                            maxLines: 1,
                            maxLength: 20,
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
                                hintText: state.inicialDate
                                    .toIso8601String()
                                    .substring(0, 10),
                                widget: IconButton(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: state.inicialDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                      locale: const Locale('es', 'ES'),
                                      helpText: 'Selecciona la fecha de inicio',
                                    );
                                    if (date != null) {
                                      notifier.setInicialDate(date);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    key: state.firstTime
                                        ? tutorialController.keyButton
                                        : key,
                                  ),
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
                                hintText: state.endDate
                                    .toIso8601String()
                                    .substring(0, 10),
                                widget: IconButton(
                                  key: state.firstTime
                                      ? tutorialController.keyButton2
                                      : key,
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: state.endDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                      locale: const Locale('es', 'ES'),
                                      helpText: 'Selecciona la fecha de fin',
                                    );
                                    if (date != null) {
                                      notifier.setEndDate(date);
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.calendar_today_outlined),
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
                      key:
                          state.firstTime ? tutorialController.keyButton3 : key,
                      padding: EdgeInsets.all(8.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5),
                        itemCount: state.list.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                color: HexColor(state.list[index].color!),
                                border: Border.all(width: 0.8),
                                borderRadius: BorderRadius.circular(5.r),
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
                                  padding: EdgeInsets.all(2.h),
                                  child: Text(
                                    state.list[index].title!,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor(state.list[index].color!)
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 2.h),
                                    child: Icon(
                                      shadows: const <Shadow>[
                                        BoxShadow(
                                          color: Colors.redAccent,
                                          blurRadius: 15.0,
                                          // offset: Offset(1, 0)
                                        ),
                                        BoxShadow(
                                          blurRadius: 12.0,
                                          color: Colors.red,
                                        ),
                                      ],
                                      Icons.delete_forever,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                    ),
                                  ),
                                  onTap: () async {
                                    notifier.removeTurnoAt(index);
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
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await _showTurnoPicker(context, ref);
                },
                key: state.firstTime ? tutorialController.keyButton4 : key,
                child: const Icon(Icons.add),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showTurnoPicker(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(crearCuadranteProvider);
            final notifier = ref.read(crearCuadranteProvider.notifier);

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AlertDialog(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  content: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 15,
                      children: state.turnoType.map((turno) {
                        final color = HexColor(turno.color!);
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            backgroundColor: color,
                          ),
                          onPressed: () {
                            notifier.addTurno(turno);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            width: 50,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Text(
                                turno.description!,
                                style: TextStyle(
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.done,
                    color: Theme.of(context).primaryColorDark,
                    size: 30.0,
                  ),
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  alertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BeautifulAlertDialog();
      },
    );
  }

  showAlertLoadingDialog(BuildContext context) {
    final adcontroller = Get.find<AdsController>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final loading = ref.watch(crearCuadranteProvider).cuadranteLoading;

            return AlertDialog(
              title: const Text("Espera a que cargue el cuadrante"),
              content: const Text(
                "Cuando se haya cargado el cuadrante el boton se habilitara "
                "para llevarte a la pagina de calendario",
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          adcontroller.staticHomeAd.load();
                          Get.offAllNamed('/home');
                        },
                  child: loading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Calendario'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
