import 'dart:collection';

import 'package:calendario2/widgets/buttons/button_primary.dart';
import 'package:calendario2/widgets/buttons/button_text_rich.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';

import 'package:table_calendar/table_calendar.dart';

import '../../../../config/theme/my_fonts.dart';
import '../../../../config/util/hexColor.dart';
import '../../../data/model/cuadranteDay.dart';
import '../../../providers/calendar.dart';
import '../../menu/views/menu_view.dart';

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HomeView extends HookConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  // @override
  // HomeViewState createState() => HomeViewState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final calendarState = ref.watch(calendarProvider);
    final calendarAction = ref.read(calendarProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        calendarAction.syncSchedules(now).then((err) {
          if (err != null) {
            AppDialog().showErrorAlert(context, err);
            return;
          }
        });
      });

      return () {};
    }, const []);

    final calendar = TableCalendar(
        locale: 'ja_JP',
        firstDay: DateTime.utc(now.year - 1, 1, 1),
        lastDay: DateTime.utc(now.year + 1, 12, 31),
        focusedDay: calendarState.focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
        ),
        selectedDayPredicate: (day) {
          return isSameDay(calendarState.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(calendarState.selectedDay, selectedDay)) {
            calendarAction.selectDay(selectedDay);
          }
        },
        onPageChanged: (date) {
          calendarAction.focusDay(date);
          calendarAction.syncSchedules(date).then((err) {
            if (err != null) {
              AppDialog().showErrorAlert(context, err);
              return;
            }
          });
        },
        eventLoader:
            EventMaker(schedules: calendarState.schedulesInMonth).getLoader(),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, List<dynamic> events) {
            // List<Task> notas = calendarController.getNotasOfDay(day);
            return Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 20.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...events.map((turno) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.5.h, horizontal: 3.w),
                          child: Container(
                            decoration: BoxDecoration(
                              color: HexColor(turno.color!).withAlpha(600),
                              // border: Border.all(
                              //     color: HexColor(turno.color!), width: 1.h),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            height: 15.h,
                            child: Container(
                              alignment: Alignment.center,
                              height: 15,
                              width: double.maxFinite,
                              child: Text(turno.title!.toUpperCase(),
                                  style: TextStyle(
                                      height: 1.2.h,
                                      fontSize: 12.sp,
                                      color: HexColor(turno.color!),
                                      fontWeight: FontWeight.w900)),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 3.h,
                    ),
                    ...events.map((nota) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.5.h, horizontal: 1.w),
                          child: Container(
                              decoration: BoxDecoration(
                                color: MyColors.menuCardBackground,
                                // color: PRIMARY_COLOR_TRANSPARENTE,
                                // border: Border.all(
                                //     color: PRIMARY_COLOR_TRANSPARENTE, width: 1.h),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              height: 15.h,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  nota.title!.toUpperCase(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1.h,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              )),
                        )),
                  ],
                ),
              ),
            );
          },

          ///==      holidayBuilder:         ========================================
          holidayBuilder: (context, day, focusedDay) {
            return Padding(
              padding: EdgeInsets.all(0.h),
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  border:
                      Border.all(width: 1.w, color: MyColors.borderCellColor),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Column(
                    children: [
                      Text(
                        day.day.toString(),
                        style: CustomTextStyle.numberCalendar.copyWith(
                          color: MyColors.cellTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },

          ///==      outsideBuilder:         ========================================
          // outsideBuilder: (context, date, events) =>
          //     DayBuilderWidget(date: date, dayType: 'outside'),

          ///==      defaultBuilder:         ========================================
          defaultBuilder: (context, day, focusedDay) {
            return Padding(
              padding: EdgeInsets.all(0.h),
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  color: MyColors.cellColor,
                  border:
                      Border.all(width: 1.w, color: MyColors.borderCellColor),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Column(
                    children: [
                      Text(
                        day.day.toString(),
                        style: CustomTextStyle.numberCalendar.copyWith(
                          color: MyColors.cellTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },

          ///==      selectedBuilder:         ========================================
          selectedBuilder: (context, day, focusedDay) {
            return Padding(
              padding: EdgeInsets.all(0.h),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyColors.cellSelectedColor,
                  // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                  border: Border.all(
                    color: PRIMARY_COLOR,
                    width: 0.05.w,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    day.day.toString(),
                    style: CustomTextStyle.numberCalendar.copyWith(
                      fontSize: 15.sp,
                      color: MyColors.cellTextColor,
                    ),
                  ),
                ),
              ),
            );
          },

          ///==      todayBuilder:         ========================================
          todayBuilder: (context, day, events) {
            return Padding(
              padding: EdgeInsets.all(0.h),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyColors.cellTodayColor,
                  // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
                  border: Border.all(
                    color: PRIMARY_COLOR,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    day.day.toString(),
                    // textWidthBasis: TextWidthBasis.longestLine,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'FiraCode',
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ),
              ),
            );
          },

          ///==      dowBuilder:         ========================================
          // dowBuilder: (context, day) {
          //   final text = DateFormat.E('es').format(day);
          //   if (day.weekday == DateTime.sunday
          //   // || day.weekday == DateTime.saturday
          //   ) {
          //     return Center(
          //       child: Text(
          //         text.toUpperCase(),
          //         style: const TextStyle(color: Colors.red),
          //       ),
          //     );
          //   }
          //   return Center(
          //     child: Text(
          //       text.toUpperCase(),
          //       // style: const TextStyle(color: Colors.red),
          //     ),
          //   );
          // },
        ));

    const double appBarHeight = 50;
    final calendarHeight =
        calendar.rowHeight * 6 + calendar.daysOfWeekHeight + 70;
    final listHeight =
        MediaQuery.of(context).size.height - appBarHeight - calendarHeight - 50;

    final content = Container(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: calendarHeight,
            margin: EdgeInsets.zero,
            child: calendar,
          ),
          Container(
            height: listHeight,
            margin: EdgeInsets.zero,
            child: ListView.builder(
              itemCount: calendarState.schedulesInDay().length,
              itemBuilder: (BuildContext context, int index) {
                final schedule = calendarState.schedulesInDay()[index];
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(schedule.title!,
                            style: ThemeData.dark().textTheme.bodyText1),
                      ),
                      Container(
                          width: 70,
                          child: Text(schedule.description!,
                              style: ThemeData.dark().textTheme.caption,
                              textAlign: TextAlign.right),
                          margin: const EdgeInsets.only(left: 10))
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ThemeData.dark().dividerColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: AppBar(
          title: Text(calendarState.selectedDayText()),
          centerTitle: true,
        ),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeData.dark().primaryColor,
        foregroundColor: ThemeData.dark().textTheme.bodyText1!.color!,
        child: const Icon(Icons.add),
        onPressed: () {
          Get.to(() => const MenuView(),
              duration: const Duration(milliseconds: 100),
              transition: Transition.leftToRight);
        },
        // modal(context, RegistrationPage.init(()
        // {
        //   calendarAction.syncSchedules(calendarState.focusedDay).then((err) {
        //     if (err != null) {
        //       AppDialog().showErrorAlert(context, err);
        //       return;
        //     }
        //   });
        // }));
      ),
    );
  }
}

typedef EventLoader = List<dynamic> Function(DateTime day);

class EventMaker {
  final List<CuadranteDay> schedules;

  EventMaker({required this.schedules});

  int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  EventLoader getLoader() {
    final events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: _getHashCode,
    );

    Map<DateTime, List<CuadranteDay>> map = {};
    for (var schedule in schedules) {
      if (map.containsKey(schedule.dateTime!)) {
        map[schedule.dateTime!]!.add(schedule);
      } else {
        map[schedule.dateTime!] = [schedule];
      }
    }

    events.addAll(map);

    return (DateTime day) {
      return events[day] ?? [];
    };
  }
}

// class HomeViewState extends ConsumerState<HomeView> {
//   late final PageController pageController;
//   final isDialOpen = ValueNotifier(false);
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final focusedDayValue = ref.watch(focusedDayProvider);
//     final selectedDayValue = ref.watch(selectedDayProvider);
//
//     return WillPopScope(
//         onWillPop: () async {
//           if (Platform.isAndroid) {
//             //? to close quick order floating if its open when click back btn
//             if (isDialOpen.value) {
//               isDialOpen.value = false;
//               return false;
//             } else {
//               // homeController.appCloseConfirm(context);
//             }
//           }
//           return false;
//         },
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           // onTapDown: (TapDownDetails details) => onTapDown(details),
//           child: Scaffold(
//               appBar: AppBar(
//                 centerTitle: false,
//                 elevation: 0,
//                 backgroundColor: Colors.transparent,
//                 leading: Builder(
//                   builder: (BuildContext context) {
//                     return IconButton(
//                       // key: homeController.firstTime.value
//                       //     ? homeController.tutorialController.keyButton6
//                       //     : widget.key,
//                       icon: Icon(
//                         Icons.menu,
//                         color: PRIMARY_COLOR,
//                         size: 26.sp,
//                       ),
//                       onPressed: () {
//                         // adcontroller.staticHomeAd.dispose();
//                         Get.to(() => const MenuView(),
//                             duration: const Duration(milliseconds: 100),
//                             transition: Transition.leftToRight);
//                       },
//                       tooltip: MaterialLocalizations.of(context)
//                           .openAppDrawerTooltip,
//                     );
//                   },
//                 ),
//                 title: SelectedDayWidget(),
//                 actions: [
//                   IconButton(
//                     // key: homeController.firstTime.value
//                     //     ? homeController.tutorialController.keyButton7
//                     //     : widget.key,
//                     color: PRIMARY_COLOR,
//                     icon: const Icon(
//                       Icons.today,
//                     ),
//                     tooltip: 'today',
//                     onPressed: () {
//                       // controller.firstTime.value = true;
//                       // controller.tutorialController.showTutorial(context, 'home');
//                       Get.toNamed('/version-anterior');
//                       // CustomDialog.showPopUpInfo(
//                       //   title: 'Volver a HOY',
//                       //   description: 'Selecciona Mes al que quieres ir',
//                       //   labelButton: 'Volver',
//                       //   // onPress: (){}
//                       // );adb backup -noapk ajat.calendario.turnos
//
//                       // / data/data/ ajat.calendario.turnos/app_flutter/ DBC4A.db
//                       // print(notesList.asMap());
//                     },
//                   ),
//                 ],
//               ),
//               body: Column(
//                 children: [
//                   SizedBox(height: 2.h),
//                   Column(
//                     // key: homeController.firstTime.value
//                     //     ? homeController.tutorialController.keyButton8
//                     //     : widget.key,
//                     children: [
//                       Container(
//                         alignment: Alignment.center,
//                         child: TableCalendar(
//                           locale: 'es_ES',
//                           daysOfWeekHeight: 25.h,
//                           rowHeight: 90.h,
//                           headerVisible: Platform.isMacOS ? true : false,
//                           calendarStyle: const CalendarStyle(
//                             outsideDaysVisible: false,
//                           ),
//                           // holidayPredicate: (day) {
//                           //   // print('comprobar refactor' '${calendarController.hasEvent(day)}'
//                           //   // );
//                           //   // return calendarController.hasEvent(day);
//                           // },
//                           firstDay: DateTime(2000),
//                           lastDay: DateTime(2050),
//                           focusedDay: focusedDayValue,
//                           // calendarFormat: controller.calendarFormat,
//                           onCalendarCreated: (PageController controller) {
//                             pageController = controller;
//                           },
//                           onPageChanged: (day) {
//                             ref
//                                 .read(focusedDayProvider.notifier)
//                                 .update((state) => day);
//                           },
//                           eventLoader: (day) {
//                             return [
//                               // calendarController.getTurnosOfDay(day),
//                               // calendarController.hasEvent(day)
//                               // _HobbyEvent(day, 'Hobby'),
//
//                               // _HobbyEvent(day, 'Hobby'),
//                             ];
//                           },
//
//                           // eventLoader: (day)[calendarController.getTurnosOfDay],
//                           startingDayOfWeek: StartingDayOfWeek.monday,
//                           // selectedDayPredicate: (day) {
//                           //   return isSameDay(calendarController.selectedDayRx.value, day);
//                           // },
//                           selectedDayPredicate: (DateTime date) {
//                             return isSameDay(selectedDayValue, date);
//                           },
//                           onDaySelected:
//                               (DateTime selectDay, DateTime focusDay) {
//                             ref
//                                 .read(focusedDayProvider.notifier)
//                                 .update((state) => focusDay);
//                             ref
//                                 .read(selectedDayProvider.notifier)
//                                 .update((state) => selectDay);
//                             // showDialog(
//                             //     context: context,
//                             //     builder: (context) => ScheduleDialog(pageController));
//                           },
//                           // onDaySelected: _onDaySelected,
//                           // onDayLongPressed: _onDaySelectedLongPress,
//                           // onFormatChanged: (format) {
//                           //   if (controller.calendarFormat != format) {
//                           //     controller.changeCalendarFormat(format);
//                           //   }
//                           // },
//                           // onCalendarCreated: (_) {
//                           //   calendarController.update;
//                           // },
//                           // onPageChanged: (focusedDay) {
//                           //   // widget.focusedDay.value = focusedDay;
//                           //   // calendarController.focusDayRx.value =
//                           //   //     widget.focusedDay.value;
//                           // },
//                           // calendarBuilders: calendarBuilders(notas),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 5.h),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     child: LineWidget(),
//                   ),
//                   // SizedBox(height: 2.h),
//                   // Obx(() => _buildSelectedDay()),
//                   SizedBox(height: 2.h),
//
//                   // Expanded(
//                   //   // key: homeController.firstTime.value
//                   //   //     ? homeController.tutorialController.keyButton9
//                   //   //     : widget.key,
//                   //   // child: _buildListEvent(context, selectedDayNotas),
//                   // )
//                 ],
//               )),
//         ));
//   }
// }

class AppDialog {
  static final AppDialog _singleton = AppDialog._internal();

  factory AppDialog() {
    return _singleton;
  }

  AppDialog._internal();

  bool _isShown = false;

  void showErrorAlert(BuildContext context, dynamic e) {
    if (_isShown) {
      return;
    }

    _isShown = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content:
              Text(e.toString(), style: ThemeData.dark().textTheme.bodyText1),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.zero,
              child: TextButton(
                // color: ThemeData.dark().textTheme.bodyText1!.color!,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('buton'),
              ),
            )
          ],
        );
      },
    ).then((res) async {
      _isShown = false;
    });
  }
}
