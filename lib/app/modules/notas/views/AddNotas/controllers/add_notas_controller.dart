import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotasController extends GetxController {

  Map<DateTime, List<Task>> events = <DateTime, List<Task>>{}.obs;

  bool headerShouldHide = false;



  TextEditingController title = TextEditingController();
  TextEditingController site = TextEditingController();
  TextEditingController notes = TextEditingController();
  Rx<DateTime> startTime = DateTime
      .now()
      .obs;
  Rx<DateTime> endTime = DateTime
      .now()
      .obs;
  RxBool isImportant = false.obs;

  DateTime time = DateTime.now();


  @override
  void onInit() {
    var dateTimeCalendar = Get.arguments;
    if (dateTimeCalendar != null) {
      startTime.value = dateTimeCalendar;
      endTime.value = dateTimeCalendar;
    }

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    title.clear();
    site.clear();
    notes.clear();
    super.onClose();
  }

  void addTravelEvent() {
    print('addTravelEvent' '$startTime');
    final int daysNum = endTime.value
        .difference(startTime.value)
        .inDays;
    if (0 == daysNum) {
      final DateTime time = DateTime(
          startTime.value.year, startTime.value.month, startTime.value.day);
      setTravelEvent(
        time,
        title.text,
        site.text,
        startTime.value,
        endTime.value,
        isImportant.value,
      );
    } else {
      for (int i = 0; i <= daysNum; i++) {
        DateTime _time = DateTime(startTime.value.year, startTime.value.month,
            startTime.value.day + i);
        if (0 == i) {
          setTravelEvent(_time, title.text, site.text, startTime.value,
              DateTime(0, 0, 0, 24), isImportant.value);
        } else if (i == daysNum) {
          setTravelEvent(time, title.text, site.text, DateTime(0, 0, 0, 0),
              endTime.value, isImportant.value);
        } else {
          setTravelEvent(_time, title.text, site.text, DateTime(0, 0, 0, 0),
              DateTime(0, 0, 0, 24), isImportant.value);
        }
      }
    }
  }

  void setTravelEvent(DateTime time, String title, String site,
      DateTime startTime, DateTime endTime, bool isImportant) async {
    if (events[time] != null) {
      print('if (events 1 =========' '${title}');
      events[time]?.add(Task(
        title: title,
        site: site,
        startTimeMilliseconds: startTime.millisecondsSinceEpoch,
        endTimeMilliseconds: endTime.millisecondsSinceEpoch,
        isImportant: isImportant,
      ));
    } else {
      print('if (events 2 =========' '${title}');
      events[time] = [
        Task(
          title: title,
          site: site,
          startTimeMilliseconds: startTime.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.millisecondsSinceEpoch,
          isImportant: isImportant,
        )
      ];
    }
  }

  addEvent() async {
    Task _item = await DbProvider.instance.select(
      await DbProvider.instance.insertNotas(
        Task(
          title: title.text,
          site: site.text,
          notes: notes.text,
          isImportant: isImportant.value,
          startTimeMilliseconds: startTime.value.millisecondsSinceEpoch,
          endTimeMilliseconds: endTime.value.millisecondsSinceEpoch,
          // time: Jiffy().format('yyyy-MM-dd h:mm:ss a')
        ),
      ),
    );
    print('addEvent' '${title.text}');
  }

  void markImportantAsDirty() {
    isImportant.value = !isImportant.value;
    update();
  }
}