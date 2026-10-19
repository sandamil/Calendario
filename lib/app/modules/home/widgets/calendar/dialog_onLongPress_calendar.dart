import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/customAlertDialogDaySelected.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/cuadranteDay.dart';
import 'dialog_addTurnosTo_calendar.dart';
import 'turnos_notas_onHomeDialog.dart';

class OnLongPressDialog extends StatefulWidget {
  OnLongPressDialog({
    required this.selectedDate,
    required this.getCuadrante,
    required this.tapPosition,
    super.key,
  });
  final DateTime selectedDate;
  final Offset tapPosition;
  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante;

  @override
  State<OnLongPressDialog> createState() => _OnLongPressDialogState();
}

class _OnLongPressDialogState extends State<OnLongPressDialog> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width - 20.w,
      child: Stack(
        children: [
          Positioned(
            // left: x,
            top: widget.tapPosition.dy - 40.h,
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
                          left: widget.tapPosition.dx - 20.w,
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
                        const TurnosNotasOnHomeDialog(),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(2.h),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        // adcontroller.staticHomeAd.dispose();
                                        return AddTurnostoCalendar(
                                          selectedDate: widget.selectedDate,
                                          getCuadrante: widget.getCuadrante,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Añade Turno",
                                    style: CustomTextStyle.button,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(2.h),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push('/add-notas',
                                        extra: widget.selectedDate
                                            .millisecondsSinceEpoch);
                                  },
                                  child: Text(
                                    "Añade Nota",
                                    style: CustomTextStyle.button,
                                  ),
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
  }
}
