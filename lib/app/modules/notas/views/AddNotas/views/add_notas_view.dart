import 'package:calendario2/app/modules/home/widgets/calendar/widget/warn-select.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalFormField.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalLineBetween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as dp;

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../controllers/add_notas_controller.dart';

class AddNotasView extends GetView<AddNotasController> {
  const AddNotasView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    // NotasController controller = NotasController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
//          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
          width: controller.headerShouldHide ? 0 : 200,
          child: Text(
            'Añadir Nota',
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                color: theme.primaryColor),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
            padding: const EdgeInsets.only(right: 3),
            onPressed: () async {
              controller.addTravelEvent();
              await controller.addEvent();
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/notas');
            },
          )
        ],
      ),
      body: Obx(() {
        return Center(
          child: Form(
            // key: _formKey,
              child: ListView(
                children: <Widget>[
                  GeneralLineBetween(),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: GeneralFormField(
                        controller.title, 'Titulo del evento', 1),
                    // key: keyButton13
                  ),
                  GeneralLineBetween(),

                  Column(
                    // key: keyButton14,
                    children: <Widget>[
                      Container(
                          child: TextButton(
                              onPressed: () {
                                dp.DatePicker.showDateTimePicker(
                                    Get.context!,

                                    showTitleActions: true,
                                    onChanged: (DateTime date) {
                                      if (controller
                                          .endTime.value.millisecondsSinceEpoch <
                                          date.millisecondsSinceEpoch) {
                                        controller.endTime.value = date;
                                      }
                                      controller.startTime.value = date;
                                    },
                                    onConfirm: (DateTime date) {},
                                    currentTime: controller.startTime.value,
                                    locale: dp.LocaleType.es
                                );
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Hora de inicio',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 14.sp),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${Jiffy(controller.startTime.value).yMd} ${Jiffy(controller.startTime.value).Hm}',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 14.sp),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14.sp,
                                        )
                                      ],
                                    )
                                  ]))),
                      Container(
                        child: TextButton(
                            onPressed: () {
                              dp.DatePicker.showDateTimePicker(
                                  Get.context!,

                                  showTitleActions: true,
                                  onChanged: (DateTime date) {
                                    if (controller
                                        .endTime.value.millisecondsSinceEpoch <=
                                        date.millisecondsSinceEpoch) {
                                      controller.endTime.value = date;
                                    }
                                  },
                                  onConfirm: (DateTime date) {},
                                  currentTime: controller.endTime.value,
                                  locale: dp.LocaleType.es
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Hora final',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 14.sp),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${Jiffy(controller.endTime.value).yMd} ${Jiffy(controller.endTime.value).Hm}',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 14.sp),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14.sp,
                                      )
                                    ],
                                  )
                                ])),
                      ),
                    ],
                  ),

                  GeneralLineBetween(),
                  TextButton(
                      onPressed: ()async{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WarnView(controller.noWarn, controller.warnList, (bool value) {

                                    controller.noWarn = value;
                                    controller.update();
                                  }, (int item, bool value) {

                                    controller.warnList[item]['select'] = value;
                                    controller.update();

                                  }, (String warn) {
                                    String warnDefaultt = 'Al principio';

                                    warnDefaultt = warn;
                                    controller.update();

                                  })),
                        );

                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Recordatorio',
                              style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AddNotasController.warnDefaultt,
                                  style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.sp,
                                )
                              ],
                            )
                          ])),

                  GeneralLineBetween(),
                  TextButton(
                    // key: keyButton16,
                      onPressed: controller.markImportantAsDirty,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Marcar como importante',
                              style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  controller.isImportant.value
                                      ? Icons.flag
                                      : Icons.outlined_flag,
                                  color: controller.isImportant.value
                                      ? Colors.red
                                      : Colors.black,
                                )
                              ],
                            )
                          ])),
                  GeneralLineBetween(),
                  Column(
                    // key: keyButton17,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child:
                        GeneralFormField(controller.site, 'Ubicación', 2),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: GeneralFormField(
                            controller.notes, 'Observaciones', 8),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 8.0, top: 16),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Pulsa aqui si necesitas ayuda para crear notas.",
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info, color: Colors.redAccent),
                          tooltip: '',
                          onPressed: () {
                            // showTutorial(context: context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }




}