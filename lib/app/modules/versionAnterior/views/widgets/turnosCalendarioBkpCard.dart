import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import '../../../../data/model/previousDatabase/customShiftTemplate.dart';
import '../../controllers/version_anterior_controller.dart';

List<Color> colorList = [
  Colors.blue,
  Colors.green,
  Colors.indigo,
  Colors.red,
  Colors.cyan,
  Colors.teal,
  Colors.amber.shade900,
  Colors.deepOrange
];

class TurnosCalendarioBkpCard extends StatelessWidget {
  TurnosCalendarioBkpCard({
    required this.noteData,
    // required this.onTapAction,
    Key? key,
  }) : super(key: key);

  final CustomShitTemplate noteData;
  // final Function(PreviousTask noteData) onTapAction;
  final controller = Get.find<VersionAnteriorController>();
  @override
  Widget build(BuildContext context) {
    Color color = colorList.elementAt(Random().nextInt(colorList.length));
    controller.getShiftFromDB(noteData.position);
String fecha = noteData.month.toString();

print(fecha);
    return Container(
      // padding: EdgeInsets.only(left: 4.w, right: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [buildBoxShadow(color, context)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
            height: 56.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [buildBoxShadow(color, context)],
            ),
            child: Material(
                borderRadius: BorderRadius.circular(5.r),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).cardColor,
                child: InkWell(
                    borderRadius: BorderRadius.circular(5.r),
                    onTap: () {
                      // onTapAction(noteData);
                    },
                    splashColor: color.withAlpha(20),
                    highlightColor: color.withAlpha(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 6.h, left: 6.w),
                                child: Text(

                                  controller.shiftName.value,
                                  style: TextStyle(
                                      // fontFamily: 'ZillaSlab',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            margin: EdgeInsets.only(bottom: 3.h, right: 4.w),
                            child: Text(
                              '${noteData.day}  ${noteData.month! + 1} ${noteData.year}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  // color: Colors.grey.shade300,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )))),
      ),
    );
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    return BoxShadow(
        color: color.withAlpha(8), blurRadius: 8, offset: const Offset(1, 1));
  }
}
