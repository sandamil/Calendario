import 'package:calendario2/app/components/custom_snackbar.dart';
import 'package:calendario2/app/modules/Notas/views/AddNotas/controllers/add_notas_controller.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlarmasPage extends GetView<AddNotasController> {
  const AlarmasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: theme.primaryColor),
              onPressed: () async {
                controller.noRemind.value
                    ? await controller.setAlarmTime()
                    : CustomSnackBar.showCustomSnackBar(
                        title: 'No has añadido Alarma',
                        message:
                            ' Vuelve a entrar si queires añadir recordatorio');
                Navigator.of(context).pop();
              }),
        ),
        body: Container(
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwitchListTile(
                  title: controller.noRemind.value
                      ? const Text('Recordar')
                      : const Text('No recordar'),
                  value: controller.noRemind.value,
                  onChanged: (bool value) {
                    controller.noRemind.value = value;
                    controller.update();
                    if (!value) {
                      controller.alarmaActivada.value =
                          controller.sinRecordatorio;
                      controller.alPrincipio(false);
                      controller.item2(false);
                      controller.item3(false);
                      controller.item4(false);
                      controller.item5(false);
                    }
                  },
                ),
                controller.noRemind.value
                    ? Obx(
                        () {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 40),
                            child: Column(
                              children: [
                                //Checkboxes will go here
                                CheckboxListTile(
                                  title: Text(controller.alPrincipioString),
                                  value: controller.alPrincipio.value,
                                  onChanged: (value) {
                                    controller.alPrincipio.value = value!;
                                    controller.alarmaActivada.value =
                                        controller.alPrincipioString;
                                    controller.subtractTime.value =
                                        controller.alPrincipioInt;
                                  },
                                ),
                                CheckboxListTile(
                                  title:
                                      const Text('5 minutos de anticipación'),
                                  value: controller.item2.value,
                                  onChanged: (value) {
                                    controller.item2.value = value!;
                                  },
                                ),
                                CheckboxListTile(
                                  title:
                                      const Text('30 minutos de anticipación'),
                                  value: controller.item3.value,
                                  onChanged: (value) {
                                    controller.item3.value = value!;
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('1 hora de anticipación'),
                                  value: controller.item4.value,
                                  onChanged: (value) {
                                    controller.item4.value = value!;
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text('1 día de antelación'),
                                  value: controller.item5.value,
                                  onChanged: (value) {
                                    controller.item5.value = value!;
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2),],
                      ),
                    ),
                    SizedBox(width: 60.w,),
                    DropdownButton<String>(
                        hint: const Text('Duracion'),
                        value: controller.selectedValue,
                        onChanged: (newValue) {
                          controller.onSelected(newValue!);
                        },
                        elevation: 0,
                        items: const [
                          DropdownMenuItem(
                            value: 'Minutos',
                            child: Text("Minutos"),
                          ),
                          DropdownMenuItem(
                            child: Text("Horas"),
                            value: 'Horas',
                          ),
                          DropdownMenuItem(
                            child: Text("Dias"),
                            value: 'Dias',
                          ),
                        ]),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
