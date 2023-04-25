import 'package:calendario2/config/util/assets.dart';
import 'package:calendario2/config/util/typewriter/animated_text.dart';
import 'package:calendario2/config/util/typewriter/typewriter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/inicio_controller.dart';

class InicioView extends GetView<InicioController> {
  const InicioView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          repeatForever: true,
          animatedTexts: [
            TypewriterAnimatedText(
              'Ajatsoft\t\u00a9',
              speed: const Duration(microseconds: 50000),
              textStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'Montserrat'
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: controller.width,
          height: controller.width,
          child: Image.asset(AppAsset.logo('logo_app.png')),
        ),
      ),
    );

  }
}
