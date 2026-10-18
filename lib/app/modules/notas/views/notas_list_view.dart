import 'dart:io';

import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:calendario2/app/modules/notas/views/widgets/important_indicator_text_view.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../config/util/app_icons.dart';
import 'widgets/button_row_view.dart';

class NotasListView extends GetView<NotasListController> {
  NotasListView({Key? key}) : super(key: key);

  bool _tutorialStartScheduled = false;
  final adcontroller = Get.find<AdsController>();

  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    if (!_tutorialStartScheduled && MySharedPref.getTutoTaskFirst()) {
      _tutorialStartScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        controller.firstTime.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          tutorialController.firstInstall(
            'task',
            context: context,
            onFinished: () => controller.firstTime.value = false,
          );
        });
      });
    }

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          //? to close quick order floating if its open when click back btn
          adcontroller.staticHomeAd.load();

          Get.offAllNamed('/home');
        }
        return false;
      },
      child: Obx(() {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.home,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              onPressed: () {
                adcontroller.staticHomeAd.load();

                Get.offAllNamed('/home');
              },
            ),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Notas',
              style: CustomTextStyle.appBarTitle(context: context),
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
            actions: <Widget>[
              IconButton(
                key: controller.firstTime.value
                    ? tutorialController.keyNotasListAyuda
                    : key,
                icon: const AppIcon(AppIcons.informacion, color: Colors.green),
                tooltip: '',
                onPressed: () {
                  controller.firstTime.value = true;
                  tutorialController.showTutorial(
                    context,
                    'task',
                    onFinished: () => controller.firstTime.value = false,
                  );
                },
              ),
              // add your custom action widget
            ], //Action icon search as search icon, notification icon
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: PRIMARY_COLOR,
            onPressed: () {
              controller.gotoEditNote();
              // adcontroller.staticNotesListAd.dispose();
            },
            label: Text(
              'Añade Nota'.toUpperCase(),
              key: controller.firstTime.value
                  ? tutorialController.keyButton10
                  : key,
            ),
            icon: const Icon(Icons.add),
          ),
          // bottomNavigationBar: Platform.isAndroid
          //     ?
          //
          // adcontroller.staticAdNotesListLoaded.value
          //     ? Container(
          //         color: Colors.transparent,
          //         width: adcontroller.staticNotesListAd.size.width.toDouble(),
          //         height: adcontroller.staticNotesListAd.size.height.toDouble(),
          //         alignment: Alignment.bottomCenter,
          //         child: AdWidget(
          //           ad: adcontroller.staticNotesListAd,
          //         ),
          //       )
          //     : const SizedBox(
          //       ): null,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(top: 6.h),
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: SingleChildScrollView(
              child: Column(
                // physics: BouncingScrollPhysics(),
                children: <Widget>[
                  const ButtonRowView(),
                  const ImportantIndicatorTextView(),
                  Container(height: 6.h),
                  ...controller.buildNoteComponentsList(),
                  Container(height: 100.h)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
