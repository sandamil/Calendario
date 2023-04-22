import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/controllers/utility_controller.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/tutorial/tutorialInicio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';


class HomeController extends GetxController {
  NotasListController notasController = NotasListController();
  TutorialController tutorialController = TutorialController();

  RxBool firstTime = false.obs;

  void onInit() async {
    if (MySharedPref.getTutoHomeFirst()) {
      firstTime.value = true;
      tutorialController.firstInstall('home');
    }

    super.onInit();
  }

  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
