import 'package:get/get.dart';

import '../controllers/edit_notas_controller.dart';

class EditNotasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditNotasController>(
      () => EditNotasController(),
    );
  }
}
