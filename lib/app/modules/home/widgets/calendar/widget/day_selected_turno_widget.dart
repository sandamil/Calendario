import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../components/custom_snackbar.dart';

class DaySelecetedTurnoWidget extends StatelessWidget {
  const DaySelecetedTurnoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GetX<CalendarController>(
        init: CalendarController(),
        builder: (c) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                c.selectedEvents.value.isEmpty
                    ? Container()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: c.selectedEvents.value.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onLongPress: (){


                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(

                                    content: const Text("Quieres borrar este Turno?"),
                                    action: SnackBarAction(
                                      onPressed: (){
                                        c.deleteTurnoCuadrante(c.selectedEvents.value[index].id);
                                      },
                                      label: "Borrar este Turno",
                                    ),
                                  )
                              );

                            },


                            child: Container(
                              height: 22.h,
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 2.w),
                              decoration: BoxDecoration(
                                color: HexColor(
                                    c.selectedEvents.value[index].color!),
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
                                  //     '${c.selectedEvents.value[index].dateTime.toString().substring(8, 10)}-${c.selectedEvents.value[index].dateTime.toString().substring(5, 7)}-${c.selectedEvents.value[index].dateTime.toString().substring(0, 4)}',
                                  //     style: TextStyle(
                                  //         fontSize: 14.sp,
                                  //         color: HexColor(c.selectedEvents
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
                                  FittedBox(
                                    child: Text(
                                      c.selectedEvents.value[index].description!,
                                      style: TextStyle(
                                          height: 1.2.h,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: HexColor(c.selectedEvents
                                                          .value[index].color!)
                                                      .computeLuminance() >
                                                  0.5
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 20.w,
                                  // ),
                                  c.selectedEvents.value[index].startHour !=
                                              null &&
                                          c.selectedEvents.value[index].endHour !=
                                              null
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 15.w),
                                          child: FittedBox(
                                            child: Text(
                                              'de ${c.selectedEvents.value[index].startHour.toString()} a ${c.selectedEvents.value[index].endHour.toString()}',
                                              style: TextStyle(
                                                  height: 1.2.h,
                                                  fontSize: 14.sp,
                                                  color: HexColor(c
                                                                  .selectedEvents
                                                                  .value[index]
                                                                  .color!)
                                                              .computeLuminance() >
                                                          0.5
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.only(right: 20.w),
                                        )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                SizedBox(
                  height: 3.h,
                ),
                ...c.selectedNotas.value.map((nota) => Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                      child: GestureDetector(
                        onTap: () {
                          CustomDialog.mostrarTask(nota, context);
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
                                Text(
                                  '${DateTime.fromMillisecondsSinceEpoch(nota.startTimeMilliseconds!).formatDateTime24H}',
                                  style: TextStyle(
                                      height: 1.2.h,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Text(
                                  nota.title!.toUpperCase(),
                                  style: TextStyle(
                                      height: 1.2.h,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Container(
                                  width: 150.w,
                                  child: Text(
                                    nota.notes!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        height: 1.2.h,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
