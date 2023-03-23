import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/convert_time.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoType.dart';

class CrearTurnoController extends GetxController {
  var logger = Logger();

  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  RxString title = "".obs;

  CalendarController calendarController = CalendarController();

  get getTitle => title.value;
  void setTitle(String titleString) => title.value = titleString;
  var titleValueController = TextEditingController();

  late RxString startDate;
  late RxString endDate;

  RxString description = "".obs;
  get getDescription => description.value;
  void setDescription(String descriptionString) =>
      description.value = descriptionString;
  var descriptionValueController = TextEditingController();

  var selectedTime = TimeOfDay.now().obs;

  Rx<Color> turnoColor = Rx<Color>(Colors.orangeAccent);

  @override
  void onInit() {
    fetchEventsType();
    startDate = DateTime.now().formatDate.obs;
    endDate = DateTime.now().add(const Duration(hours: 1)).formatDate.obs;
    titleValueController = TextEditingController();
    descriptionValueController = TextEditingController();
    logger.i(turnoType.value.length);

    super.onInit();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  // }
  //
  // @override
  // void onClose() {
  //   super.onClose();
  // }

  Future<List<TurnoType>> fetchEventsType() async {
    turnoType.value = await DBHelper.db.getTypeModels();
    return turnoType;
  }

  Future<List<TurnoType>> deleteEventsType(index) async {
    await DBHelper.db.deleteTypeId(turnoType[index].id!);
    await fetchEventsType();
    return turnoType;
  }

  addTurno() async {
    TurnoType eventType = TurnoType(
      title: title.value,
      description: description.value,
      startHour: startDate.value,
      endHour: endDate.value,
      color: turnoColor.value.value.toRadixString(16),
    );
    await DBHelper.db.addTypeModel(eventType);
    await calendarController.fetchTurno();
    fetchEventsType();
  }

  updateDrawerColor(Color newColor) {
    turnoColor.value = newColor;
    update();
  }

  Future<bool> colorPickerDialog(BuildContext context) async {
    return ColorPicker(
      color: turnoColor.value,
      onColorChanged: (Color color) {
        updateDrawerColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 5.r,
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
}
