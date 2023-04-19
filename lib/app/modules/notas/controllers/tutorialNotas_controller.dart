import 'package:calendario2/config/tutorial/tutorialTask.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:calendario2/config/theme/my_colors.dart' as mc;

class TutorialNotasController extends GetxController {
  @override
  void onInit() {
    print('onInit.TutorialNotasController =========');
    super.onInit();

    firstInstall();
  }

  ///Tutorial
  ///

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
//
  GlobalKey keyButton10 = GlobalKey();
  GlobalKey keyButton11 = GlobalKey();
  GlobalKey keyButton12 = GlobalKey();
  GlobalKey keyNotasListAyuda = GlobalKey();
//
  firstInstall() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('tutoTask') == null) {
      showTutorial(Get.overlayContext);
      pref.setBool('tutoTask', true);
    }
  }

//
  void showTutorial(context) {
    print('showTutorial');
    createTutorial();
    tutorialCoachMark?.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
        alignSkip: Alignment.bottomLeft,
      targets:
          ListTargetTask().createTargets(keyButton10, keyButton11, keyButton12, keyNotasListAyuda),
      colorShadow: mc.PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
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
        print("skip");
      },
    );
  }
}


