import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoType.dart';

class CrearTurnoController extends GetxController {
  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  final startcontroller = TextEditingController();
  final endcontroller = TextEditingController();
  Rx<TextEditingController> titlecontroller = TextEditingController().obs;
  final descriptioncontroller = TextEditingController();

  DateFormat format = DateFormat.Hm();

  // Color? tempMainColor;
  // Color? mainColor = Colors.orangeAccent;
  Rx<Color> drawerColor = Rx<Color>(Colors.orangeAccent);

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
    print(turnoType.length);

    return turnoType;
  }

  Future<List<TurnoType>> deleteEventsType(index) async {
    await TurnoDbProvider.instance.deleteTypeId(turnoType[index].id!);
    await fetchEventsType();
    return turnoType;
  }

  addTurno() async {
    TurnoType eventType = TurnoType(
      title: titlecontroller.value.text,
      description: descriptioncontroller.text,
      startHour: startcontroller.text,
      endHour: endcontroller.text,
      color: drawerColor.value.value.toRadixString(16),
    );
    await TurnoDbProvider.instance.addTypeModel(eventType);
    fetchEventsType();
  }

  void setAb(String value) => titlecontroller.value = titlecontroller.value;

  updateDrawerColor(Color newColor) {
    drawerColor.value = newColor;
    update();
  }

  Future<bool> colorPickerDialog(BuildContext context) async {
    return ColorPicker(
      color: drawerColor.value,
      onColorChanged: (Color color) {
        updateDrawerColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: const Text(
        'Selecciona color',
      ),
      subheading: const Text(
        'Selecciona tono color',
      ),
      // recentColors: [mainColor],
      // showRecentColors: true,
      showMaterialName: false,
      showColorName: false,
      showColorCode: false,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: false,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

  // void openDialog() async {
  //   Get.defaultDialog(
  //     title: 'Choose Color',
  //     buttonColor: mainColor,
  //     cancelTextColor: Colors.black,
  //     confirmTextColor: Colors.white,
  //     textConfirm: 'Save',
  //     textCancel: 'Cancal',
  //     titleStyle: TextStyle(
  //         fontWeight: FontWeight.bold,
  //         fontFamily: 'Lato-Bold',
  //         fontSize: 17.sp,
  //         color: mainColor),
  //     content: SizedBox(
  //       height: 18.h,
  //       child: MaterialColorPicker(
  //         selectedColor: mainColor,
  //         allowShades: false,
  //         onMainColorChange: (color) {
  //           tempMainColor = color;
  //           update();
  //         },
  //       ),
  //     ),
  //     onCancel: () {
  //       Get.back();
  //     },
  //     onConfirm: () {
  //       mainColor = tempMainColor;
  //       Get.back();
  //       update();
  //     },
  //   );
  // }

  // Future<void> showPopUp(BuildContext context, {colorCallback}) {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         contentPadding: const EdgeInsets.all(2.0),
  //         backgroundColor: Colors.transparent,
  //         content: Column(
  //           children: <Widget>[
  //             Expanded(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(30.0),
  //                 ),
  //                 child: MaterialColorPicker(
  //                   colors: fullMaterialColors,
  //                   onColorChange: (color) {
  //                     tempMainColor = color;
  //                     update();
  //                   },
  //                   circleSize: 60,
  //                   selectedColor: Colors.red,
  //                   elevation: 10,
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(15.0),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 mainColor = tempMainColor;
  //                 Get.back();
  //                 update();
  //               },
  //               child: Icon(Icons.done),
  //             )
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

typedef colorCallback = void Function(Color);
