import 'dart:collection';
import 'dart:io';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';

import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/views/widgets/taskCard.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/table_calendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config/util/constant.dart';

import '../../../components/toast.dart';
import '../../../controllers/ads_controller.dart';
import '../../../data/local/calendarDatabase.dart';
import '../../../data/local/taskDatabase.dart';
import '../../../data/model/cuadranteDay.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/calendar/dialog_onLongPress_calendar.dart';

typedef HomeCallback = void Function(int id, DateTime selectedDate);
typedef HomeCallback2 = void Function();
typedef HomeCallbackSetState = void Function(DateTime selectedDate);

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  static get notasListController => Get.put(NotasListController());

  State<HomeView> createState() => _HomeViewState();

  static notaHomeDelete(
      BuildContext context, id, selectedDay, focusedDay) async {
    print('HomeView');
    final calendarController = Get.put(CalendarController());

    await NotasDB.instance.delete(id);
    // Navigator.pop(context);

    Toast.toast(context, msg: "Eliminada!");
    _HomeViewState().setStateHomeFOcusday(selectedDay, focusedDay);
  }
}

class _HomeViewState extends State<HomeView> {
  final isDialOpen = ValueNotifier(false);
  final adcontroller = Get.find<AdsController>();
  final homeController = Get.find<HomeController>();
  final calendarController = Get.put(CalendarController());

  DateTime? _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  setStateHomeFOcusday(selectedDay, focusedDay) {
    print('setStateHomeFOcusday');
    calendarController.getListEvent();
    setState(() {
      calendarController.selectedDayNotas =
          calendarController.getNotasOfDay(selectedDay);
    });

    calendarController.getNotasOfDay(selectedDay);

    // _onDaySelected(selectedDay, focusedDay);
    // _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
    calendarController.cuadrante.value =
        await CalendarioDB.db.getCuadranteList();

    setState(() {
      calendarController.cuadranteMap.clear();
      for (CuadranteDay turno in calendarController.cuadrante) {
        calendarController.cuadranteMap
            .putIfAbsent(turno.dateTime!, () => <CuadranteDay>[]);
        List<CuadranteDay>? turnoData =
            calendarController.cuadranteMap[turno.dateTime];
        turnoData!.add(turno);
        calendarController.cuadranteMap.update(turno.dateTime!, (data) {
          return turnoData;
        });
      }
      calendarController.isReady.value = true;
    });
    print('getCuadrante');

    return calendarController.cuadranteMap;
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(calendarController.selectedDay, selectedDate)) {
      setState(() {
        calendarController.selectedDay = selectedDate;
        calendarController.focusedDay.value = focusedDate;
      });
    }
    calendarController.selectedDayTurnos.value =
        calendarController.getTurnosOfDay(selectedDate);
    calendarController.selectedDayNotas =
        calendarController.getNotasOfDay(selectedDate);
  }

  onDaySelectedLongPress(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(calendarController.selectedDay, selectedDate)) {
      setState(() {
        calendarController.selectedDay = selectedDate;
        calendarController.focusedDay.value = focusedDate;
      });
    }
    calendarController.selectedDayTurnos.value =
        calendarController.getTurnosOfDay(selectedDate);
    calendarController.selectedDayNotas =
        calendarController.getNotasOfDay(selectedDate);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return OnLongPressDialog(
            selectedDate: selectedDate,
            getCuadrante: getCuadrante(),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _selectedDays.add(calendarController.focusedDay.value);
    getCuadrante();
    calendarController.getListEvent();
    // _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    calendarController.selectedDayTurnos.value =
        calendarController.getTurnosOfDay(calendarController.focusedDay.value);
    calendarController.selectedDayNotas =
        calendarController.getNotasOfDay(calendarController.focusedDay.value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            //? to close quick order floating if its open when click back btn
            if (isDialOpen.value) {
              isDialOpen.value = false;
              return false;
            } else {
              homeController.appCloseConfirm(context);
            }
          }
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    key: homeController.firstTime.value
                        ? homeController.tutorialController.keyButton6
                        : widget.key,
                    icon: Icon(
                      Icons.menu,
                      color: PRIMARY_COLOR,
                      size: 26.sp,
                    ),
                    onPressed: () {
                      adcontroller.staticHomeAd.dispose();
                      Get.to(() => const MenuView(),
                          duration: const Duration(milliseconds: 100),
                          transition: Transition.leftToRight);
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              ),
              title: SelectedDayWidget(),
              actions: [
                IconButton(
                  key: homeController.firstTime.value
                      ? homeController.tutorialController.keyButton7
                      : widget.key,
                  color: PRIMARY_COLOR,
                  icon: const Icon(
                    Icons.today,
                  ),
                  tooltip: 'today',
                  onPressed: () {
                    // controller.firstTime.value = true;
                    // controller.tutorialController.showTutorial(context, 'home');
                    Get.toNamed('/version-anterior');
                    // CustomDialog.showPopUpInfo(
                    //   title: 'Volver a HOY',
                    //   description: 'Selecciona Mes al que quieres ir',
                    //   labelButton: 'Volver',
                    //   // onPress: (){}
                    // );adb backup -noapk ajat.calendario.turnos

                    // / data/data/ ajat.calendario.turnos/app_flutter/ DBC4A.db
                    // print(notesList.asMap());
                  },
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isAndroid
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      // MyTheme.changeTheme();
                    },
                    label: adcontroller.staticAdHomeLoaded.value
                        ? Container(
                            color: Colors.transparent,
                            width:
                                adcontroller.staticHomeAd.size.width.toDouble(),
                            height: adcontroller.staticHomeAd.size.height
                                .toDouble(),
                            alignment: Alignment.bottomCenter,
                            child: AdWidget(
                              ad: adcontroller.staticHomeAd,
                            ),
                          )
                        : const SizedBox(),
                  )
                : null,
            body: Column(
              children: [
                SizedBox(height: 2.h),
                Column(
                  key: homeController.firstTime.value
                      ? homeController.tutorialController.keyButton8
                      : widget.key,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: TableCalendarWidget(
                        onDaySelected: onDaySelected,
                        onDaySelectedLongPress: onDaySelectedLongPress,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: LineWidget(),
                ),
                // SizedBox(height: 2.h),
                // Obx(() => _buildSelectedDay()),
                SizedBox(height: 2.h),

                Expanded(
                  key: homeController.firstTime.value
                      ? homeController.tutorialController.keyButton9
                      : widget.key,
                  child: _buildListEvent(
                      context, calendarController.selectedDayNotas),
                )
              ],
            )));
  }

  Widget _buildListEvent(BuildContext context, List<Task> events) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: events
                  .map(
                    (event) => Column(
                      children: [
                        // CardEvent(event: event),
                        TaskCard(
                          noteData: event,
                          onTapAction:
                              homeController.notasController.openNoteToRead,
                          routeToNotas: false,
                          selectedDay: calendarController.selectedDay,
                          focusedDay: calendarController.focusedDay.value,
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
