import 'package:calendario2/app/controllers/utility_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UtilityController());
  }
}
