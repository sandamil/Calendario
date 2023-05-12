import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class BigText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final TextOverflow overflow;

  const BigText(
      {this.color = PRIMARY_COLOR, required this.text, this.size = 0, this.overflow = TextOverflow.fade, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: overflow,
      softWrap: false,
      style: TextStyle(fontSize: size == 0 ? 25.sp : size, color: color, fontWeight: FontWeight.w600),
    );
  }
}
