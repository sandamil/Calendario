import 'package:get/get.dart';

import '../controllers/notas_controller.dart';

class NotasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotasController>(
      () => NotasController(),
    );
  }
}
