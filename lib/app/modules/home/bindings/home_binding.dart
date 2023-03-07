import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/calendar/calendar_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut(() => CalendarLogic());
  }
}
