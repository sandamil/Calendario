import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/Notas/controllers/notas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class AddNotasView extends GetView {



  const AddNotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetX<NotasController>(
      init: NotasController(),
      builder: (controller) {

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
                              title: controller.title,
                              site: controller.site,
                              notes: controller.notes,
                              isImportant: controller.isImportant,
                              startTimeMilliseconds:
                              controller.startTime.millisecondsSinceEpoch,
                              endTimeMilliseconds:
                              controller.endTime.millisecondsSinceEpoch,
                              time: Jiffy().format('yyyy-MM-dd h:mm:ss a')),
                        ));
                    _warnList.forEach((e) {
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
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: _buildGeneralFormField(
                            _title, 'Titulo del evento', 1), key: keyButton13
                    ),
                    Column(key: keyButton14,
                      children: <Widget>[
                        Container(
                          child: _buildGeneralColumn(context, 'Hora de inicio',
                              '${Jiffy(_startTime).yMd} ${Jiffy(_startTime)
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
                              '${Jiffy(_endTime).yMd} ${Jiffy(_endTime)
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
                    Container(key: keyButton15,
                      child: _buildGeneralColumn(
                          context, 'Recordatorio', _warn, () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WarnView(_noWarn, _warnList, (bool value) {
                                    setState(() {
                                      _noWarn = value;
                                    });
                                  }, (int item, bool value) {
                                    setState(() {
                                      _warnList[item]['select'] = value;
                                    });
                                  }, (String warn) {
                                    setState(() {
                                      _warn = warn;
                                    });
                                  })),
                        );
                      }),
                    ),
                    _buildLineBetween(),
                    TextButton(key: keyButton16,
                        onPressed: markImportantAsDirty,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Marcar como importante',
                                style: TextStyle(color: Colors.blue,
                                    fontSize: 4 * SizeConfig.textMultiplierW),

                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    isImportant ? Icons.flag : Icons
                                        .outlined_flag,
                                    color: isImportant ? Colors.red : Colors
                                        .black,
                                  )
                                ],
                              )
                            ])),
                    _buildLineBetween(),
                    Column(key: keyButton17,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          child: _buildGeneralFormField(_site, 'Ubicación', 2),
                        ), SizedBox(
                          height: 6,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          child: _buildGeneralFormField(
                              _notes, 'Observaciones', 8),
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
                              fontSize: 3 * SizeConfig.textMultiplierW,
                            ),
                          ),
                          IconButton(
                            icon: Icon(FontAwesomeIcons.infoCircle,
                                color: Colors.redAccent),
                            tooltip: '',
                            onPressed: () {
                              showTutorial(context: context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}
