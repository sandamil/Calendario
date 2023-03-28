import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:calendario2/app/modules/notas/views/widgets/important_indicator_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/notas_controller.dart';
import 'widgets/button_row_view.dart';
import 'widgets/taskCard.dart';

class NotasView extends GetView<NotasController> {
  const NotasView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: theme.primaryColor,
          ),
          color: theme.primaryColor,
          onPressed: () {
            Get.offAll(const HomeView(),
                duration: const Duration(milliseconds: 100),
                transition: Transition.leftToRight);
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
                fontSize: 36.sp,
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
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            ButtonRowView(),
            ImportantIndicatorTextView(),
            Container(height: 6),
            ...buildNoteComponentsList(),
            Container(height: 100)
          ],
        ),
      ),
    );
  }
  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    controller.notesList.sort((a, b) {
      return b.startTimeMilliseconds!.compareTo(a.startTimeMilliseconds as num);
    });
    if (controller.searchController.text.isNotEmpty) {
      controller.notesList.forEach((note) {
        if (note.title!
            .toLowerCase()
            .contains(controller.searchController.text.toLowerCase()) ||
            note.title!
                .toLowerCase()
                .contains(controller.searchController.text.toLowerCase()))
          noteComponentsList.add(TaskCard(
            noteData: note,
            onTapAction: controller.openNoteToRead,
          ));
      });
      return noteComponentsList;
    }
    if (controller.isFlagOn.value) {
      controller.notesList.forEach((note) {
        if (note.isImportant!)
          noteComponentsList.add(TaskCard(
            noteData: note,
            onTapAction: controller.openNoteToRead,
          ));
      });
    } else {
      controller.notesList.forEach((note) {
        noteComponentsList.add(TaskCard(
          noteData: note,
          onTapAction: controller.openNoteToRead,
        ));
      });
    }
    return noteComponentsList;
  }

}
