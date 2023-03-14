import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:get/get.dart';

import '../../CrearTurno/controllers/crear_turno_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<CalendarController>(
      () => CalendarController(),
    );
    Get.lazyPut(() => CrearTurnoController());
  }
}
