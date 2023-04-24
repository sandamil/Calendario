import 'package:calendario2/config/util/analytics_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../views/pages/feedback_screen.dart';

class AyudaController extends GetxController {
  //TODO: Implement AyudaController

  final count = 0.obs;
  @override
  void onInit() {
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

  void launchGmail() {}

  void reportProblem() {}

  void launchTwitter() {}

  void giveFeedbackClicked(context) {
    AnalyticsHelper.logEvent(
        event: AnalyticsHelper.ayudaGiveFeedbackClicked);
    showBarModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container( height: 600.h, child: const FeedbackScreen()));
  }

  void rateAppClicked() {
  }
}
