import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../components/custom_dialog.dart';
import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../controllers/calendar_controller.dart';

class TurnosNotasOnHomeDialog extends StatefulWidget {
  TurnosNotasOnHomeDialog(BuildContext context, {super.key});

  @override
  State<TurnosNotasOnHomeDialog> createState() =>
      _TurnosNotasOnHomeDialogState();
}

class _TurnosNotasOnHomeDialogState extends State<TurnosNotasOnHomeDialog> {
  final calendarController = Get.find<CalendarController>();

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
    return calendarController.cuadranteMap;
  }

  deleteTurnoCuadrante(id, DateTime selectedDate) async {
    CalendarioDB.db.deleteItemID(id);

    await getCuadrante();
    setState(() => calendarController.focusedDay.value = selectedDate);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.backgroundColor,
      height: 150,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            calendarController.selectedDayTurnos.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: calendarController.selectedDayTurnos.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.3,
                          children: [
                            SlidableAction(
                              label: 'Eliminar',
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.r)),
                              backgroundColor: Colors.redAccent,
                              // icon: Icons.send,
                              onPressed: (context) {
                                deleteTurnoCuadrante(
                                    calendarController
                                        .selectedDayTurnos[index].id,
                                    calendarController.selectedDay!);
                              },
                            ),
                          ],
                        ),
                        child: Container(
                          height: 22.h,
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: HexColor(calendarController
                                .selectedDayTurnos[index].color!),
                            border: Border.all(width: 0.8.r),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 2.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                padding: const EdgeInsets.only(left: 6.0),
                                child: FittedBox(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                        height: 1.2.h,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor(calendarController
                                                        .selectedDayTurnos[
                                                            index]
                                                        .color!)
                                                    .computeLuminance() >
                                                0.5
                                            ? Colors.black
                                            : Colors.white),
                                    child: Text(
                                      calendarController
                                          .selectedDayTurnos[index]
                                          .description!,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 20.w,
                              // ),
                              calendarController.selectedDayTurnos[index]
                                              .startHour !=
                                          null &&
                                      calendarController
                                              .selectedDayTurnos[index]
                                              .endHour !=
                                          null
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 15.w),
                                      child: FittedBox(
                                        child: DefaultTextStyle(
                                          style: TextStyle(
                                              height: 1.2.h,
                                              fontSize: 14.sp,
                                              color: HexColor(calendarController
                                                              .selectedDayTurnos[
                                                                  index]
                                                              .color!)
                                                          .computeLuminance() >
                                                      0.5
                                                  ? Colors.black
                                                  : Colors.white),
                                          child: Text(
                                            'de ${calendarController.selectedDayTurnos[index].startHour.toString()} '
                                            'a ${calendarController.selectedDayTurnos[index].endHour.toString()}',
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(right: 20.w),
                                    ),
                              Spacer(),
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: MyColors.textColor,
                              ),
                              Icon(
                                Icons.delete_forever,
                                size: 18,
                                color: MyColors.textColor,
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
            ...calendarController.selectedDayNotas.map((nota) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  child: GestureDetector(
                    onTap: () {
                      MyCustomDialog.mostrarTask(nota, context);
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: MyColors.cellSelectedColor,
                          border: Border.all(
                              color: MyColors.borderAccentLine, width: 1),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        height: 22.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            SizedBox(
                              width: 50.w,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                    height: 1.2.h,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: MyColors.textColor),
                                child: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          nota.startTimeMilliseconds!)
                                      .formatDateTime24H,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            SizedBox(
                              width: 85.w,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                    height: 1.2.h,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: MyColors.textColor),
                                child: Text(
                                  nota.title!.toUpperCase(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            SizedBox(
                              width: 170.w,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                    height: 1.2.h,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: MyColors.textColor),
                                child: Text(
                                  nota.notes!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
