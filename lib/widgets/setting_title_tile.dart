import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingTitleTile extends StatelessWidget {
  final String text;
  const SettingTitleTile(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 19.h, 5.w, 7.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11.sp,
          letterSpacing: .8,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.55),
        ),
      ),
    );
  }
}
