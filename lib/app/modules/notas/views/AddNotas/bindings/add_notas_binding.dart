import 'package:get/get.dart';

import '../controllers/add_notas_controller.dart';

class AddNotasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNotasController>(
      () => AddNotasController(),
    );
  }
}
