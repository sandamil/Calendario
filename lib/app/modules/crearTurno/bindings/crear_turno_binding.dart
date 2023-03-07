import 'package:get/get.dart';

import '../controllers/crear_turno_controller.dart';

class CrearTurnoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrearTurnoController>(
      () => CrearTurnoController(),
    );
  }
}
