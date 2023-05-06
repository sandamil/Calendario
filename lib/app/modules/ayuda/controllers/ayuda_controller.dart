import 'package:calendario2/app/data/local/previusTaskDatabase.dart';
import 'package:calendario2/app/data/model/previousTaskModel.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/notas_version_anterior_screen.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/version_anterior_screen.dart';
import 'package:calendario2/config/util/analytics_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../views/pages/feedback_screen.dart';
import '../views/widgets/notasBkpCard.dart';

class AyudaController extends GetxController {
  //TODO: Implement AyudaController

  final count = 0.obs;

  @override
  void onInit() {
    setNotesFromDB();
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

  void goToVersionAnteriorScreen() {
    Get.to(
      () => const VersionAnteriorScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }

  void goToNotasVersionAnteriorScreen() {
    Get.to(
      () => const NotasVersionAnteriorScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }

  void launchGmail() {}

  void reportProblem() {}

  void launchTwitter() {}

  void giveFeedbackClicked(context) {
    AnalyticsHelper.logEvent(event: AnalyticsHelper.ayudaGiveFeedbackClicked);
    showBarModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            SizedBox(height: 600.h, child: const FeedbackScreen()));
  }

  void rateAppClicked() {}

  RxList<PreviousTask> notesBkpList = <PreviousTask>[].obs;

  setNotesFromDB() async {
    notesBkpList.value = await PreviusDbProvider.instance.getPreviousTaskFromDB();
    update();
    return notesBkpList.value;
  }

  List<Widget> buildNoteBkpComponentsList() {
    List<Widget> noteBkcComponentsList = [];
    notesBkpList.value.sort((a, b) {
      return b.year!.compareTo(a.year as num);
    });
    notesBkpList.value.forEach((note) {
      noteBkcComponentsList.add(NotasBkpCard(
        noteData: note,
        // onTapAction: openNoteToRead,
      ));
    });

    return noteBkcComponentsList;
  }
}
