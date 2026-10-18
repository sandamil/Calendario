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

  void launchGmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'ajatsoft@gmail.com',
      query: 'subject= Email Calendario Turnos Appp&body = ',
    );
    String url = params.toString();
    await launchUrlString(url);
  }

  void launchTwitter() async {
    const String url = 'https://x.com/ajatsoft';
    await launchUrlString(url);
  }

  void giveFeedbackClicked(context) {
    AnalyticsHelper.logEvent(event: AnalyticsHelper.ayudaGiveFeedbackClicked);
    showBarModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            SizedBox(height: 600.h, child: const FeedbackScreen()));
  }

  void onRateThisAppPress() async {
    if (Platform.isAndroid || Platform.isIOS) {
      const androidPackageName = 'ajat.calendario.turnos';
      final appId = Platform.isAndroid ? androidPackageName : 'YOUR_IOS_APP_ID';

      final url = Uri.parse(
        Platform.isAndroid
            ? 'market://details?id=$androidPackageName'
            : 'https://apps.apple.com/app/id$appId',
      );

      final canLaunchIntent = await canLaunchUrl(url);
      if (canLaunchIntent) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrlString(
          'https://play.google.com/store/apps/details?id=$androidPackageName',
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }
}
