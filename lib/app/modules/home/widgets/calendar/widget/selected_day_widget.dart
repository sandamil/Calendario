import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class SelectedDayWidget extends StatelessWidget {
  final calendarController = Get.put(CalendarController());


  SelectedDayWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child:
        Obx(() {
          return Text(
            DateFormat.MMMM('es').add_y()
                .format(calendarController.focusDayRx.value)
                .toUpperCase(),
            style: CustomTextStyle.appBarTitle(context: context),
          );
        })

    );
  }
}
