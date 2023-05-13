
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/theme/my_fonts.dart';
import '../../controllers/version_anterior_controller.dart';


class TurnosPersonalizadosScreen extends GetView<VersionAnteriorController> {
  const TurnosPersonalizadosScreen({Key? key}) : super(key: key);

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
          'Turnos personalizados',
          style: CustomTextStyle.appBarTitle(context: context),

        ),
      ),
      body: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Obx(() {
              return Column(
                // physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Container(height: 6.h),
                  ...controller.buildTurnosPersonalizadosList(),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
