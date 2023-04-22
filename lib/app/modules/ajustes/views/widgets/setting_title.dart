import 'package:calendario2/config/util/constant.dart';
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
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 15.w),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 50.h,
          width: 325.w,
          child: Row(
            children: [
              Container(
                  height: 40.h,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: icon)),
              SizedBox(width: 20.w),
              Text(
                btnText!,
                style: theme.textTheme.headlineSmall?.copyWith(  fontFamily: ConstantData.ralewayFont,
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
