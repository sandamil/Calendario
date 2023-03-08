import 'package:get/get.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/turnoType.dart';

class CrearTurnoController extends GetxController {
  //TODO: Implement CrearTurnoController
  RxList<TurnoType> turnoType = <TurnoType>[].obs;

  @override
  void onInit() {
    fetchEventsType();
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


  Future<List<TurnoType>> fetchEventsType() async {
    turnoType.value = await TurnoDbProvider.instance.getTypeModels();
    return turnoType;
  }
}
