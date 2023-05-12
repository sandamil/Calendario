import 'package:get/get.dart';

import '../controllers/videotutoriales_controller.dart';

class VideotutorialesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideotutorialesController>(
      () => VideotutorialesController(),
    );
  }
}
