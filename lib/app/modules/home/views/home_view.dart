import 'package:calendario2/app/modules/home/widgets/calendar/calendar_logic.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import '../../../../config/theme/my_fonts.dart';
import '../../../../config/theme/my_theme.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    CalendarLogic calendarController = CalendarLogic();

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
            onPressed: () {
              calendarController.fetchCuadrante();
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: GetBuilder<HomeController>(
        builder: (_) {
          return const CalendarPage();
        },
      ),
    );
  }
}
