import 'dart:io';

import 'package:calendario2/config/util/analytics_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../views/pages/feedback_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AyudaController extends GetxController {
  //TODO: Implement AyudaController

  final count = 0.obs;




  void goToVersionAnteriorScreen() {
    Get.toNamed('/version-anterior');
  }



  void launchGmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'ajatsoft@gmail.com',
      query: 'subject= Email Calendario Turnos Appp&body = ',
    );
    String url = params.toString();
    if (await launchUrlString(url)) {
      await launchUrlString(url);
    } else {
    }
  }

  void reportProblem() {}

  void launchTwitter() async {
    const String url = 'https://www.twitter.com/@ajatsoft';
    if (await launchUrlString(url)) {
      await launchUrlString(url);
    } else {
    }
  }

  void giveFeedbackClicked(context) {
    AnalyticsHelper.logEvent(event: AnalyticsHelper.ayudaGiveFeedbackClicked);
    showBarModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            SizedBox(height: 600.h, child: const FeedbackScreen()));
  }

  void rateAppClicked() {}



  void onRateThisAppPress() async {
    // logEvent(EventNames.rateAppClicked, {});
    if (Platform.isAndroid || Platform.isIOS) {
      // todo support for ios
      var androidPackageName = 'ajat.calendario.turnos';
      final appId = Platform.isAndroid ? androidPackageName: 'YOUR_IOS_APP_ID';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      bool canLaunchIntent = await canLaunchUrl(url);
      if (canLaunchIntent) {
        launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        launchUrlString(
            'https://play.google.com/store/apps/details?id=$androidPackageName');
      }
    }
  }



}
