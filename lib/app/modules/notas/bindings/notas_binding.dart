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
