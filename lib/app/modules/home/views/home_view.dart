import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/table_calendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/cuadrante_calendar_day.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config/theme/my_fonts.dart';
import '../../../../config/theme/my_theme.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  Get.to(() => const MenuView(),
                      duration: const Duration(milliseconds: 100),
                      transition: Transition.leftToRight);
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: Text(
            "Calendario",
            style: TextStyle(
              fontSize: MyFonts.headline3TextSize,
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              color: theme.primaryColor,
              icon: const Icon(
                Icons.today,
              ),
              tooltip: 'Open shopping cart',
              onPressed: () async {
                await Get.deleteAll(force: true); //deleting all controllers
                Get.reset();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          onPressed: () {
            MyTheme.changeTheme();
          },
          child: const Icon(Icons.icecream_rounded),
        ),
        body: Column(
          children: [
            CalendarWidget(),
            SelectedDayWidget(),
            Container(height: 200,child: CuadranteCalendarDay()),
          ],
        )
    );
  }
}








