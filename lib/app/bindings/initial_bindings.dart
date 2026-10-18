import 'package:get/get.dart';

import '../controllers/ads_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AdsController());
  }
}
