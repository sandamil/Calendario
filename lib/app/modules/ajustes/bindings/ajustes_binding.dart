import 'package:get/get.dart';

import '../controllers/ajustes_controller.dart';

class AjustesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AjustesController>(
      () => AjustesController(),
    );
  }
}
