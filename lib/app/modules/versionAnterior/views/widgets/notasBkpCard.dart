import 'dart:math';

import 'package:calendario2/app/data/model/previousDatabase/previousTaskModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';

import '../../../../../config/theme/my_colors.dart';


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

    return Card(
      color: MyColors.menuCardBackgroundDark,

      // padding: EdgeInsets.only(left: 4.w, right: 4.w),
      // decoration: BoxDecoration(
      //
      //   borderRadius: BorderRadius.circular(5.r),
      //   boxShadow: [buildBoxShadow(color, context)],
      // ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              height: 75.h,
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
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin:
                          EdgeInsets.only(bottom: 3.h, right: 4.w),
                          child: Text(
                            '${noteData.day}  ${noteData.month} ${noteData.year}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 22.sp,
                                // color: Colors.grey.shade300,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Spacer(),

                        Container(
                          width: 220.w,
                          height: 75.h,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 4.h, left: 6.w),
                          child: CustomScrollView(
                              slivers: [
                                SliverFillRemaining(fillOverscroll: true,
                                  hasScrollBody: false,
                                  child: Text(
                                    maxLines: 12,
                                    noteData.note!,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                )]
                          ),
                        ),

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
