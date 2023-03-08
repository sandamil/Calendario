import 'package:get/get.dart';

class AjustesController extends GetxController {
  //TODO: Implement AjustesController

  final count = 0.obs;
  @override
  void onInit() {
    print('AjustesController');
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

  void increment() => count.value++;
}
