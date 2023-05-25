import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/app/modules/crearCuadrante/views/add_cuadrante_view.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CrearCuadranteController extends GetxController {
  TutorialController tutorialController = TutorialController();

  RxString cuadranteNameString = "".obs;

  RxList<String> cuadrantesNameList = <String>[].obs;

  get getCuadranteNameString => cuadranteNameString.value;

  void setCuadranteName(String cuadranteNameValue) =>
      cuadranteNameString.value = cuadranteNameValue;

  var cuadranteName = TextEditingController();

  Rx<DateTime> inicialDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 365)).obs;

  RxList<TurnoType> list = <TurnoType>[].obs;
  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  var isSwitched = false.obs;

  RxBool cuadranteLoading = true.obs;

  RxBool firstTime = false.obs;

  @override
  void onInit() async {
    cuadrantesNameList.value = MySharedPref.getStringList() ?? [];

    // inicialDate = Rxn(DateTime.now());
    // endDate = Rxn(DateTime.now().add(const Duration(days: 365)));

    // if (MySharedPref.getTutoCuadranteFirst()) {
    //   firstTime.value = true;
    //   tutorialController.firstInstall('cuadrante');
    // }

    fetchTurnosType();
    super.onInit();
  }

  @override
  void onReady() {


    super.onReady();
  }

  bool submit() {
    return list.isNotEmpty &&
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
    await Rotation(
      DateTime.parse(inicialDate.value.toString().substring(0, 10)),
      DateTime.parse(endDate.value.toString().substring(0, 10)),
    );
    cuadranteLoading.value = false;
  }

  Rotation(DateTime start, DateTime end) async {
    if (cuadrantesNameList.value.contains(cuadranteNameString.value)) {
      DateTime date;
      var x = 0;
      var difference = end.difference(start).inDays;

      for (int i = 0; i <= difference; i++) {
        date = start.add(Duration(days: i)).add(const Duration(hours: 6));
        if (x >= list.length) {
          x = 0;
        }
        await CalendarioDB.db.updateItem(
          CuadranteDay(
            dateTime: date,
            color: list[x].color,
            description: list[x].description,
            endHour: list[x].endHour,
            startHour: list[x].startHour,
            title: list[x].title,
            cuadranteName: cuadranteNameString.value,
          ),
        );
        x = x + 1;
      }
      return;
    }

    DateTime date;
    var x = 0;
    var difference = end.difference(start).inDays;

    for (int i = 0; i <= difference; i++) {
      date = start.add(Duration(days: i)).add(const Duration(hours: 6));
      if (x >= list.length) {
        x = 0;
      }
      await CalendarioDB.db.addItem(
        CuadranteDay(
          dateTime: date,
          color: list[x].color,
          description: list[x].description,
          endHour: list[x].endHour,
          startHour: list[x].startHour,
          title: list[x].title,
          cuadranteName: cuadranteNameString.toString(),
        ),
      );
      x = x + 1;
    }
    cuadrantesNameList.add(cuadranteNameString.value);
    MySharedPref.setCuadrantesList(cuadrantesNameList.value);
  }

  Future<List<TurnoType>> fetchTurnosType() async {
    turnoType.value = await CalendarioDB.db.getTypeModels();
    return turnoType;
  }

  editarCuadrante(String name) {
    Get.to(() =>  AddCuadranteView());
    cuadranteName.text = name;
    cuadranteNameString.value = name;
  }

  deleteCuadrante(cuadranteName) async {
    await CalendarioDB.db.deleteCuadrante(cuadranteName);
    cuadrantesNameList.remove(cuadranteName);
    MySharedPref.setCuadrantesList(cuadrantesNameList.value);
    cuadrantesNameList.value = MySharedPref.getStringList();
    update();
  }

  deleteAllCuadrante() async {
    await CalendarioDB.db.deleteALlCuadrante();
    cuadrantesNameList.clear();
    MySharedPref.deleteCuadrantesList();
  }

  void addYear() async {
    if (isSwitched.value == false) {
      endDate.value
          .add(const Duration(days: 365))
          .subtract(const Duration(hours: 2))
          .toIso8601String()
          .substring(0, 10);
      endDate.refresh();
    } else {
      endDate.value == DateTime.now();
      endDate.refresh();
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
                              borderRadius: BorderRadius.circular(5.r),
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
