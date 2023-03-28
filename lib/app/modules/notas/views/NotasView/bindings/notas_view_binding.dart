import 'package:get/get.dart';

import '../controllers/notas_view_controller.dart';

class NotasViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotasViewController>(
      () => NotasViewController(),
    );
  }
}
