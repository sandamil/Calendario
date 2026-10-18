import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../components/custom_dialog.dart';
import '../../../../data/local/calendarDatabase.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';

class TurnosNotasOnHomeDialog extends ConsumerStatefulWidget {
  const TurnosNotasOnHomeDialog({super.key});

  @override
  ConsumerState<TurnosNotasOnHomeDialog> createState() =>
      _TurnosNotasOnHomeDialogState();
}

class _TurnosNotasOnHomeDialogState
    extends ConsumerState<TurnosNotasOnHomeDialog> {
  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    final result = container.read(cuadranteMapProvider);
    if (mounted) setState(() {});
    return result;
  }

  deleteTurnoCuadrante(id, DateTime selectedDate) async {
    await CalendarioDB.db.deleteItemID(id);

    await getCuadrante();
    ProviderScope.containerOf(context, listen: false)
        .read(focusedMonthProvider.notifier)
        .setFocusedDay(selectedDate);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayTurnos = ref.watch(selectedDayTurnosProvider);
    final notas = ref.watch(notasProvider);
    final selectedDate = ref.watch(selectedDayProvider);
    final selectedDayNotas = selectedDate == null
        ? notas.take(0).toList()
        : ref.read(notasProvider.notifier).getNotasOfDay(selectedDate);

    return Container(
      color: MyColors.backgroundColor,
      height: 150,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            selectedDayTurnos.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedDayTurnos.length,
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
                                final selectedDate =
                                    ref.read(selectedDayProvider);
                                if (selectedDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No hay ningún día seleccionado.'),
                                    ),
                                  );
                                  return;
                                }
                                deleteTurnoCuadrante(
                                  selectedDayTurnos[index].id,
                                  selectedDate,
                                );
                              },
                            ),
                          ],
                        ),
                        child: Container(
                          height: 22.h,
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: HexColor(selectedDayTurnos[index].color!),
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
                                        color: HexColor(selectedDayTurnos[index]
                                                        .color!)
                                                    .computeLuminance() >
                                                0.5
                                            ? Colors.black
                                            : Colors.white),
                                    child: Text(
                                      selectedDayTurnos[index].description!,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 20.w,
                              // ),
                              selectedDayTurnos[index].startHour != null &&
                                      selectedDayTurnos[index].endHour != null
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 15.w),
                                      child: FittedBox(
                                        child: DefaultTextStyle(
                                          style: TextStyle(
                                              height: 1.2.h,
                                              fontSize: 14.sp,
                                              color: HexColor(selectedDayTurnos[
                                                                  index]
                                                              .color!)
                                                          .computeLuminance() >
                                                      0.5
                                                  ? Colors.black
                                                  : Colors.white),
                                          child: Text(
                                            'de ${selectedDayTurnos[index].startHour.toString()} '
                                            'a ${selectedDayTurnos[index].endHour.toString()}',
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
            ...selectedDayNotas.map((nota) => Padding(
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
