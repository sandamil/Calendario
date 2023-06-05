import 'package:get/get.dart';

import '../../../../config/theme/my_theme.dart';

class BoardingController extends GetxController {
   RxBool on = true.obs;


  get temaString {
    if(on.value){
      return 'Claro';
    }
    return 'Oscuro';
  } // our observable

  // swap true/false & save it to observable
  void toggle() {
    MyTheme.changeTheme();
    on.value = on.value ? false : true;
  }
}
