import 'package:calendario2/app/data/model/turnoCalendar.dart';
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
            Obx(() {
              return controller.isReady.value
                  ? TableCalendar(
                      // pageJumpingEnabled: true,
                      // pageAnimationEnabled: false,
                      locale: 'es_ES',
                      weekendDays: const [DateTime.saturday, DateTime.sunday],
                      // enabledDayPredicate: (date) {
                      //   return (date.weekday != DateTime.sunday &&
                      //       date.weekday != DateTime.saturday);
                      // },
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 600, hours: 23)),
                      focusedDay: controller.focusedDay,
                      // calendarFormat: controller.calendarFormat,
                      eventLoader: controller.getEventForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) {
                        return isSameDay(controller.selectedDay, day);
                      },
                      onDaySelected: controller.onDaySelected,
                      // onFormatChanged: (format) {
                      //   if (controller.calendarFormat != format) {
                      //     controller.changeCalendarFormat(format);
                      //   }
                      // },
                      onCalendarCreated: (_) async {
                        await controller.update;
                      },
                      onPageChanged: (focusedDay) {
                        controller.focusedDay = focusedDay;
                      },
                      calendarStyle: const CalendarStyle(
                        markersAlignment: Alignment.bottomRight,
                        outsideDaysVisible: false,
                        canMarkersOverflow: true,
                        todayTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          // color: HelperTheme.primary
                        ),
                        selectedTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          // color: HelperTheme.white
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            // color: HelperTheme.black
                          )),

                      ///=======================================================Calendar builders
                      ///

                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, events) => Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              // color: HelperTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              date.day.toString(),
                              // style: const TextStyle(
                              //     color: HelperTheme.black
                              // ),
                            )),
                        todayBuilder: (context, date, events) => Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                // color: HelperTheme.warning,
                                shape: BoxShape.circle),
                            child: Text(
                              date.day.toString(),
                              // style: const TextStyle(
                              //     color: HelperTheme.black
                              // ),
                            )),

                        ///=======================================================   markerBuilder
                        ///
                        markerBuilder: (context, day, List<Cuadrante> events) {
                          return events.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.all(1.0),
                                  //   padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: events != null
                                        ? HexColor(events[0].color!).withAlpha(600)
                                        : Theme.of(context).highlightColor,
                                    border: events != null
                                        ? Border.all(
                                            color: HexColor(events[0].color!),
                                            width: 1)
                                        : null,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  width: 100,
                                  height: 100,
                                  //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                                  child: Container(
                                    child: events[0].title != null
                                        ? Stack(
                                            children: <Widget>[
                                              Positioned.fill(
                                                bottom: 0.0,
                                                child: Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Text(
                                                      events[0]
                                                          .title!
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: HexColor(
                                                              events[0].color!),
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                              )
                                            ],
                                          )
                                        : null,
                                  ))
                              : Container();
                        },

                        dowBuilder: (context, day) {
                          if (day.weekday == DateTime.sunday ||
                              day.weekday == DateTime.saturday) {
                            final text = DateFormat.E('es').format(day);
                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    )




                  : Center(child: CircularProgressIndicator());



            },),
    //           Expanded(
    //           child: ValueListenableBuilder<List<Cuadrante>>(
    //           builder: (context, value, _) {
    //             return value.isEmpty
    //                 ? const Center(
    //               child: Text('Doctor is not available in this day.'),
    //             )
    //                 : ListView.builder(
    //               itemCount: value.length,
    //               itemBuilder: (context, index) {
    //                 Cuadrante currentValue = value[index];
    //                  // isAvailable = currentValue.title;
    //                 return Container(
    //                   margin: const EdgeInsets.symmetric(
    //                     horizontal: 12.0,
    //                     vertical: 4.0,
    //                   ),
    //                   decoration: BoxDecoration(
    //                     border: Border.all(),
    //                     borderRadius: BorderRadius.circular(12.0),
    //                   ),
    //                   child: ListTile(
    //                     title: Text(
    //                       "Time: ${currentValue.dateTime} - ${currentValue.dateTime}",
    //                     ),
    //                     subtitle: Text(
    //                      currentValue.description!
    //                     ),
    //                     trailing: ElevatedButton(
    //                         onPressed: () {},
    //
    //                         child: const Text("Book"))
    //
    //                   ),
    //                 );
    //               },
    //             );
    //           },
    //         ),
    // ),



          ],
        )
    );
  }
}








