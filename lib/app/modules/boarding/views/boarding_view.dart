import 'dart:ui';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/smooth_page_indicator/components/effects/worm_effect.dart';
import 'package:calendario2/config/util/smooth_page_indicator/smooth_page_indicator.dart';
import 'package:calendario2/config/util/transformer_page_view/transformer_page_view.dart';
import 'package:calendario2/config/util/transformers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/boarding_controller.dart';
import 'widgets/boarding_page.dart';

class BoardingView extends GetView<BoardingController> {
  const BoardingView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BoardingView'),
      //   centerTitle: true,
      // ),
      body: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: controller.pageController,
              itemCount: controller.info.length,
              itemBuilder: (_, __) => Container(color: const Color(0xff495057)),
            ),
            TransformerPageView.children(
              scrollDirection: Axis.horizontal,
              transformer: DeepthPageTransformer(),
              duration: const Duration(milliseconds: 900),
              onPageChanged: controller.onPageChanged,
              controller: controller.tController,
              children: controller.info
                  .map(
                    (value) => BoardingPage(data: value),
                  )
                  .toList(),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    height: 100.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: Colors.white.withOpacity(0.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 30.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SmoothPageIndicator(
                            controller: controller.pageController,
                            count: 7,
                            effect:  WormEffect(
                              activeDotColor: PRIMARY_COLOR,
                              dotWidth: 10.w,
                              dotHeight: 10.h,
                              spacing: 7.w,
                            ),
                          ),
                          InkWell(
                            onTap: controller.onButtonPressed,
                            child: Obx(
                              () => Text(
                                controller.currentPage >
                                        controller.info.length - 2
                                    ? 'FIN'
                                    : '',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
