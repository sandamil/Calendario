import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/Notas/controllers/notas_controller.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/warn-select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class AddNotasView extends GetView<NotasController> {



  const AddNotasView( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // NotasController controller = NotasController();

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.0,
            // for elevation
            title: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
//          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
              width: controller.headerShouldHide ? 0 : 200,
              child: Text(
                'Añadir Nota',
                style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme
                        .of(context)
                        .textTheme
                        .titleLarge!
                        .color),
                overflow: TextOverflow.clip,
                softWrap: false,
              ),
            ),
            leading: IconButton(
                icon: Icon(Icons.clear, color: Theme
                    .of(context)
                    .primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check, color: Theme
                    .of(context)
                    .primaryColor),
                padding: EdgeInsets.only(right: 3),
                onPressed: () async {
                  controller.addTravelEvent();

                  await TurnoDbProvider.instance.init().then((db) async {

                    Cuadrante _item = await TurnoDbProvider.instance.select(

                        await TurnoDbProvider.instance.insert(
                          Cuadrante(
                              title: controller.title.text,
                              site: controller.site.text,
                              notes: controller.notes.text,
                              isImportant: controller.isImportant,
                              startTimeMilliseconds:
                              controller.startTime.millisecondsSinceEpoch,
                              endTimeMilliseconds:
                              controller.endTime.millisecondsSinceEpoch,
                              time: Jiffy().format('yyyy-MM-dd h:mm:ss a')),
                        ));
                    controller.warnList.forEach((e) {
                      if (e['select']) {
                        // push.setOneTime(_item.id * 10 + e['id'], title, notes,
                        //     e['time'](_startTime));
                      }
                    });
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed('/home');
                    // Toast.toast(context, msg: "¡Añadida! ");
                    TurnoDbProvider.instance.close();
                  });
                },
              )
            ],
          ),
          body: Center(
            child:


            Form(
                // key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: _buildGeneralFormField(
                            controller.title, 'Titulo del evento', 1),
                        // key: keyButton13
                    ),
                    Column(
                      // key: keyButton14,
                      children: <Widget>[
                        Container(
                          child: _buildGeneralColumn(context, 'Hora de inicio',
                              '${Jiffy(controller.startTime).yMd} ${Jiffy(controller.startTime)
                                  .Hm}', () {
                                //     dp.DatePicker.showDateTimePicker(context,
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
                                //         // locale: LocaleType.es
                                //     );
                              }),
                        ),
                        Container(
                          child: _buildGeneralColumn(context, 'Hora final',
                              '${Jiffy(controller.endTime).yMd} ${Jiffy(controller.endTime)
                                  .Hm}', () {
                                // dp.DatePicker.showDateTimePicker(context,
                                //
                                //     showTitleActions: true,
                                //     onChanged: (DateTime date) {},
                                //     onConfirm: (DateTime date) {
                                //       if (_startTime.millisecondsSinceEpoch <=
                                //           date.millisecondsSinceEpoch) {
                                //         setState(() {
                                //           _endTime = date;
                                //         });
                                //       }
                                //     }, currentTime: _endTime,
                                //     // locale: LocaleType.es
                                // );
                              }),
                        ),
                      ],
                    ),

                    _buildLineBetween(),
                    // Container(
                    //   // key: keyButton15,
                    //   child: _buildGeneralColumn(
                    //       context, 'Recordatorio', NotasController.warnDefaultt, () async {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               WarnView(controller.noWarn, controller.warnList, (bool value) {
                    //
                    //                   controller.noWarn = value;
                    //                controller.update();
                    //               }, (int item, bool value) {
                    //
                    //                 controller.warnList[item]['select'] = value;
                    //                   controller.update();
                    //
                    //               }, (String warn) {
                    //                String warnDefaultt = 'Al principio';
                    //
                    //                warnDefaultt = warn;
                    //                   controller.update();
                    //
                    //               })),
                    //     );
                    //   }),
                    // ),
                    _buildLineBetween(),
                    TextButton(
                        // key: keyButton16,
                        onPressed: controller.markImportantAsDirty,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Marcar como importante',
                                style: TextStyle(color: Colors.blue,
                                    fontSize: 14.sp),

                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    controller.isImportant ? Icons.flag : Icons
                                        .outlined_flag,
                                    color: controller.isImportant ? Colors.red : Colors
                                        .black,
                                  )
                                ],
                              )
                            ])),
                    _buildLineBetween(),
                    Column(
                      // key: keyButton17,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          child: _buildGeneralFormField(controller.site, 'Ubicación', 2),
                        ), SizedBox(
                          height: 6,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          child: _buildGeneralFormField(
                              controller.notes, 'Observaciones', 8),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8.0, top: 16),

                      child: Row(
                        children: <Widget>[
                          Text(
                            "Pulsa aqui si necesitas ayuda para crear notas.",
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info,
                                color: Colors.redAccent),
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
          ),
        );

  }
  TextFormField _buildGeneralFormField(
      TextEditingController value, String hint, int lines) {
    final double _radiusNum = 10;
    return TextFormField(
      controller: value,
      decoration: InputDecoration(
        filled: true,
        contentPadding: EdgeInsets.only(left: 20, top: 20),
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(_radiusNum),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(_radiusNum),
            ),
            borderSide: BorderSide(
              color: Colors.green,
              width: 2,
            )),
        hintText: hint,
      ),
      maxLines: lines,
    );
  }

  Widget _buildLineBetween() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: Container(
          width: 320, //max-width is 240
          height: 1,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildGeneralColumn(
      BuildContext context,
      String title,
      var value,
      Function onPressed,
      ) {
    return TextButton(
        onPressed: onPressed(),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: Colors.blue,
                    fontSize: 14.sp),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    value,
                    style: TextStyle(color: Colors.blue,
                        fontSize: 14.sp),

                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                  )
                ],
              )
            ]));
  }


}
