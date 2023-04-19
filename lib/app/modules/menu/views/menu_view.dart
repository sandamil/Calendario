import 'package:calendario2/app/modules/CrearCuadrante/views/crear_cuadrante_view.dart';
import 'package:calendario2/app/modules/CrearTurno/views/turno_view.dart';
import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../../config/theme/my_fonts.dart';
import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuAppController> {
  const MenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
            size: 24.sp,
          ),
          color: theme.primaryColor,
          onPressed: () {
            Get.to(() => const HomeView(),
                duration: const Duration(microseconds: 700),
                transition: Transition.rightToLeft);

          },
        ),
        title: Text(
          'Menu',
          style: TextStyles.titleLarge.copyWith(
            fontSize: MyFonts.headline3TextSize,
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
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
                shape: RoundedRectangleBorder(
                    borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: Theme.of(context).hintColor,
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
                          child: Text("Notas",
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),

                onPressed: () {
                  Get.toNamed('/notas');
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
                shape: RoundedRectangleBorder(
                    borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: Theme.of(context).hintColor,
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
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Get.toNamed('/crear-cuadrante');
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
                shape: RoundedRectangleBorder(
                    borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: Theme.of(context).hintColor,
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
                          child: Text("Turnos",
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Get.toNamed('/crear-turno');
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
                shape: RoundedRectangleBorder(
                    borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: Theme.of(context).hintColor,
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
                          child: Text("Ajustes",
                              style: TextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Get.toNamed('/ajustes');
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
                shape: RoundedRectangleBorder(
                    borderRadius: Corners.xmBorder),
                height: qaButtonHeight,
                minWidth: qaButtonWidth,
                color: Theme.of(context).hintColor,
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
                          child: Text("Ayuda",
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Get.toNamed('/ayuda');
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
