import 'dart:math';

import 'package:calendario2/app/data/model/previousTaskModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';


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

class NotasBkpCard extends StatelessWidget {
  const NotasBkpCard({
    required this.noteData,
    // required this.onTapAction,
    Key? key,
  }) : super(key: key);

  final PreviousTask noteData;
  // final Function(PreviousTask noteData) onTapAction;

  @override
  Widget build(BuildContext context) {
    // NotasViewController notasViewController = NotasViewController();

    Color color =
    colorList.elementAt(Random().nextInt(colorList.length));

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
                                noteData.note!.trim().length <= 20
                                    ? noteData.note!.trim()
                                    : '${noteData.note!.trim().substring(0, 20)}...',
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
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 4.h, left: 6.w),
                                child: Text(
                                  noteData.note!
                                              .trim()
                                              .split('\n')
                                              .first
                                              .length <=
                                          30
                                      ? noteData.note!.trim().split('\n').first
                                      : '${noteData.note!.trim().split('\n').first.substring(0, 30)}...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: 3.h, right: 4.w),
                                child: Text(
                                  '${noteData.day}  ${noteData.month} ${noteData.year}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      // color: Colors.grey.shade300,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )),

      ),
    );
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    return BoxShadow(
        color: color.withAlpha(8), blurRadius: 8, offset: const Offset(1, 1));
  }
}
