import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';

class AyudaRowWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const AyudaRowWidget(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 2.h),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 90.w,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: MyColors.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: MyColors.textColor.withOpacity(0.6),
                      ),
                    ),

                  ]),
                ),
                const Spacer(),
                Icon(Icons.arrow_right,size: 30.sp,)

              ],
            ),
            SizedBox(height: 6.h),
            const Divider(height: 0.5, thickness: 0),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
