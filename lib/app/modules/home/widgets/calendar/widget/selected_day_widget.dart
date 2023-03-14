import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';




class SelectedDayWidget extends StatelessWidget {
  SelectedDayWidget({super.key});

  final calendarController = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Obx(
            () {
          return Text(
            DateFormat.MMMM('es').format(calendarController.selectedDay.value),
            style: TextStyle(fontFamily: "FiraCode", fontSize: 16.0, color: Colors.orange),
          );
        },
      ),
    );
  }
}
