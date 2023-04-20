import 'package:calendario2/app/controllers/utility_controller.dart';
import 'package:calendario2/app/modules/crearCuadrante/controllers/crear_cuadrante_controller.dart';
import 'package:calendario2/app/modules/home/controllers/home_controller.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/AddNotas/controllers/add_notas_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/tutorial/tutorialAddTask.dart';
import 'package:calendario2/config/tutorial/tutorialCuadrantes.dart';
import 'package:calendario2/config/tutorial/tutorialInicio.dart';
import 'package:calendario2/config/tutorial/tutorialTask.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialController extends GetxController {
  UtilityController utilityController = UtilityController();

  @override
  void onClose() {
    super.onClose();
  }

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  firstInstall(String view) async {
    print(view);

    SharedPreferences pref = await SharedPreferences.getInstance();

    switch (view) {
      case 'home':
        if (pref.getBool('tutoHomeFirst') == true) {
          showTutorial(Get.overlayContext, view);
          pref.setBool('tutoHomeFirst', false);
        }
        break;
      case 'task':
        if (pref.getBool('tutoTask') == true) {
          showTutorial(Get.overlayContext, view);
          pref.setBool('tutoTask', false);
        }
        break;
      case 'taskAdd':
        if (pref.getBool('tutoAddTask') == true) {
          showTutorial(Get.overlayContext, view);
          pref.setBool('tutoAddTask', false);
        }
        break;
      case 'cuadrante':
        if (pref.getBool('tutoCuadrante') == true) {
          showTutorial(Get.overlayContext, view);
          pref.setBool('tutoCuadrante', false);
        }
        break;
      default:
        break;
    }
  }

  void showTutorial(context, String view) {
    switch (view) {
      case 'home':
        print('showTutorialHome');
        createTutorialHome();
        tutorialCoachMark?.show(context: context);
        break;
      case 'task':
        createTutorialNotas();
        tutorialCoachMark?.show(context: context);
        break;
      case 'taskAdd':
        createTutorialAddNotas();
        tutorialCoachMark?.show(context: context);
        break;
      case 'cuadrante':
        createTutorialCuadrante();
        tutorialCoachMark?.show(context: context);
        break;
      default:
        break;
    }
  }

  ///Home
  ///

//
//   GlobalKey<FormState> keyButton6 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton7 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton8 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton9 = GlobalKey<FormState>();

  GlobalKey? keyButton6 = GlobalKey();
  GlobalKey? keyButton7 = GlobalKey();
  GlobalKey? keyButton8 = GlobalKey();
  GlobalKey? keyButton9 = GlobalKey();

  void createTutorialHome() {
    var homeController = Get.put(HomeController());

    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.bottomRight,
      targets: InicioListTarget().createTargets(
        keyButton6,
        keyButton7,
        keyButton8,
        keyButton9,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
        print(
            "finish createTutorialHome homeController.firstTime.value = false !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        homeController.firstTime.value = false;
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        homeController.firstTime.value = false;
      },
    );
  }

  ///Cuadrantes
  ///
  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();

  void createTutorialCuadrante() {
    var cuadranteController = Get.put(CrearCuadranteController());

    tutorialCoachMark = TutorialCoachMark(
      targets: ListTargetCuadrantes().createTargets(
        keyButton,
        keyButton2,
        keyButton3,
        keyButton4,
        keyButton5,
      ),
      alignSkip: Alignment.bottomLeft,

      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
        cuadranteController.firstTime.value = false;

        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        cuadranteController.firstTime.value = false;

        print("skip");
      },
    );
  }

  ///NOtas
  ///

  GlobalKey keyButton10 = GlobalKey();
  GlobalKey keyButton11 = GlobalKey();
  GlobalKey keyButton12 = GlobalKey();
  GlobalKey keyNotasListAyuda = GlobalKey();

  void createTutorialNotas() {
    var notasController = Get.put(NotasListController());

    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.bottomLeft,
      targets: ListTargetTask().createTargets(
        keyButton10,
        keyButton11,
        keyButton12,
        keyNotasListAyuda,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
        notasController.firstTime.value = false;

        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        notasController.firstTime.value = false;

        print("skip");
      },
    );
  }

  ///AddNotas
  ///

  GlobalKey keyButton13 = GlobalKey();
  GlobalKey keyButton14 = GlobalKey();
  GlobalKey keyButton15 = GlobalKey();
  GlobalKey keyButton16 = GlobalKey();
  GlobalKey keyButton17 = GlobalKey();
  GlobalKey keyNotasAyuda = GlobalKey();

  void createTutorialAddNotas() {
    var addNotasController = Get.put(AddNotasController());

    tutorialCoachMark = TutorialCoachMark(
      targets: ListTargetAddTask().createTargets(
        keyButton13,
        keyButton14,
        keyButton15,
        keyButton16,
        keyButton17,
        keyNotasAyuda,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
        addNotasController.firstTime.value = false;

        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        addNotasController.firstTime.value = false;

        print("skip");
      },
    );
  }
}
