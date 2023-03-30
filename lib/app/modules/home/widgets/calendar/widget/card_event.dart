
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CardEvent extends StatelessWidget {
  CardEvent({required this.event});

  final Task event;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        height: 50,
        width: double.maxFinite,
        color: DARK_ORANGE_COLOR,
        child: Row(
          children: [
            Container(
              height: double.maxFinite,
              width: 10,
              color: DARK_BLUE_COLOR,
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      event.title!,
                      overflow: TextOverflow.ellipsis,
                      // style: AppTextStyle.smallTitleTextStyle(),
                    ),
                    // Text(
                    //   // event.timeStart + ' - ' + event.timeEnd,
                    //   // maxLines: 2,
                    //   // overflow: TextOverflow.ellipsis,
                    //   // style: AppTextStyle.defaultTextStyle().copyWith(
                    //     // color: LIGHT_BLUE_COLOR,
                    //   // ),
                    // ),
                    if (event.site != null)
                      GestureDetector(
                        onTap: () {
                          // Get.to(() => WebViewWidget(
                          //     title: event.title, url: event.link!));
                        },
                        child: Text(
                          event.site!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          // style: AppTextStyle.linkTextStyle(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
