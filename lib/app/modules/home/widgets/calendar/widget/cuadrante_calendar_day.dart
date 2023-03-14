import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class CuadranteCalendarDay extends StatelessWidget {

  CalendarController calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Obx(
            () => calendarController.cuadrante.isEmpty
            ? Center(
          child: Text("Data Not Available"),
        )
            : Container(
        height: Get.height / 1.6,
        width: Get.width,
        child: Obx(
    () => ListView.builder(
      shrinkWrap: true,
      itemCount: calendarController.cuadrante.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        Text(
          "${calendarController.cuadrante[index].title}",
          style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
              fontWeight:
              FontWeight.bold),
        );
      },
    ),
    )));
    /*
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: calendarController.selectedEvents
          .map((turno) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 25,
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
        decoration: BoxDecoration(
            color: HexColor(turno.color),
            border: Border.all(width: 0.8),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 3),
            ]),
        margin:
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FittedBox(
              child: Text(
                '${turno.dateTime.toString().substring(8, 10)}-${turno.dateTime.toString().substring(5, 7)}-${turno.dateTime.toString().substring(0, 4)}',
                style: TextStyle(
                    fontSize: 14.sp,
                    color:
                    Theme.of(context).primaryTextTheme.titleLarge!.color),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            FittedBox(
              child: Text(
                turno.description,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:
                    Theme.of(context).primaryTextTheme.titleLarge!.color),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            turno.startHour  != null && turno.endHour != null
            ? FittedBox(
              child: Text(
                '${turno.startHour.toString()} a ${turno.endHour.toString()}',
                style: TextStyle(
                    fontSize: 14.sp,
                    color:
                    Theme.of(context).primaryTextTheme.titleLarge!.color),
              ),
            )
                : Container( padding: EdgeInsets.only(right: 20),)
          ],
        ),
      ))
          .toList(),

    );
*/
  }
}


