import 'package:calendario2/app/modules/home/widgets/calendar/widget/warn-select.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalColumn.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalFormField.dart';
import 'package:calendario2/app/modules/notas/views/widgets/generalLineBetween.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../controllers/edit_notas_controller.dart';

class EditNotasView extends GetView<EditNotasController> {
  const EditNotasView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0, // for elevation
        title: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
//          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
          width: controller.headerShouldHide ? 0 : 200,
          child: Text(
            'Editar Nota',
            style: TextStyle(
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Theme.of(context).primaryColor),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),iconSize: 28,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check,color: Theme.of(context).primaryColor),iconSize: 28,
            padding: EdgeInsets.only(right: 3),
            onPressed: () async {
              controller.editNote();

            },
          )
        ],
      ),
      body: Center(
        child: Form(
            // key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: GeneralFormField(controller.title, 'Titulo del evento', 1),
                ),
                GeneralColumn(context, 'Hora de inicio',
                    '${Jiffy(controller.startTime.value).yMd} ${Jiffy(controller.startTime.value).Hm}', () {
                      // dp.DatePicker.showDateTimePicker(context,
                      //
                      //     showTitleActions: true,
                      //     onChanged: (DateTime date) {},
                      //     onConfirm: (DateTime date) {
                      //   if (_endTime.millisecondsSinceEpoch <
                      //       date.millisecondsSinceEpoch) {
                      //     setState(() {
                      //       _endTime = date;
                      //     });
                      //   }
                      //   setState(() {
                      //     _startTime = date;
                      //   });
                      // }, currentTime: _startTime,
                      //     // locale: LocaleType.es
                      // );
                    }),
                GeneralColumn(context, 'Hora final',
                    '${Jiffy(controller.endTime.value).yMd} ${Jiffy(controller.endTime.value).Hm}', () {
                      // dp.DatePicker.showDateTimePicker(context,
                      //
                      //     showTitleActions: true,
                      //     onChanged: (DateTime date) {},
                      //     onConfirm: (DateTime date) {
                      //   if (_startTime.millisecondsSinceEpoch <=
                      //       date.millisecondsSinceEpoch) {
                      //     setState(() {
                      //       _endTime = date;
                      //     });
                      //   }
                      // }, currentTime: _endTime,
                      //     // locale: LocaleType.es
                      // );
                    }),
                GeneralLineBetween(),
                GeneralColumn(context, 'Recordatorio', controller.warn.value, () async {
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
                }),
                GeneralLineBetween(),
                TextButton(
                    onPressed: controller.markImportantAsDirty,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Marcar como importante',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                controller.isImportant.value ? Icons.flag : Icons.outlined_flag,
                                color: controller.isImportant.value ? Colors.red : Colors.black,
                              )
                            ],
                          )
                        ])),
                GeneralLineBetween(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: GeneralFormField(controller.site, 'Ubicación', 2),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: GeneralFormField(controller.notes, 'Observaciones', 8),
                ),
              ],
            )),
      ),
    );
  }
}
