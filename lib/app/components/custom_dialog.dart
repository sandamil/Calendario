import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/widgets/buttons/app_round_mini_btn.dart';
import 'package:calendario2/widgets/buttons/button_primary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

import '../../widgets/big_text.dart';

class MyCustomDialog {

  static void myConfirmDialogBody({
    required BuildContext context,
    required String title,
    required String desc,
    btnCancelText = 'No',
    btnOkText = 'Si',
    circularColor,
    required Function onTapOK,
    required Function onTapCancel,
  }) {
    bool horizontal = 1.sh < 1.sw ? true : false;
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context) {
        return AlertDialog(
            insetPadding: EdgeInsets.all(0.sp),
            titlePadding: EdgeInsets.all(0.sp),
            actionsAlignment: MainAxisAlignment.center,
            contentPadding: EdgeInsets.symmetric(vertical: 0.sp, horizontal: 3.sp),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Colors.transparent,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.sp),
                    color: Colors.transparent,
                    width: horizontal ? 0.3.sw : 0.8.sw,
                    height: 250.h,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Positioned(
                          top: 25.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.sp),
                            width: horizontal ? 0.26.sw : 0.7.sw,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              color: MyColors.backgroundLowAccent,
                            ),
                            child: Container(
                              width: horizontal ? 0.26.sw : 0.7.sw,
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  55.verticalSpace,
                                  FittedBox(
                                      child: BigText(
                                        text: title,
                                        color: MyColors.textColor,
                                      )),
                                  5.verticalSpace,
                                  FittedBox(
                                      child: Center(
                                        child: Text(
                                          textAlign: TextAlign.center,

                                          desc,
                                          style:  TextStyle(

                                            color: MyColors.cellTextColor,
                                          ),
                                        ),
                                      )),
                                  10.verticalSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        child: AppRoundMiniBtn(
                                          text: btnOkText,
                                          color: Colors.green,
                                          onTap: () {
                                            onTapOK();
                                          },
                                        ),
                                      ),
                                      10.horizontalSpace,
                                      Flexible(
                                        child: AppRoundMiniBtn(
                                            text: btnCancelText,
                                            color: Colors.redAccent,
                                            onTap: () {
                                              onTapCancel();
                                            }),
                                      )
                                    ],
                                  ),
                                  10.verticalSpace,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: CircleAvatar(
                            minRadius: 26.r,
                            maxRadius: 38.r,
                            backgroundColor: MyColors.backgroundLowAccent,
                            child: Icon(
                              Icons.question_mark_sharp,
                              size: 38.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 3,
                          child: CircleAvatar(
                            minRadius: 19.r,
                            maxRadius: 31.r,
                            backgroundColor: circularColor ?? Colors.green,
                            child: Icon(
                              Icons.question_mark_sharp,
                              size: 38.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ));
      },

      animationType: DialogTransitionType.scale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
    );
  }

  static alertaInfo(String msj) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mensaje de Información'),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle: const TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: Text(msj),
          contentPadding: const EdgeInsets.all(10),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(
            Icons.info,
            color: Colors.orangeAccent,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          scrollable: false,
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }

  static alertaError(String msj, {duracion}) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle:  TextStyle(
            color: Colors.red,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          content: Text(msj,textAlign: TextAlign.center,),
          contentPadding: const EdgeInsets.all(10),
          contentTextStyle:  TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.normal,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(
            Icons.info,
            color: Colors.redAccent,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          scrollable: false,
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
    Future.delayed(Duration(seconds: duracion ?? 1), () {
      Get.back();
    });
  }



  static showPopUpInfo({
    required BuildContext context,
    String? title,
    String? description,
    String? labelButton,
    Function()? onPress,
  }) {
    showAnimatedDialog(
        context: context,
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 900),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w.w, 20.w, 20.w, 4.w),
              decoration:
              BoxDecoration(
                  borderRadius: Corners.smBorder, color: MyColors.backgroundLowAccent),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? '',
                    style: CustomTextStyle.title.copyWith(fontSize: 16.w),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace(Insets.med),
                  Text(
                    description ?? '',
                    style: CustomTextStyle.text,
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace(Insets.xl),
                  ButtonPrimary(
                    onTap: onPress ?? Get.back,
                    label: labelButton ?? 'OK',
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        }
    );
  }



  static mostrarTask(Task nota, context) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,

        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: MyColors.menuCardBackground,
            shape: RoundedRectangleBorder(borderRadius: Corners.smBorder),
            elevation: 5,
            title: Text.rich(
              TextSpan(
                text:
                    '${DateTime.fromMillisecondsSinceEpoch(nota.startTimeMilliseconds!).formatDateYMMMd} : ',
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '  ${DateTime.fromMillisecondsSinceEpoch(nota.startTimeMilliseconds!).formatDateTime24H} h.',
                    style: GoogleFonts.titilliumWeb(
                      fontWeight: FontWeight.bold,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ],
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  textAlign: TextAlign
                      .start,

                  TextSpan(
                    text: nota.title,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text.rich(
                  TextSpan(
                    text: nota.notes,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        },

      animationType: DialogTransitionType.scale,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 600),


    );
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }
}
