import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRoundMiniBtn extends StatelessWidget {
  final String text;
  final Color color;
  final Function onTap;
  const AppRoundMiniBtn({Key? key, required this.text, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: color,
          minimumSize: Size(70.w, 40.h),
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.r)),
          )),
      onPressed: () {onTap(); },
      child: Text(text,style: TextStyle(fontSize: 18.sp),),
    );
  }
}
