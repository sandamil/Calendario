import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingTile extends StatelessWidget {
  final Widget? icon;
  final String? btnText;
  final Widget? trailing;
  final void Function()? onPressed;

  const SettingTile(
      {Key? key, this.icon, this.btnText, this.trailing, this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 15.w),
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          height: 50.h,
          width: 325.w,
          child: Row(
            children: [
              SizedBox(
                  height: 40.h,
                  child: FittedBox(fit: BoxFit.cover, child: icon)),
              SizedBox(width: 20.w),
              Text(
                btnText!,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  // fontFamily: ConstantData.ralewayFont,
                  fontSize: 20.sp,
                  color: MyColors.textColor,
                ),
              ),
              const Spacer(),
              Container(
                child: trailing,
              )
            ],
          ),
        ),
      ),
    );
  }
}
