import 'dart:io';

import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/modules/crearCuadrante/widgets/beautifulAlertDialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/controllers/ads_provider.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../home/providers/calendar_providers.dart';
import '../providers/crear_cuadrante_provider.dart';
import 'add_cuadrante_view.dart';

class CrearCuadranteView extends ConsumerWidget {
  const CrearCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double qaButtonHeight = 100.h;
    double qaButtonWidth = 120.w;
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();
          Get.offAllNamed('/home');
        }
        return false;
      },
      child: Scaffold(
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
              ProviderScope.containerOf(context, listen: false)
                  .read(adsProvider.notifier)
                  .ensureHomeBanner();
              Get.offAllNamed('/home');
            },
          ),
          title: Text(
            'Cuadrantes',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: controller.submit()
          //         ? () async {
          //             //Todo carcgar primera pagina de calendario
          //
          //             showAlertLoadingDialog(context);
          //             await controller.cuadranteLoad();
          //           }
          //         : () => alertDialog(context),
          //     icon: controller.submit()
          //         ? Icon(
          //             Icons.done,
          //             color: Colors.green,
          //             size: 24.sp,
          //           )
          //         : Icon(
          //             Icons.done_outline,
          //             color: PRIMARY_COLOR.withOpacity(0.4),
          //             size: 24.sp,
          //           ),
          //     key: controller.firstTime.value
          //         : key,
          //   )
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 25.h,
              ),
              Expanded(
                flex: 10,
                child: MaterialButton(
                  elevation: 10,
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                  height: qaButtonHeight,
                  minWidth: qaButtonWidth,
                  color: MyColors.cellSelectedColor,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text("Crear nuevo Cuadrante",
                        style: CustomTextStyle.textCuadranteMenu),
                  ),

                  onPressed: () {
                    ProviderScope.containerOf(context, listen: false)
                        .read(crearCuadranteProvider.notifier)
                        .resetForCreate();
                    // Get.toNamed('/notas', (r) => false);
                    Get.to(() => const AddCuadranteView()); //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               TaskListVIew(widget.time, widget.events)));
                  },
                  // splashColor: AAThemeData.buttonColor,
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              Expanded(
                flex: 80,
                child: MaterialButton(
                  elevation: 10,
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                  height: qaButtonHeight,
                  minWidth: qaButtonWidth,
                  color: MyColors.cellSelectedColor,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            Text("Mis Cuadrantes",
                                style: CustomTextStyle.textCuadranteMenu),
                            const Spacer(),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                MyCustomDialog.myConfirmDialogBody(
                                    circularColor: Colors.redAccent,
                                    context: context,
                                    title: 'Eliminar TODOS',
                                    desc: 'Si aceptas y pulsas ok eliminaras,'
                                        '\ntodos los cuadrantes creados.'
                                        '\nY LOS TURNOS AÑADIDOS MANUALMENTE',
                                    onTapOK: () {
                                      ref
                                          .read(crearCuadranteProvider.notifier)
                                          .deleteAllCuadrante();
                                      Navigator.of(context).pop();
                                    },
                                    onTapCancel: () =>
                                        Navigator.of(context).pop());
                              },
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                size: 30.sp,
                                color: Colors.red,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Consumer(builder: (context, ref, child) {
                          return Container(
                            height: 200.h,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: ref
                                  .watch(crearCuadranteProvider)
                                  .cuadrantesNameList
                                  .length,
                              itemBuilder: (context, index) {
                                final name = ref
                                    .watch(crearCuadranteProvider)
                                    .cuadrantesNameList[index];

                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.h),
                                  child: Card(
                                    color: MyColors.menuCardBackgroundDark,
                                    elevation: 1,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10.w),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: MyColors.textColor,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                        Spacer(),
                                        Consumer(
                                          builder: (context, ref, child) {
                                            return IconButton(
                                              onPressed: () async {
                                                final preparado = await ref
                                                    .read(crearCuadranteProvider
                                                        .notifier)
                                                    .prepareEdit(name);

                                                if (!context.mounted) return;

                                                if (!preparado) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'No se han encontrado datos para este cuadrante.',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                Get.to(() =>
                                                    const AddCuadranteView());
                                              },
                                              icon: const Icon(
                                                Icons.edit_calendar,
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          onPressed: () => ref
                                              .read(crearCuadranteProvider
                                                  .notifier)
                                              .deleteCuadrante(name),
                                          icon: const Icon(
                                              Icons.delete_forever_outlined),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              //   RadioListTile(
                              //     title: Text(controller.languages[index].name),
                              //     value: controller.languages[index].languageCode,
                              //     groupValue: controller.selectedLanguage.value.languageCode,
                              //     onChanged: (value) {
                              //       log('pressed: ${controller.languages[index].languageCode}');
                              //       controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
                              //     },
                              //   ),
                              // ),
                              // children: [
                              //   ...List.generate(
                              //     controller.languages.length,
                              //     (index) => RadioListTile(
                              //       title: Text(controller.languages[index].name),
                              //       value: controller.languages[index].languageCode,
                              //       groupValue: controller.selectedLanguage.value.languageCode,
                              //       onChanged: (value) {
                              //         controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
                              //       },
                              //     ),
                              //     // ListTile(leading: ,trailing: ,)
                              //   ),
                              // ],
                            ),
                          );
                        })
                      ],
                    ),
                  ),

                  onPressed: () {
                    // Get.toNamed('/notas', (r) => false);
                    // Navigator.pushNamedAndRemoveUntil(context, "/notas", (r) => false);
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               TaskListVIew(widget.time, widget.events)));
                  },
                  // splashColor: AAThemeData.buttonColor,
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  alertDialog(BuildContext context) {
    showAnimatedDialog(
      animationType: DialogTransitionType.slideFromRightFade,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const BeautifulAlertDialog();
      },
    );
  }

  showAlertLoadingDialog(BuildContext context) {
    Widget okButton = Consumer(builder: (context, ref, child) {
      return TextButton(
        child: ref.watch(crearCuadranteProvider).cuadranteLoading
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(),
              )
            : const Text('Calendario'),
        onPressed: () async {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();

          Get.offAllNamed('/home');
        },
      );
    });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Espera a que cargue el cuadrante"),
      content: const Text(
          "Cuando se haya cargado el cuadrante el boton se habilitara para llevarte a la pagina de calendario"),
      actions: [
        okButton,
      ],
    );
    showAnimatedDialog(
      context: context,
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
