import 'dart:async';

import 'package:calendario2/app/data/local/app_storage.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';

class AppCycleService {
  factory AppCycleService() {
    return _instance;
  }
  AppCycleService._internal() {
    logSys('AppCylceService Initialized');
  }

  static final AppCycleService _instance = AppCycleService._internal();

  // CalendarController calendarController = Get.put(CalendarController());

  Future<void> checkFirstTimeAndRoute() async {
    try {

      //* CHECK FIRST TIME OPEN APP
      final value = await AppStorage.read(key: APP_FIRST_TIME_OPEN);
      if (value.isEmpty) {
        await Get.offNamed(Routes.BOARDING);
        return;
      }

      //* DEFAULT ROUTES TO HOME
      // calendarController.onInit();
      await Get.offNamed(Routes.HOME);
    } on Exception {
      // await Get.offNamed(Routes.LOGIN);
    }
  }

}
