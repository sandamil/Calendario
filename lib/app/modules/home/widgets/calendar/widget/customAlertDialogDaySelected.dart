import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'day_selected_turno_widget.dart';

class CustomAlertDilogDaySelected extends StatelessWidget {
  CustomAlertDilogDaySelected(
      {super.key,
      required this.selectedDate,
      required this.turno,
      required this.x,
      required this.y});

  double x;
  double y;
  final DateTime selectedDate;
  final List turno;

  CalendarController calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      // width: Get.width,
      child: Stack(
        children: [
          Positioned(
            // left: x,
            top: y - 40.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 19,
                    width: Get.width,
                    child: Stack(
                      children: [
                        Positioned(
                          left: x,
                          child: CustomPaint(
                              size: Size(20.h, 20.w), painter: DrawTriangle()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 220,
                    width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: MyColors.backgroundColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.r),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 2.h),
                        getContent(),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: turnoBtn(context, selectedDate),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: eventoBtn(context, selectedDate),
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

  Widget getContent() {
    return Container(
      color: MyColors.backgroundColor,
      height: 150,
      child: const DaySelecetedTurnoWidget(),
    );
  }

  Widget turnoBtn(context, selectedDate) {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: ElevatedButton(
        onPressed: () async {
          await calendarController.fetchTurno();
          Navigator.pop(context);
          calendarController.showPopUp(Get.context!, selectedDate, turno);
        },
        child: const Text("+ Turno"),
      ),
    );
  }

  Widget eventoBtn(context, selectedDate) {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed('/add-notas', arguments: selectedDate);
        },
        child: const Text("+ Evento"),
      ),
    );
  }
}

class DrawTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, Paint()..color = MyColors.backgroundColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClipperStack extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0.0, 0.0);
    path.lineTo(0.0, size.height - 10);
    path.lineTo((size.width / 2) - 5, size.height - 10);

    path.lineTo(size.width / 2, size.height);

    path.lineTo((size.width / 2) + 5, size.height - 10);
    path.lineTo(size.width, size.height - 10);

    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
