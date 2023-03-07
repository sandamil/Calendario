import 'package:get/get.dart';

import '../controllers/crear_cuadrante_controller.dart';

class CrearCuadranteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrearCuadranteController>(
      () => CrearCuadranteController(),
    );
  }
}
