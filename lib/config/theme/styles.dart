import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';

// enum TextFieldState { focus, error, disabled, none }
//
// enum InputStyle { box, line, outline }
//
// enum ShimmerStyle { rectangle, circle }

Widget verticalSpace(double v) {
  return SizedBox(height: v.h);
}

Widget horizontalSpace(double v) {
  return SizedBox(width: v.w);
}





class Insets {
  static double offsetScale = 1;
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get med => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 32.w;
  // Offset, used for the edge of the window, or to separate large sections in the app
  static double get offset => 40 * offsetScale;
}

class Corners {
  static double xs = 4.w;
  static BorderRadius xsBorder = BorderRadius.all(xsRadius);
  static Radius xsRadius = Radius.circular(xs);

  static double xm = 4.w;
  static BorderRadius xmBorder = BorderRadius.all(xmRadius);
  static Radius xmRadius = Radius.circular(xm);

  static double sm = 8.w;
  static BorderRadius smBorder = BorderRadius.all(smRadius);
  static Radius smRadius = Radius.circular(sm);

  static double med = 12.w;
  static BorderRadius medBorder = BorderRadius.all(medRadius);
  static Radius medRadius = Radius.circular(med);

  static double lg = 16.w;
  static BorderRadius lgBorder = BorderRadius.all(lgRadius);
  static Radius lgRadius = Radius.circular(lg);

  static double xl = 24.w;
  static BorderRadius xlBorder = BorderRadius.all(xlRadius);
  static Radius xlRadius = Radius.circular(xl);

  static double xxl = 32.w;
  static BorderRadius xxlBorder = BorderRadius.all(xxlRadius);
  static Radius xxlRadius = Radius.circular(xxl);
}

class Shadows {
  static List<BoxShadow> get universal => [
        BoxShadow(
          color: const Color(0xff333333).withValues(alpha: .13),
          blurRadius: 5,
          offset: const Offset(0, 5),
        ),
      ];
  static List<BoxShadow> get universal2 => [
        BoxShadow(
          color: const Color(0xff333333).withValues(alpha: .05),
          blurRadius: 5,
          offset: const Offset(0, 5),
        ),
      ];
  static List<BoxShadow> get small => [
        BoxShadow(
          color: const Color(0xff333333).withValues(alpha: .15),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
  static List<BoxShadow> get none => [
        BoxShadow(
          color: Colors.grey.shade50,
        ),
      ];

  static List<BoxShadow> get shadowsUp => [
        BoxShadow(
          color: const Color(0xff333333).withValues(alpha: .15),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(-1, 0),
        ),
      ];
}

final PageDecoration pageDecoration = PageDecoration(
    imageFlex: 2,
    footerFlex: 0,
    titleTextStyle: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w700,),
    bodyTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 18.w,
    ),
    // pageColor: Colors.white,

  // titleTextStyle: CustomTextStyle.titleLarge,
  titlePadding:  EdgeInsets.only(top: 36.h, bottom: 24.h),
  // bodyTextStyle: CustomTextStyle.textLarge,
  bodyPadding:  EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
  // pageColor: Colors.white,
  imagePadding: EdgeInsets.zero,
);

const PageDecoration pageDecorationFullScreen = PageDecoration(
  fullScreen : true,
  bodyPadding:  EdgeInsets.zero,
  imagePadding: EdgeInsets.zero,
  contentMargin: EdgeInsets.zero,
  footerPadding: EdgeInsets.zero,
);