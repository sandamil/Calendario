import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingTitleTile extends StatelessWidget {
  final String text;

  const SettingTitleTile( this.text,
      {Key? key,})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          // fontFamily: ConstantData.ralewayFont,
          fontSize: 20.sp,
          color: MyColors.textDisable,
        ),
      ),
    );
  }
}
