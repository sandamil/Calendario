import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class VideotutorialesViewGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const VideotutorialesViewGroup({Key? key, required this.title, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              color: PRIMARY_COLOR.withOpacity(0.4),
              fontSize: 26,
              fontWeight: FontWeight.w800),
        ),
      ),
      Padding(
        padding:  EdgeInsets.symmetric(horizontal: 120.w),
        child: const Divider(height: 0.5, thickness: 0.3),
      ),
      SizedBox(height: 5.h),
      ...children,
    ]);
  }
}

