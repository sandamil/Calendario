import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:get/get.dart';

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
