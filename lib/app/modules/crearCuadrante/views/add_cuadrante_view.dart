import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/modules/CrearTurno/views/widgets/input_field.dart';
import 'package:calendario2/app/modules/crearCuadrante/widgets/beautifulAlertDialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dp;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../config/util/app_icons.dart';
import '../controllers/crear_cuadrante_controller.dart';

class AddCuadranteView extends GetView<CrearCuadranteController> {
  const AddCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();
    return Obx(
      () {
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
                onPressed: controller.submit()
                    ? () async {
                  if (controller.cuadranteNameString.isEmpty) {
                    MyCustomDialog.alertaError('Es necesario añadir nombre al cuadrante');
                    return;
                  }
                        //Todo carcgar primera pagina de calendario
                        showAlertLoadingDialog(context);
                        await controller.cuadranteLoad();
                      }
                    : () => alertDialog(context),
                icon: controller.submit()
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
                key: controller.firstTime.value
                    ? controller.tutorialController.keyButton5
                    : key,
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
                          icon: const AppIcon(AppIcons.informacion, color: Colors.green),
                          tooltip: '',
                          onPressed: () {
                            controller.firstTime.value = true;

                            controller.tutorialController
                                .showTutorial(context, 'cuadrante');
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
                        onChanged: (value) => controller.setCuadranteName(value),
                        decoration: const InputDecoration(
                          hintText: 'Nombre del cuadrante creado',
                          labelText: 'Nombre del Cuadrante',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15))),
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
                            hintText: controller.inicialDate.value
                                .toIso8601String()
                                .substring(0, 10),
                            widget: IconButton(
                              onPressed: () {
                                dp.DatePicker.showDatePicker(context,
                                    theme: dp.DatePickerTheme(
                                        cancelStyle: TextStyle(
                                            color: Colors.redAccent.shade200,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        doneStyle: TextStyle(
                                            color: MyColors.textColorPrimary,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        itemStyle: TextStyle(
                                            color: MyColors.textColorPrimary,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        backgroundColor: MyColors.backgroundLowAccent),
                                    showTitleActions: true,
                                    minTime: DateTime(2020),
                                    maxTime: DateTime(2050), onChanged: (date) {
                                  controller.inicialDate.value = date;
                                }, onConfirm: (date) {
                                  controller.inicialDate.value = date;
                                },
                                    currentTime: DateTime.now(),
                                    locale: dp.LocaleType.es);
                              },
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                key: controller.firstTime.value
                                    ? controller.tutorialController.keyButton
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
                            hintText: controller.endDate.value
                                .toIso8601String()
                                .substring(0, 10),
                            widget: IconButton(
                              key: controller.firstTime.value
                                  ? controller.tutorialController.keyButton2
                                  : key,
                              onPressed: () {
                                dp.DatePicker.showDatePicker(
                                    theme: dp.DatePickerTheme(
                                        cancelStyle: TextStyle(
                                            color: Colors.redAccent.shade200,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        doneStyle: TextStyle(
                                            color: MyColors.textColorPrimary,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        itemStyle: TextStyle(
                                            color: MyColors.textColorPrimary,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        backgroundColor: MyColors.backgroundLowAccent),
                                    context,
                                    showTitleActions: true,
                                    minTime: DateTime(2020),
                                    maxTime: DateTime(2050), onChanged: (date) {
                                  controller.endDate.value = date;
                                }, onConfirm: (date) {
                                  controller.endDate.value = date;
                                },
                                    currentTime: DateTime.now(),
                                    locale: dp.LocaleType.es);
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
                  key: controller.firstTime.value
                      ? controller.tutorialController.keyButton3
                      : key,
                  padding: EdgeInsets.all(8.w),
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
                                controller.list[index].title!,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor(controller.list[index].color!).computeLuminance() > 0.5
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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await controller.showPopUp(context);
            },
            key: controller.firstTime.value
                ? controller.tutorialController.keyButton4
                : key,
            child: const Icon(Icons.add),
          ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
