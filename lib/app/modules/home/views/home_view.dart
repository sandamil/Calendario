import 'package:calendario2/app/modules/home/widgets/calendar/calendar_view.dart';
import 'package:calendario2/config/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import '../../../../config/theme/my_theme.dart';
import '../controllers/home_controller.dart';
import '../widgets/appBar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), // here the desired height
          child: HomeAppBar()),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          MyTheme.changeTheme();
        },
        child: const Icon(Icons.icecream_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: GetBuilder<HomeController>(
        builder: (_) {
          return CalendarPage();
        },
      ),
    );
  }
}
