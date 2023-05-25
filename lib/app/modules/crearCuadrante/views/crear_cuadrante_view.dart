import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/modules/crearCuadrante/widgets/beautifulAlertDialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../controllers/crear_cuadrante_controller.dart';
import 'add_cuadrante_view.dart';

class CrearCuadranteView extends GetView<CrearCuadranteController> {
  const CrearCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double qaButtonHeight = 100.h;
    double qaButtonWidth = 120.w;
    final adcontroller = Get.find<AdsController>();
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
        //         ? controller.tutorialController.keyButton5
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
                  Future.delayed(const Duration(milliseconds: 300), () {
                    // MySharedPref.setTutoCuadranteFirst(true);
                    if (MySharedPref.getTutoCuadranteFirst()) {
                      controller.firstTime.value = true;
                      controller.tutorialController.firstInstall('cuadrante');
                    }
                  });
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
                                    controller.deleteAllCuadrante();
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
                      Obx(() {
                        return Container(
                          height: 200.h,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: controller.cuadrantesNameList.value.length,
                            itemBuilder: (context, index) {
                              final name = controller.cuadrantesNameList.value[index];

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.h),
                                child: Card(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10.w),
                                      Text(
                                        name,
                                        style: CustomTextStyle.rowButomText,
                                      ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () =>
                                            controller.editarCuadrante(name),
                                        icon: const Icon(
                                            Icons.edit_calendar),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            controller.deleteCuadrante(name),
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
    final adcontroller = Get.find<AdsController>();

    Widget okButton = Obx(() {
      return TextButton(
        child: controller.cuadranteLoading.value
            ? const SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        )
            : const Text('Calendario'),
        onPressed: () async {
          adcontroller.staticHomeAd.load();

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
