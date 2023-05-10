import 'package:get/get.dart';

import '../controllers/version_anterior_controller.dart';

class VersionAnteriorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VersionAnteriorController>(
      () => VersionAnteriorController(),
    );
  }
}
