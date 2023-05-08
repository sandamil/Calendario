import 'dart:io';

import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/data/local/previusTaskDatabase.dart';
import 'package:calendario2/app/modules/notas/views/widgets/taskCard.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/table_calendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../controllers/ads_controller.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final adcontroller = Get.find<AdsController>();
  final calendarController = Get.find<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) =>
            calendarController.onTapDown(details),
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    key: controller.firstTime.value
                        ? controller.tutorialController.keyButton6
                        : key,
                    icon: Icon(
                      Icons.menu,
                      color: PRIMARY_COLOR,
                      size: 26.sp,
                    ),
                    onPressed: () {
                      Get.to(() => const MenuView(),
                          duration: const Duration(milliseconds: 100),
                          transition: Transition.leftToRight);
                    },
                    tooltip: MaterialLocalizations.of(context)
                        .openAppDrawerTooltip,
                  );
                },
              ),
              title: const SelectedDayWidget(),
              actions: [
                IconButton(
                  key: controller.firstTime.value
                      ? controller.tutorialController.keyButton7
                      : key,
                  color: PRIMARY_COLOR,
                  icon: const Icon(
                    Icons.today,
                  ),
                  tooltip: 'today',
                  onPressed: () async {
                    // CustomDialog.showPopUpInfo(
                    //   title: 'Volver a HOY',
                    //   description: 'Selecciona Mes al que quieres ir',
                    //   labelButton: 'Volver',
                    //   // onPress: (){}
                    // );adb backup -noapk ajat.calendario.turnos

                    // / data/data/ ajat.calendario.turnos/app_flutter/ DBC4A.db
                    await PreviusDbProvider.instance.getPreviousTaskFromDB();
                    // print(notesList.asMap());
                  },
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isAndroid
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      // MyTheme.changeTheme();
                    },
                    label: adcontroller.staticAdHomeLoaded.value
                        ? Container(
                            color: Colors.transparent,
                            width: adcontroller.staticHomeAd.size.width
                                .toDouble(),
                            height: adcontroller.staticHomeAd.size.height
                                .toDouble(),
                            alignment: Alignment.bottomCenter,
                            child: AdWidget(
                              ad: adcontroller.staticHomeAd,
                            ),
                          )
                        : const SizedBox(),
                  )
                : null,
            body: Column(
              children: [
                SizedBox(height: 2.h),
                CalendarWidget(
                  key: controller.firstTime.value
                      ? controller.tutorialController.keyButton8
                      : key,
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: LineWidget(),
                ),
                // SizedBox(height: 2.h),
                // Obx(() => _buildSelectedDay()),
                SizedBox(height: 2.h),
                Obx(() {
                  return Expanded(
                    child: _buildListEvent(),
                    key: controller.firstTime.value
                        ? controller.tutorialController.keyButton9
                        : key,
                  );
                }),
              ],
            )),
      );
    });
  }

  Widget _buildListEvent() {
    final calendarVM = Get.find<CalendarController>();
    final selectedDay = calendarVM.selectedDay.value;
    String formattedDate =
        '${selectedDay.day} / ${selectedDay.month} / ${selectedDay.year}';
    List events = calendarVM.getEventsOfDay(selectedDay);

    return SingleChildScrollView(
      child: Column(
        children: [
          // events.isNotEmpty
          //     ? Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Container(
          //             margin: EdgeInsets.only(left: 4.w),
          //             child:  Text(
          //               'Notas para el día:',
          //               style: TextStyle(fontSize: 14.sp),
          //             ),
          //           ),
          //           const SizedBox(height: 5),
          //           Container(
          //             margin:  EdgeInsets.only(left: 4.w),
          //             child: Text(
          //               formattedDate,
          //               style: TextStyle(fontSize: 14.sp),
          //             ),
          //           ),
          //         ],
          //       )
          //     : Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Container(
          //             margin: EdgeInsets.only(left: 4.w),
          //             child: Text(
          //               'No hay notas grabadas para el día:',
          //               style: TextStyle(fontSize: 14.sp),
          //             ),
          //           ),
          //            SizedBox(height: 5.h),
          //           Container(
          //             margin: EdgeInsets.only(left: 4.w),
          //             child: Text(
          //               formattedDate,
          //               style: TextStyle(fontSize: 14.sp),
          //             ),
          //           ),
          //         ],
          //       ),
          SingleChildScrollView(
              child: Column(
            children: events
                .map(
                  (event) => Column(
                    children: [
                      // CardEvent(event: event),
                      TaskCard(
                          noteData: event,
                          onTapAction:
                              controller.notasController.openNoteToRead)
                    ],
                  ),
                )
                .toList(),
          )),
        ],
      ),
    );
  }

// Widget _buildSelectedDay() {
//   final calendarVM = Get.find<CalendarController>();
//
//   final selectedDay = calendarVM.selectedDay.value;
//   String formattedDate =
//       '${selectedDay.day} / ${selectedDay.month} / ${selectedDay.year}';
//
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Container(
//         margin: const EdgeInsets.only(left: 10),
//         child: const Text(
//           'Notas para el dia:',
//           // style: AppTextStyle.titleTextStyle(),
//         ),
//       ),
//       const SizedBox(height: 5),
//       Container(
//         margin: const EdgeInsets.only(left: 10),
//         child: Text(
//           formattedDate + ':',
//           // style: AppTextStyle.disableTextStyle(),
//         ),
//       ),
//     ],
//   );
// }
}
