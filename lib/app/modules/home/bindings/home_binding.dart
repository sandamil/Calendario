import 'package:get/get.dart';

import '../../CrearTurno/controllers/crear_turno_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/calendar/calendar_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut(() => CalendarLogic());
    Get.lazyPut(() => CrearTurnoController());
  }
}
