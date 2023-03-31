import 'package:calendario2/app/modules/Notas/controllers/notas_controller.dart';
import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:calendario2/app/modules/notas/views/widgets/important_indicator_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'widgets/button_row_view.dart';
import 'widgets/taskCard.dart';

class NotasListView extends GetView<NotasListController> {
  const NotasListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.home,
              color: theme.primaryColor,
            ),
            color: theme.primaryColor,
            onPressed: () {
              Get.offAllNamed('/home');
            },
          ),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
//          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
            width: controller.headerShouldHide ? 0 : 200,
            child: Text(
              'Notas',
              style: TextStyle(
                  fontFamily: 'ZillaSlab',
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                  color: theme.primaryColor),
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_rounded, color: Colors.redAccent),
              tooltip: '',
              onPressed: () {
                // showTutorial();
              },
            ),
            // add your custom action widget
          ], //Action icon search as search icon, notification icon
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: theme.primaryColor,
          onPressed: () {
            controller.gotoEditNote();
          },
          label: Text('Añade Nota'.toUpperCase()),
          icon: Icon(Icons.add),
          // key: keyButton10,
        ),
        body: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.only(top: 6),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              // physics: BouncingScrollPhysics(),
              children: <Widget>[
                ButtonRowView(),
                ImportantIndicatorTextView(),
                Container(height: 6),
                ...controller.buildNoteComponentsList(),
                Container(height: 100)
              ],
            ),
          ),
        ),
      );
    });
  }


  /// todo rehacer esto por que esta continuo cargando, ver prints activados

}
