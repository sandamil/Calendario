import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../controllers/app_controller.dart';

class SelectedDayWidget extends StatelessWidget {
  const SelectedDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: GetBuilder<CalendarController>(
          builder: (controller) {
            return Text(
              DateFormat.MMMM('es').add_y().format(AppController().focusDayRx).toUpperCase(),
              style: CustomTextStyle.appBarTitle(context: context),
            );
          },
        ));
  }
}
