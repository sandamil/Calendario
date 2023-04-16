import 'package:get/get.dart';

import '../controllers/ayuda_controller.dart';

class AyudaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AyudaController>(
      () => AyudaController(),
    );
  }
}
