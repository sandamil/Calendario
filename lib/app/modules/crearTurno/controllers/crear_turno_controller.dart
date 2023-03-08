import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoType.dart';

class CrearTurnoController extends GetxController {
  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  final startcontroller = TextEditingController();
  final endcontroller = TextEditingController();
  final titlecontroller = TextEditingController();
  final descriptioncontroller = TextEditingController();

  DateFormat format = DateFormat.Hm();

  Color color = Colors.orangeAccent;

  @override
  void onInit() {
    fetchEventsType();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<List<TurnoType>> fetchEventsType() async {
    turnoType.value = await TurnoDbProvider.instance.getTypeModels();
    return turnoType;
  }

  Future<List<TurnoType>> deleteEventsType(index) async {
    await TurnoDbProvider.instance.deleteTypeId(turnoType[index].id!);
    await fetchEventsType();
    return turnoType;
  }

  addTurno() {
    submit()
        ? () async {
            TurnoType eventType = TurnoType(
              title: titlecontroller.text,
              description: descriptioncontroller.text,
              startHour: startcontroller.text,
              endHour: endcontroller.text,
              color: color.value.toRadixString(16),
            );
            await TurnoDbProvider.instance.addTypeModel(eventType);
          }
        : null;
  }

  bool submit() {
    return
//        _startcontroller.text != '' &&
//        _startcontroller != null &&
//        _endcontroller.text != '' &&
//        _endcontroller != null &&
//        _titlecontroller.text != '' &&
//        _titlecontroller != null &&
        descriptioncontroller?.text != '' && descriptioncontroller != null;
  }

  Future getColor() async {
    color = color;
    return color;
  }

  Future<void> showPopUp(BuildContext context, {colorCallback}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(2.0),
          backgroundColor: Colors.transparent,
          content: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: MaterialColorPicker(
                    colors: fullMaterialColors,
                    onColorChange: colorCallback,
                    circleSize: 60,
                    selectedColor: Colors.red,
                    elevation: 10,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.done),
              )
            ],
          ),
        );
      },
    );
  }
}

typedef colorCallback = void Function(Color);
