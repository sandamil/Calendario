import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SizedBox(
      height: 100.h,
      child: Padding(
        padding: EdgeInsets.only(top: 30.h, left: 5.w, right: 5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(30.h),
              child: Icon(
                Icons.menu, // set your color here
                size: 40.sp,
                // color: Theme
                //     .of(context)
                //     .textTheme
                //     .titleLarge!
                //     .color,
                // key: keyButton6,
              ),
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Menu(__selectedDay, _events),
                //     ));
              },
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 30.w,
                  ),
                  child: Text(
                    "Calendario",
                    style: TextStyle(
                      fontSize: MyFonts.headline2TextSize,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

//          IconButton(
//            icon: Icon(Icons.info, color: Colors.redAccent),
//            tooltip: '',
//            onPressed: () {
//              _showTutorial(context: context);
//            },
//          ),

//          IconButton(
//              icon: Icon(Icons.transfer_within_a_station,),
//              onPressed: () {
//                Navigator.push(context, MaterialPageRoute(builder: (context) => TaskListVIew(__selectedDay, _events),),);
//              })
//    ,

            IconButton(
              icon: Icon(
                Icons.today,
                size: 40.sp,
                // key: keyButton7,
              ),
              // color: Theme
              //     .of(context)
              //     .textTheme
              //     .titleLarge!
              //     .color,
              tooltip: "Hoy",
              onPressed: () {
                // setState(
                //       () {
                //     _calendarController.setSelectedDay(DateTime.now(),
                //         runCallback: true);
                //   },
                // );
              },
            ),
            SizedBox(width: 10.w)
          ],
        ),
      ),
    );
  }
}


