// import 'package:calendario2/config/theme/my_colors.dart';
// import 'package:calendario2/config/theme/my_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class DayBuilderWidget extends StatelessWidget {
//   const DayBuilderWidget(
//       {super.key, required this.date, required this.dayType});
//
//   final DateTime date;
//   final String dayType;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(0.5),
//       child: Container(
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//
//         color: dayType == 'outside' ? Colors.white : MyColors.cellColor,
//           // backgroundBlendMode: dayType == 'outside' ? BlendMode.modulate :  BlendMode.darken,
//           border: Border.all(
//             color: dayType == 'today' ? PRIMARY_COLOR : Colors.transparent,
//             width: dayType == 'selected' ? 3.w : 1.w,
//           ),
//           borderRadius: BorderRadius.circular(5.r),
//           // boxShadow: const [
//           //   BoxShadow(
//           //       blurRadius: 2, spreadRadius: -2, offset: Offset(1, 1))
//           // ],
//         ),
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: Text(
//             date.day.toString(),
//             textWidthBasis: TextWidthBasis.longestLine,
//             style: TextStyle(
//               fontSize: 15.sp,
//               // fontFamily: 'FiraCode',
//               color:
//                   dayType == 'outside' ? MyColors.cellColor : MyColors.cellTextColor,
//               fontWeight: dayType == '' ? FontWeight.normal : FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
