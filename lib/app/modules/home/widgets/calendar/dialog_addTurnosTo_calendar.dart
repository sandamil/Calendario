import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/customAlertDialogDaySelected.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'turnos_notas_onHomeDialog.dart';

class AddTurnostoCalendar extends ConsumerStatefulWidget {
  AddTurnostoCalendar(
      {required this.selectedDate, required this.getCuadrante, super.key});
  DateTime selectedDate;
  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  @override
  _AddTurnostoCalendarState createState() => _AddTurnostoCalendarState();
}

class _AddTurnostoCalendarState extends ConsumerState<AddTurnostoCalendar> {

  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    final result = container.read(cuadranteMapProvider);
    if (mounted) setState(() {});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final turnos = ref.watch(turnoTypesProvider).value ?? [];
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
                    ...turnos.map((m) {
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
                                  color: HexColor(m.color!).computeLuminance() >
                                          0.5
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                          onPressed: () async {
                            await CalendarioDB.db.addCuadranteItem(
                              CuadranteDay(
                                cuadranteName: 'Turnos sueltos',
                                dateTime: DateTime.parse(widget.selectedDate
                                    .toString()
                                    .substring(0, 10)),
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
                            ProviderScope.containerOf(context, listen: false)
                                .read(focusedMonthProvider.notifier)
                                .setFocusedDay(widget.selectedDate);

                            Navigator.pop(context); // Get.offAllNamed('/home');
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
  }

// final calendarController = Get.find<CalendarController>();
//
// Future<dynamic> showDialogOnLongPressCalendar(
//     context, DateTime selectedDate, currentY, currentX) {}
}
