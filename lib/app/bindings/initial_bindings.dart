import 'package:calendario2/app/controllers/app_controller.dart';
import 'package:get/get.dart';

import '../controllers/ads_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(AdsController());

  }
}
