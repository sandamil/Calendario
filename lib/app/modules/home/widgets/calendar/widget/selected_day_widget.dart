import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SelectedDayWidget extends StatelessWidget {
  SelectedDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: GetBuilder<CalendarController>(
          builder: (controller) {
            return Text(
              DateFormat.MMMM('es').add_y().format(controller.focusedDay.value).toUpperCase(),
              style: TextStyle(
                fontSize: MyFonts.headline3TextSize,
                fontWeight: FontWeight.bold,
                color: Colors.orange
              ),
            );
          },
        ));
  }
}
