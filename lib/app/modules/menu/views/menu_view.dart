import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuAppController> {
  const MenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _qaButtonHeight = 200.h;
    double _qaButtonWidth = 120.w;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.home,
            size: 30.0,
          ),
          color: Theme.of(context).textTheme.titleLarge!.color,
          tooltip: "Color",
          onPressed: () {
            Get.to(const HomeView(),
                duration: const Duration(milliseconds: 100),
                transition: Transition.rightToLeft);
          },
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.0,
        title: Text(
          'Menu',
          style: TextStyle(
              fontSize: 30.0,
              color: Theme.of(context).textTheme.titleLarge!.color),
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
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                height: _qaButtonHeight,
                minWidth: _qaButtonWidth,
                color: Theme.of(context).hintColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      height: 100.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/notas.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25,
                      bottom: 2,
                      child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Text("Notas",
                              style: TextStyle(
                                fontSize: 55.sp,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),

                onPressed: () {
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
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                height: _qaButtonHeight,
                minWidth: _qaButtonWidth,
                color: Theme.of(context).hintColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 0, bottom: 0),
                      height: 100.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/cuadrante.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 25,
                      bottom: 2,
                      child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Text("Cuadrante",
                              style: TextStyle(
                                fontSize: 55.sp,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/creaCuadrante");
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
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                height: _qaButtonHeight,
                minWidth: _qaButtonWidth,
                color: Theme.of(context).hintColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 0, bottom: 0),
                      height: 150.h,
                      alignment: AlignmentDirectional.topStart,
                      child: Image.asset(
                        "assets/images/turnos.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 0,
                      child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Text("Turnos",
                              style: TextStyle(
                                fontSize: 55.sp,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/TurnoTypeList");
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
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h)),
                height: _qaButtonHeight,
                minWidth: _qaButtonWidth,
                color: Theme.of(context).hintColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      height: 100.h,
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
                          padding: EdgeInsets.all(0),
                          child: Text("Ajustes",
                              style: TextStyle(
                                fontSize: 55.sp,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/ajustes");
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
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                height: _qaButtonHeight,
                minWidth: _qaButtonWidth,
                color: Theme.of(context).hintColor,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      height: 100.h,
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
                          padding: EdgeInsets.all(0),
                          child: Text("Ayuda",
                              style: TextStyle(
                                fontSize: 55.sp,
                                color: Colors.orange,
                              ))),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/ayuda");
                },
                //splashColor: AAThemeData.buttonColor,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }
}
