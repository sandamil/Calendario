import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/youtubeThumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../config/theme/my_colors.dart';


class VideotutorialesRowWidget extends StatelessWidget {

  final String title;
  final String subtitle;
  final String id;
  final VoidCallback onTap;
  const VideotutorialesRowWidget(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.id,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                SizedBox(
                  height: 150.h,
                  width: MediaQuery.sizeOf(context).width / 2.8,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Text(
                    //   title,
                    //   style: TextStyle(
                    //       color: MyColors.textColor,
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w600),
                    // ),
                    SizedBox(height: 1.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: MyColors.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),

                  ]),
                ),
                SizedBox(
                  height: 150.h,
                    width: MediaQuery.sizeOf(context).width / 2,
                    child: YouTubeThumbnail(id: id)),

              ],
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 12.w),
              child: const Divider(height: 0.3, thickness: 0.3),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
