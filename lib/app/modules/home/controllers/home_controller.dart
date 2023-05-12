import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/controllers/tutorialController.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
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

  //? to close the app
  void appCloseConfirm(context) {
    CustomDialog.myConfirmDialogBody(
      context: context,
      title: '¿ Salir de la aplicacion ?',
      desc: 'Quieres cerrar la aplicación?'
          '\nPuedes dejarla en segundo plano'
          '\nsi pulsas el botón: o en vez de: <',
      btnCancelText: 'Salir',
      btnOkText: 'Quedarme',
      onTapOK: () async {
        Get.back();
      },
      onTapCancel: () async {
        SystemNavigator.pop();
      },
    );
  }
}
