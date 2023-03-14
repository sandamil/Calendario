import 'package:get/get.dart';

import '../../CrearTurno/controllers/crear_turno_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut(() => CrearTurnoController());
  }
}
