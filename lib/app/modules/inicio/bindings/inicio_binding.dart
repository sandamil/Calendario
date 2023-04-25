import 'package:calendario2/app/modules/boarding/controllers/boarding_controller.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/inicio_controller.dart';

class InicioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InicioController>(() => InicioController());
    Get.lazyPut<CalendarController>(() => CalendarController());
  }

}


