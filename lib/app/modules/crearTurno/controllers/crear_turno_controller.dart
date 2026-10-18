import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:calendario2/config/util/validation_utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoType.dart';

class CrearTurnoController extends GetxController {
  RxList<TurnoType> turnoTypeList = <TurnoType>[].obs;
  // Rx<TurnoType> turnoType = i.obs;
  final turnoType = Rxn<TurnoType>();


  RxString title = "".obs;
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

  Rx<Color> turnoColor = Rx<Color>(Colors.orangeAccent);

  // var selectedTime = TimeOfDay.now().obs;

  @override
  void onInit() {
    fetchEventsType();
    startDate = DateTime.now().formatDateTime24H.obs;
    endDate =
        DateTime.now().add(const Duration(hours: 1)).formatDateTime24H.obs;
    titleValueController = TextEditingController();
    descriptionValueController = TextEditingController();
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

  bool isValidResponse() {
    return ValidationUtils.isValidString(description.value);
  }

  Future<List<TurnoType>> fetchEventsType() async {
    turnoTypeList.value = await CalendarioDB.db.getTypeModels();
    return turnoTypeList;
  }

  Future<List<TurnoType>> deleteEventsType(index) async {
    await CalendarioDB.db.deleteTypeId(turnoTypeList[index].id!);
    await fetchEventsType();
    return turnoTypeList;
  }

  addTurno() async {
    TurnoType eventType = TurnoType(
      title: title.value,
      description: description.value,
      startHour: startDate.value,
      endHour: endDate.value,
      color: turnoColor.value.value.toRadixString(16),
    );
    await CalendarioDB.db.addTypeModel(eventType);
    await fetchEventsType();
  }

  updateDrawerColor(Color newColor) {
    turnoColor.value = newColor;
    eturnoColor.value = newColor;
    update();
  }

  Future<bool> colorPickerDialog(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);

    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Cerrar selector de color',
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return Theme(
              data: theme,
              child: Localizations.override(
                context: dialogContext,
                locale: locale,
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: Dialog(
                  backgroundColor: theme.cardColor,
                  surfaceTintColor: Colors.transparent,
                  child: SizedBox(
                    width: 320,
                    height: 560,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: ColorPicker(
                              color: turnoColor.value,
                              onColorChanged: updateDrawerColor,
                              width: 40,
                              height: 40,
                              borderRadius: 5.r,
                              spacing: 5,
                              runSpacing: 5,
                              wheelDiameter: 155,
                              heading: const Text('Selecciona color'),
                              subheading: const Text('Selecciona tono color'),
                              showMaterialName: false,
                              showColorName: false,
                              showColorCode: false,
                              copyPasteBehavior:
                                  const ColorPickerCopyPasteBehavior(
                                longPressMenu: false,
                              ),
                              pickersEnabled: const <ColorPickerType, bool>{
                                ColorPickerType.both: false,
                                ColorPickerType.primary: true,
                                ColorPickerType.accent: true,
                                ColorPickerType.bw: false,
                                ColorPickerType.custom: true,
                                ColorPickerType.wheel: false,
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  ///Edit turno

  int? id;
  RxString etitle = "".obs;
  get egetTitle => etitle.value;
  void esetTitle(String titleString) => etitle.value = titleString;
  var etitleValueController = TextEditingController();

  RxString estartDate = ''.obs;
  RxString eendDate = ''.obs;

  RxString edescription = "".obs;
  get egetDescription => description.value;
  void esetDescription(String descriptionString) =>
      edescription.value = descriptionString;
  var edescriptionValueController = TextEditingController();

  Rx<Color> eturnoColor = Rx<Color>(Colors.orangeAccent);

  bool isValidEditResponse() {
    return ValidationUtils.isValidString(edescription.value);
  }

  Future<void> editEventsType(int id) async {
    turnoType.value = await CalendarioDB.db.fetchTurnoType(id);
  }

  updateEditScreen() {
    id = turnoType.value!.id;
    etitle.value = turnoType.value!.title!;
    etitleValueController.text = turnoType.value!.title!;
    edescription.value = turnoType.value!.description!;
    edescriptionValueController.text = turnoType.value!.description!;
    estartDate.value = turnoType.value!.startHour!;
    eendDate.value = turnoType.value!.endHour!;
    eturnoColor.value = HexColor(turnoType.value!.color!);
  }

  Future<void> updateTurno() async {
    await CalendarioDB.db.updateTurno(
      TurnoType(
        id: id,
        title: etitle.value,
        description: edescription.value,
        startHour: estartDate.value,
        endHour: eendDate.value,
        color: eturnoColor.value.value.toRadixString(16),
      ),
    );
  }
}
