import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/widgets/buttons/button_primary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomDialog {
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

  static alertaError(String msj) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mensaje de Error'),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle: const TextStyle(
            color: Colors.red,
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
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }



  static showPopUpInfo({
    String? title,
    String? description,
    String? labelButton,
    Function()? onPress,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w.w, 20.w, 20.w, 4.w),
          decoration:
          BoxDecoration(borderRadius: Corners.smBorder, color: MyColors.cellColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? '',
                style: TextStyles.title.copyWith(fontSize: 16.w),
                textAlign: TextAlign.center,
              ),
              verticalSpace(Insets.med),
              Text(
                description ?? '',
                style: TextStyles.text,
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
      ),
      barrierDismissible: false,
    );
  }



  static mostrarTask(Task nota, context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 5,
            title: Text.rich(
              TextSpan(
                text:
                    '${DateTime.fromMillisecondsSinceEpoch(nota.startTimeMilliseconds!).formatDateYMMMd} : ',
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '  ${DateTime.fromMillisecondsSinceEpoch(nota.startTimeMilliseconds!).formatDateTime24H} h.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ACCENT_COLOR,
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
                    style: TextStyle(
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    Future.delayed(const Duration(seconds: 10), () {
      Get.back();
    });
  }
}
