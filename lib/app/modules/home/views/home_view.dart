import 'dart:collection';
import 'dart:io';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
import '../../../../config/theme/my_fonts.dart';
import '../../../../config/util/constant.dart';
import '../../../../config/util/hexColor.dart';
import '../../../components/custom_dialog.dart';
import '../../../controllers/ads_controller.dart';
import '../../../data/local/calendarDatabase.dart';
import '../../../data/model/cuadranteDay.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/calendar/widget/customAlertDialogDaySelected.dart';
import '../widgets/calendar/widget/customAlertDialogTurnoList.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final isDialOpen = ValueNotifier(false);
  final adcontroller = Get.find<AdsController>();
  final homeController = Get.find<HomeController>();

  final calendarController = Get.put(CalendarController());

  CalendarFormat _calendarFormat = CalendarFormat.month;

  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  deleteTurnoCuadrante(id, DateTime selectedDate) async {
    print('_focusedDay :  ${_focusedDay.value}');

    // adcontroller.staticHomeAd.load();

    CalendarioDB.db.deleteItemID(id);
    print('selectedDate :  ${selectedDate}');
    print('selectedDate :  ${selectedDate}');
    print('_focusedDay 2 :  ${_focusedDay.value}');
    await getCuadrante();
    setState(() => _focusedDay.value = selectedDate);

    Navigator.pop(context);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      calendarController.selectedDayTurnos.value =
          calendarController.getTurnosOfDay(selectedDay);
      calendarController.selectedDayNotas.value =
          calendarController.getNotasOfDay(selectedDay);
      // _selectedEvents.value = _getEventsForDays(_selectedDays);
    }
  }

  _onDaySelectedLongPress(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(_selectedDay, selectedDate)) {
      setState(() {
        _selectedDay = selectedDate;
        _focusedDay.value = focusedDate;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      // calendarController.selectedDayTurnos.value =
      //     calendarController.getTurnosOfDay(selectedDate);
      // calendarController.selectedDayNotas.value =
      //     calendarController.getNotasOfDay(selectedDate);

      // Get.dialog(CustomAlertDilogDaySelected(
      //     x: calendarController.currentX,
      //     y: calendarController.currentY,
      //     selectedDate: selectedDate,
      //     turno: calendarController.turno));
    }
    calendarController.selectedDayTurnos.value =
        calendarController.getTurnosOfDay(selectedDate);
    calendarController.selectedDayNotas.value =
        calendarController.getNotasOfDay(selectedDate);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return
              // CustomAlertDilogDaySelected(
              //       x: calendarController.currentX,
              //       y: calendarController.currentY,
              //       selectedDate: selectedDate,
              //       turno: calendarController.turno);

              SizedBox(
            height: Get.height,
            width: Get.width - 20.w,
            child: Stack(
              children: [
                Positioned(
                  // left: x,
                  top: calendarController.currentY - 40.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          width: Get.width - 20.w,
                          child: Stack(
                            children: [
                              Positioned(
                                left: calendarController.currentX - 20.w,
                                child: CustomPaint(
                                    size: const Size(35, 35),
                                    painter: DrawTriangle()),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 220,
                          width: Get.width - 20.w,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: PRIMARY_COLOR),
                            color: MyColors.backgroundColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.r),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 2.h),
                              Container(
                                color: MyColors.backgroundColor,
                                height: 150,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      calendarController
                                              .selectedDayTurnos.isEmpty
                                          ? Container()
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: calendarController
                                                  .selectedDayTurnos.length,
                                              itemBuilder: (context, index) {
                                                return Slidable(
                                                  endActionPane: ActionPane(
                                                    motion:
                                                        const DrawerMotion(),
                                                    extentRatio: 0.3,
                                                    children: [
                                                      SlidableAction(
                                                        label: 'Eliminar',
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5.r)),
                                                        backgroundColor:
                                                            Colors.redAccent,
                                                        // icon: Icons.send,
                                                        onPressed: (context) {
                                                          deleteTurnoCuadrante(
                                                              calendarController
                                                                  .selectedDayTurnos[
                                                                      index]
                                                                  .id, selectedDate);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  child: Container(
                                                    height: 22.h,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 1.h,
                                                            horizontal: 2.w),
                                                    decoration: BoxDecoration(
                                                      color: HexColor(
                                                          calendarController
                                                              .selectedDayTurnos[
                                                                  index]
                                                              .color!),
                                                      border: Border.all(
                                                          width: 0.8.r),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.r),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 2.w,
                                                            vertical: 2.h),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        // FittedBox(
                                                        //   child: Text(
                                                        //     '${calendarController.selectedEvents.value[index].dateTime.toString().substring(8, 10)}-${calendarController.selectedEvents.value[index].dateTime.toString().substring(5, 7)}-${calendarController.selectedEvents.value[index].dateTime.toString().substring(0, 4)}',
                                                        //     style: TextStyle(
                                                        //         fontSize: 14.sp,
                                                        //         color: HexColor(calendarController.selectedEvents
                                                        //                         .value[index].color!)
                                                        //                     .computeLuminance() >
                                                        //                 0.5
                                                        //             ? Colors.black
                                                        //             : Colors.white),
                                                        //   ),
                                                        // ),
                                                        // SizedBox(
                                                        //   width: 20.w,
                                                        // ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 6.0),
                                                          child: FittedBox(
                                                            child: Text(
                                                              calendarController
                                                                  .selectedDayTurnos[
                                                                      index]
                                                                  .description!,
                                                              style: TextStyle(
                                                                  height: 1.2.h,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: HexColor(calendarController.selectedDayTurnos[index].color!)
                                                                              .computeLuminance() >
                                                                          0.5
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //   width: 20.w,
                                                        // ),
                                                        calendarController
                                                                        .selectedDayTurnos[
                                                                            index]
                                                                        .startHour !=
                                                                    null &&
                                                                calendarController
                                                                        .selectedDayTurnos[
                                                                            index]
                                                                        .endHour !=
                                                                    null
                                                            ? Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 15
                                                                            .w),
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                    'de ${calendarController.selectedDayTurnos[index].startHour.toString()} a ${calendarController.selectedDayTurnos[index].endHour.toString()}',
                                                                    style: TextStyle(
                                                                        height: 1.2
                                                                            .h,
                                                                        fontSize: 14
                                                                            .sp,
                                                                        color: HexColor(calendarController.selectedDayTurnos[index].color!).computeLuminance() >
                                                                                0.5
                                                                            ? Colors.black
                                                                            : Colors.white),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right: 20
                                                                            .w),
                                                              ),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.arrow_back,
                                                          size: 16,
                                                          color: MyColors
                                                              .textColor,
                                                        ),
                                                        Icon(
                                                          Icons.delete_forever,
                                                          size: 18,
                                                          color: MyColors
                                                              .textColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      ...calendarController.selectedDayNotas
                                          .map((nota) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 2.w),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    MyCustomDialog.mostrarTask(
                                                        nota, context);
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.w),
                                                      decoration: BoxDecoration(
                                                        color: MyColors
                                                            .cellSelectedColor,
                                                        border: Border.all(
                                                            color: MyColors
                                                                .borderAccentLine,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.r),
                                                      ),
                                                      height: 22.h,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 4.w,
                                                          ),
                                                          SizedBox(
                                                            width: 40.w,
                                                            child: Text(
                                                              DateTime.fromMillisecondsSinceEpoch(
                                                                      nota.startTimeMilliseconds!)
                                                                  .formatDateTime24H,
                                                              style: TextStyle(
                                                                  height: 1.2.h,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4.w,
                                                          ),
                                                          SizedBox(
                                                            width: 90.w,
                                                            child: Text(
                                                              nota.title!
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  height: 1.2.h,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4.w,
                                                          ),
                                                          SizedBox(
                                                            width: 170.w,
                                                            child: Text(
                                                              nota.notes!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  height: 1.2.h,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(2.h),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await calendarController.fetchTurno();
                                          
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              // adcontroller.staticHomeAd.dispose();
                                              return Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: PRIMARY_COLOR),
                                                          // color: theme.scaffoldBackgroundColor,
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(5.r),
                                                          ),
                                                        ),
                                                        child: SingleChildScrollView(
                                                          child: Wrap(
                                                            alignment: WrapAlignment.spaceAround,
                                                            // runSpacing: 1.h,
                                                            children: <Widget>[
                                                              ...calendarController.turno.map((m) {
                                                                return Padding(
                                                                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(

                                                                      side: BorderSide(width: 0.8.r),

                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(5.r),
                                                                      ),
                                                                      backgroundColor: HexColor(m.color!),
                                                                    ),
                                                                    child: Container(

                                                                      alignment: Alignment.center,
                                                                      height: 20.h,
                                                                      width: 75.w,
                                                                      child: Text(
                                                                        m.description!,
                                                                        style: TextStyle(
                                                                            fontSize: 12.sp,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: HexColor(m.color!).computeLuminance() > 0.5 ? Colors.black : Colors.white
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onPressed: () async {

                                                                      await CalendarioDB.db.addCuadranteItem(
                                                                        CuadranteDay(
                                                                          cuadranteName: 'Turnos sueltos',
                                                                          dateTime: DateTime.parse(selectedDate.toString().substring(0, 10)),
                                                                          color: m.color,
                                                                          description: m.description,
                                                                          endHour: m.endHour,
                                                                          startHour: m.startHour,
                                                                          title: m.title,
                                                                        ),
                                                                      );
                                                                      // await calendarController.getCuadrante();
                                                                      // adcontroller.staticHomeAd.load();
                                                                      await getCuadrante();
                                                                      setState(() => _focusedDay.value = selectedDate);

                                                                      Navigator.pop(context);                                                                      // Get.offAllNamed('/home');
                                                                    },
                                                                  ),
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );


                                            },
                                          );


                                        },
                                        child: const Text("Añade Turno"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(2.h),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.toNamed('/add-notas',
                                              arguments: selectedDate
                                                  .millisecondsSinceEpoch);
                                        },
                                        child: const Text("Añade Nota"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });

    // Get.dialog(CustomAlertDilogDaySelected(
    //     x: calendarController.currentX,
    //     y: calendarController.currentY,
    //     selectedDate: selectedDate,
    //     turno: calendarController.turno));
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

      print('get cuadrante =============');
    });
    return calendarController.cuadranteMap;
  }

  @override
  void initState() {

    print('_focusedDay initState :  ${_focusedDay.value}');
    print('_focusedDay initState :  ${_focusedDay.value}');
    print('_focusedDay initState :  ${_focusedDay.value}');
    print('_focusedDay initState :  ${_focusedDay.value}');

    super.initState();
    _selectedDays.add(_focusedDay.value);
    getCuadrante();
    calendarController.getListEvent();
    // _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    calendarController.selectedDayTurnos.value =
        calendarController.getTurnosOfDay(_focusedDay.value);
    calendarController.selectedDayNotas.value =
        calendarController.getNotasOfDay(_focusedDay.value);
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (TapDownDetails details) =>
              calendarController.onTapDown(details),
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
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
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
                              width: adcontroller.staticHomeAd.size.width
                                  .toDouble(),
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
                        child: TableCalendar(
                          locale: 'es_ES',
                          daysOfWeekHeight: 25.h,
                          rowHeight: 90.h,
                          headerVisible: Platform.isMacOS ? true : false,
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                          ),
                          holidayPredicate: (day) {
                            // print('comprobar refactor' '${calendarController.hasEvent(day)}'
                            // );
                            return calendarController.hasEvent(day);
                          },
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2050),
                          focusedDay: _focusedDay.value,
                          // calendarFormat: controller.calendarFormat,
                          eventLoader: calendarController.getTurnosOfDay,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          // selectedDayPredicate: (day) {
                          //   return isSameDay(calendarController.selectedDayRx.value, day);
                          // },
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),

                          onDaySelected: _onDaySelected,
                          onDayLongPressed: _onDaySelectedLongPress,
                          // onFormatChanged: (format) {
                          //   if (controller.calendarFormat != format) {
                          //     controller.changeCalendarFormat(format);
                          //   }
                          // },
                          onCalendarCreated: (_) {
                            calendarController.update;
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay.value = focusedDay;
                            calendarController.focusDayRx.value =
                                _focusedDay.value;
                          },
                          calendarBuilders: _calendarBuilders(),
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
              )),
        ));
  }

  _calendarBuilders() => CalendarBuilders(
        /// =       markerBuilder:          =======================================

        markerBuilder: (context, day, List<CuadranteDay> events) {
          List<Task> notas = calendarController.getNotasOfDay(day);
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
                                    fontSize: 14.sp,
                                    // color: HexColor(turno.color!),
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 3.h,
                  ),
                  ...notas.map((nota) => Padding(
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
                border: Border.all(width: 1.w, color: MyColors.borderCellColor),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: CustomTextStyle.numberCalendar.copyWith(),
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
                border: Border.all(width: 1.w, color: MyColors.borderCellColor),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      day.day.toString(),
                      style: CustomTextStyle.numberCalendar,
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
                  style:
                      CustomTextStyle.numberCalendar.copyWith(fontSize: 15.sp),
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
        dowBuilder: (context, day) {
          final text = DateFormat.E('es').format(day);
          if (day.weekday == DateTime.sunday
              // || day.weekday == DateTime.saturday
              ) {
            return Center(
              child: Text(
                text.toUpperCase(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return Center(
            child: Text(
              text.toUpperCase(),
              // style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );
  Widget _buildListEvent(BuildContext context, List<Task> events) {
    // final calendarVM = Get.find<CalendarController>();
    // final selectedDay = calendarVM.selectedDayRx;
    // List events = calendarVM.getEventsOfDay(selectedDay.value);

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
                            routeToNotas: false)
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

// class HomeView extends GetView<HomeController> {
//   HomeView({Key? key}) : super(key: key);
//   final adcontroller = Get.find<AdsController>();
//   final calendarController = Get.find<CalendarController>();
//   final isDialOpen = ValueNotifier(false);
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: () async {
//         if (Platform.isAndroid) {
//           //? to close quick order floating if its open when click back btn
//           if (isDialOpen.value) {
//             isDialOpen.value = false;
//             return false;
//           } else {
//             controller.appCloseConfirm(context);
//           }
//         }
//         return false;
//       },
//       child: Obx(() {
//
//         return GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onTapDown: (TapDownDetails details) =>
//               calendarController.onTapDown(details),
//           child: Scaffold(
//               appBar: AppBar(
//                 centerTitle: false,
//                 elevation: 0,
//                 backgroundColor: Colors.transparent,
//                 leading: Builder(
//                   builder: (BuildContext context) {
//                     return IconButton(
//                       key: controller.firstTime.value
//                           ? controller.tutorialController.keyButton6
//                           : key,
//                       icon: Icon(
//                         Icons.menu,
//                         color: PRIMARY_COLOR,
//                         size: 26.sp,
//                       ),
//                       onPressed: () {
//                         adcontroller.staticHomeAd.dispose();
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
//                     key: controller.firstTime.value
//                         ? controller.tutorialController.keyButton7
//                         : key,
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
//               floatingActionButtonLocation:
//                   FloatingActionButtonLocation.centerDocked,
//               floatingActionButton: Platform.isAndroid
//                   ? FloatingActionButton.extended(
//                       backgroundColor: Colors.transparent,
//                       elevation: 0,
//                       onPressed: () {
//                         // MyTheme.changeTheme();
//                       },
//                       label: adcontroller.staticAdHomeLoaded.value
//                           ? Container(
//                               color: Colors.transparent,
//                               width: adcontroller.staticHomeAd.size.width
//                                   .toDouble(),
//                               height: adcontroller.staticHomeAd.size.height
//                                   .toDouble(),
//                               alignment: Alignment.bottomCenter,
//                               child: AdWidget(
//                                 ad: adcontroller.staticHomeAd,
//                               ),
//                             )
//                           : const SizedBox(),
//                     )
//                   : null,
//               body: Column(
//                 children: [
//                   SizedBox(height: 2.h),
//                   CalendarWidget(
//                     key: controller.firstTime.value
//                         ? controller.tutorialController.keyButton8
//                         : key,
//                   ),
//                   SizedBox(height: 5.h),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     child: LineWidget(),
//                   ),
//                   // SizedBox(height: 2.h),
//                   // Obx(() => _buildSelectedDay()),
//                   SizedBox(height: 2.h),
//                   Obx(() {
//                     return Expanded(
//                       key: controller.firstTime.value
//                           ? controller.tutorialController.keyButton9
//                           : key,
//                       child: _buildListEvent(context, calendarController.selectedDayNotas),
//                     );
//                   }),
//                 ],
//               )),
//         );
//       }),
//     );
//   }
//
//   Widget _buildListEvent(BuildContext context, List<Task> events) {
//     // final calendarVM = Get.find<CalendarController>();
//     // final selectedDay = calendarVM.selectedDayRx;
//     // List events = calendarVM.getEventsOfDay(selectedDay.value);
//
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SingleChildScrollView(
//             child: Column(
//               children: events
//                   .map(
//                     (event) => Column(
//                       children: [
//                         // CardEvent(event: event),
//                         TaskCard(
//                             noteData: event,
//                             onTapAction:
//                                 controller.notasController.openNoteToRead, routeToNotas: false)
//                       ],
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// // Widget _buildSelectedDay() {
// //   final calendarVM = Get.find<CalendarController>();
// //
// //   final selectedDay = calendarVM.selectedDay.value;
// //   String formattedDate =
// //       '${selectedDay.day} / ${selectedDay.month} / ${selectedDay.year}';
// //
// //   return Row(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       Container(
// //         margin: const EdgeInsets.only(left: 10),
// //         child: const Text(
// //           'Notas para el dia:',
// //           // style: AppTextStyle.titleTextStyle(),
// //         ),
// //       ),
// //       const SizedBox(height: 5),
// //       Container(
// //         margin: const EdgeInsets.only(left: 10),
// //         child: Text(
// //           formattedDate + ':',
// //           // style: AppTextStyle.disableTextStyle(),
// //         ),
// //       ),
// //     ],
// //   );
// // }
// }
