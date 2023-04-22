
import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../config/tutorial/tutorialCuadrantes.dart';

class CrearCuadranteController extends GetxController {
  TutorialController tutorialController = TutorialController();


  Rx<DateTime> inicialDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 365)).obs;
  // late Rxn<DateTime> endDate;

  RxList<TurnoType> list = <TurnoType>[].obs;
  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  var isSwitched = false.obs;

  RxBool cuadranteLoading = true.obs;

  RxBool firstTime = false.obs;

  @override
  void onInit() async {
    // inicialDate = Rxn(DateTime.now());
    // endDate = Rxn(DateTime.now().add(const Duration(days: 365)));

    if (MySharedPref.getTutoCuadranteFirst()) {
      firstTime.value = true;
      tutorialController.firstInstall('cuadrante');
    }

    fetchTurnosType();
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

  bool submit() {
    return list.length != 0 &&
        endDate.value.toString() != "" &&
        endDate.value.toString().isNotEmpty &&
        inicialDate.value.toString() != "" &&
        inicialDate.value.toString().isNotEmpty &&
        DateTime.parse(endDate.value.toString())
                .difference(DateTime.parse(inicialDate.value.toString()))
                .inDays >
            0;
  }

  Future cuadranteLoad() async {
    print(cuadranteLoading.value);
    print('Future cuadranteLoad()=======================1================ ${cuadranteLoading.value}');
    await Rotation(
        DateTime.parse(inicialDate.value.toString().substring(0, 10)),
        DateTime.parse(endDate.value.toString().substring(0, 10)));
    cuadranteLoading.value = false;
    print('Future cuadranteLoad()=======================2================  ${cuadranteLoading.value}');


  }

  Rotation(DateTime start, DateTime end) async {
    DateTime date;
    var x = 0;
    var difference = end.difference(start).inDays;

    for (int i = 0; i <= difference; i++) {
      date = start.add(Duration(days: i)).add(Duration(hours: 6));
      if (x >= list.length) {
        x = 0;
      }
      await DBHelper.db.addItem(
        CuadranteDay(
          dateTime: date,
          color: list[x].color,
          description: list[x].description,
          endHour: list[x].endHour,
          startHour: list[x].startHour,
          title: list[x].title,
        ),
      );
      x = x + 1;
    }
  }

  Future<List<TurnoType>> fetchTurnosType() async {
    turnoType.value = await DBHelper.db.getTypeModels();
    return turnoType;
  }

  void addYear() async {
    if (isSwitched.value == false) {
      await endDate.value!
          .add(const Duration(days: 365))
          .subtract(const Duration(hours: 2))
          .toIso8601String()
          .substring(0, 10);
      endDate.refresh();

      print('isswitched true');
      print(endDate.value);
    } else {
      await endDate.value == DateTime.now();
      endDate.refresh();

      print('isswitched false');
      print(endDate.value);
    }
  }



  Future<void> showPopUp(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AlertDialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                content: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runSpacing: 15,
                    children: <Widget>[
                      ...turnoType.map((m) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.r),
                            ),
                            backgroundColor: HexColor(m.color!),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            width: 50,
                            child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  m.description!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color,
                                  ),
                                )),
                          ),
                          onPressed: () {
                            list.value.add(m);
                            list.refresh();
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.done,
                  color: Theme.of(context).primaryColorDark,
                  size: 30.0,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }











}
