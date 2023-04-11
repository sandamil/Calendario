import 'package:get/get.dart';

import '../controllers/alarmas_controller.dart';

class AlarmasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmasController>(
      () => AlarmasController(),
    );
  }
}
