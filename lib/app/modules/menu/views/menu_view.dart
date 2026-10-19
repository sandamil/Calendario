import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/controllers/ads_provider.dart';

import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/my_fonts.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    double qaButtonHeight = 200.h;
    double qaButtonWidth = 120.w;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: PRIMARY_COLOR,
            size: 26.sp,
          ),
          onPressed: () {
            ProviderScope.containerOf(context, listen: false)
                .read(adsProvider.notifier)
                .ensureHomeBanner();
            context.go('/home');
          },
        ),
        title: Text(
          'Menu',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 20,
              child: MaterialButton(
                elevation: 10,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: MyColors.menuCardBackground,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10.w, bottom: 15.h),
                      height: 120.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/notas.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25.w,
                      bottom: 2.h,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Text("Notas", style: CustomTextStyle.textMenu),
                      ),
                    ),
                  ],
                ),

                onPressed: () {
                  // Get.toNamed('/notas', (r) => false);
                  context.go('/notas');
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) =>
                  //               TaskListVIew(widget.time, widget.events)));
                },
                // splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Expanded(
              flex: 20,
              child: MaterialButton(
                elevation: 10,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: MyColors.menuCardBackground,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10.w, bottom: 15.h),
                      height: 120.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/cuadrante.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25.w,
                      bottom: 2.h,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Text("Cuadrante",
                              style: CustomTextStyle.textMenu)),
                    ),
                  ],
                ),
                onPressed: () {
                  // Get.toNamed('/crear-cuadrante');
                  context.go('/crear-cuadrante');
                },
                //splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Expanded(
              flex: 20,
              child: MaterialButton(
                elevation: 10,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: MyColors.menuCardBackground,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10.w, bottom: 15.h),
                      height: 120.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/turnos.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25.w,
                      bottom: 2.h,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child:
                              Text("Turnos", style: CustomTextStyle.textMenu)),
                    ),
                  ],
                ),
                onPressed: () {
                  // Get.toNamed('/crear-turno');
                  context.go('/crear-turno');

                  // Get.to(() => const TurnoView());
                },
                //splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Expanded(
              flex: 20,
              child: MaterialButton(
                elevation: 10,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: MyColors.menuCardBackground,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10.w, bottom: 15.h),
                      height: 120.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/ajustes.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25.w,
                      bottom: 2.h,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child:
                              Text("Ajustes", style: CustomTextStyle.textMenu)),
                    ),
                  ],
                ),
                onPressed: () {
                  // Get.toNamed('/ajustes');
                  context.go('/ajustes');
                },
                //splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Expanded(
              flex: 20,
              child: MaterialButton(
                elevation: 10,
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: MyColors.menuCardBackground,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10.w, bottom: 15.h),
                      height: 120.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/ajustes.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25,
                      bottom: 2,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child:
                              Text("Ayuda", style: CustomTextStyle.textMenu)),
                    ),
                  ],
                ),
                onPressed: () {
                  context.go('/ayuda');
                },
                //splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
          ],
        ),
      ),
    );
  }
}
