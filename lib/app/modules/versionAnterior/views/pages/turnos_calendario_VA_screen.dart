import 'dart:developer';

import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../ayuda/controllers/ayuda_controller.dart';
import '../../../ayuda/views/widgets/ayuda_group_widget.dart';
import '../../../ayuda/views/widgets/ayuda_row_widget.dart';
import '../../controllers/version_anterior_controller.dart';

class TurnosCalendarioScreen extends GetView<VersionAnteriorController> {
  const TurnosCalendarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 26.sp,
              color: PRIMARY_COLOR,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Turnos en calendario',
            style: CustomTextStyle.appBarTitle(context: context),

          ),
        ),
        body: Obx(() {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.turnosCalendarioBkpList.value.length,
              itemBuilder: (context, index) {
                return Container(
                  // padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                        margin:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                        height: 56.h,
                        child: Material(
                            borderRadius: BorderRadius.circular(5.r),
                            clipBehavior: Clip.antiAlias,
                            color: HexColor(controller
                                .turnosPersonalizadosBkpList
                                .value[controller.turnosCalendarioBkpList.value[index].position!]
                                .color!).withOpacity(0.3),
                            child: InkWell(
                                borderRadius: BorderRadius.circular(5.r),
                                onTap: () {
                                  // onTapAction(noteData);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[


                                      Container(
                                        margin: EdgeInsets.only(left: 20.w,
                                            bottom: 3.h, right: 4.w),
                                        child: Text(
                                          '${controller
                                              .turnosCalendarioBkpList
                                              .value[index]
                                              .day}  ${controller
                                              .turnosCalendarioBkpList
                                              .value[index]
                                              .month} ${controller
                                              .turnosCalendarioBkpList
                                              .value[index]
                                              .year}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              // color: Colors.grey.shade300,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                       SizedBox(width: 60.w,),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            child: Obx(() {
                                              return Text(
                                                controller
                                                    .turnosPersonalizadosBkpList
                                                    .value[controller.turnosCalendarioBkpList.value[index].position!]
                                                    .title!,
                                                style: TextStyle(
                                                    color: HexColor( controller
                                                        .turnosPersonalizadosBkpList
                                                        .value[controller.turnosCalendarioBkpList.value[index].position!]
                                                        .color!),
                                                    // fontFamily: 'ZillaSlab',
                                                    fontSize: 24.sp,
                                                    fontWeight: FontWeight
                                                        .w800),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )))),
                  ),
                );
              });
        })

      // Container(
      //   child: SingleChildScrollView(
      //     child:
      //
      //
      //
      //
      //
      //
      //     // Obx(() {
      //     //   return Column(
      //     //     // physics: BouncingScrollPhysics(),
      //     //     children: <Widget>[
      //     //       Container(height: 6.h),
      //     //       ...controller.buildTurnosCalendarioList(),
      //     //     ],
      //     //   );
      //     // }),
      //   ),
      // ),
    );
  }
}
