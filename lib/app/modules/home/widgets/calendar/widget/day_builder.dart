import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DayBuilderWidget extends StatelessWidget {
  const DayBuilderWidget(
      {super.key, required this.date, required this.dayType});

  final DateTime date;
  final String dayType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dayType == 'selected' ? primaryColor : Colors.white,
          border: Border.all(
            color: dayType == 'today' ? primaryColor : Colors.white,
            width: dayType == 'today' ? 3.w : 0.0,
          ),
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: const [
            BoxShadow(
                blurRadius: 2, spreadRadius: -2, offset: Offset(1, 1))
          ],
        ),
        child: Text(
          date.day.toString(),
          textWidthBasis: TextWidthBasis.longestLine,
          style: TextStyle(
            fontSize: 16.sp,
            // fontFamily: 'FiraCode',
            color: dayColors[dayType],
            fontWeight: ['selected', 'today'].contains(dayType)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
