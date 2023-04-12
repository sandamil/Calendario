import 'package:calendario2/app/modules/notas/views/alarmas/controllers/alarmas_controller.dart';
import 'package:get/get.dart';

import '../controllers/notas_controller.dart';

class NotasListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotasListController>(
      () => NotasListController(),
    );

  }
}
