import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/tutorial/tutorialInicio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialHomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    firstInstall();
  }

  @override
  void onClose() {
    super.onClose();
  }

  ///Tutorial
  ///
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
//
//   GlobalKey<FormState> keyButton6 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton7 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton8 = GlobalKey<FormState>();
//   GlobalKey<FormState> keyButton9 = GlobalKey<FormState>();

  GlobalKey? keyButton6 = GlobalKey();
  GlobalKey? keyButton7 = GlobalKey();
  GlobalKey? keyButton8 = GlobalKey();
  GlobalKey? keyButton9 = GlobalKey();
//
  firstInstall() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('tutoHome') == null) {
      showTutorial(Get.overlayContext);
      pref.setBool('tutoHome', true);
    }
  }

//
  void showTutorial(context) {
    createTutorial();
    tutorialCoachMark?.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.bottomRight,
      targets:
      InicioListTarget().createTargets(keyButton6, keyButton7, keyButton8, keyButton9),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: "Finalizar",
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () {
      },
      onClickTarget: (target) {
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
      },
      onClickOverlay: (target) {
      },
      onSkip: () {
      },
    );
  }
}


