import 'package:calendario2/app/data/local/app_storage.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/services/app_cycle_service.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:get/get.dart';

class InicioController extends GetxController {
  double width = Get.width * 0.0001;
  CalendarController calendarController = Get.put(CalendarController());

  @override
  void onInit() {
    calendarController.onInit();
    startAnimation();
    checkRoute();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  Future<void> startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 10));
        width = Get.width * 1;
     update();

  }

  Future<void> checkRoute() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    await AppCycleService().checkFirstTimeAndRoute();
  }
}
