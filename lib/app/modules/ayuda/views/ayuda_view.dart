import 'dart:io';

import 'package:calendario2/app/controllers/ads_controller.dart';
import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_group_widget.dart';
import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_row_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:get/get.dart';

import 'pages/feedback_screen.dart';

Future<void> _launchGmail() async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: 'ajatsoft@gmail.com',
    query: 'subject= Email Calendario Turnos Appp&body = ',
  );
  await launchUrlString(params.toString());
}

Future<void> _launchTwitter() async {
  await launchUrlString('https://x.com/ajatsoft');
}

void _giveFeedbackClicked(BuildContext context) {
  showBarModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        SizedBox(height: 600.h, child: const FeedbackScreen()),
  );
}

Future<void> _onRateThisAppPress() async {
  if (Platform.isAndroid || Platform.isIOS) {
    const androidPackageName = 'ajat.calendario.turnos';
    final appId = Platform.isAndroid ? androidPackageName : 'YOUR_IOS_APP_ID';

    final url = Uri.parse(
      Platform.isAndroid
          ? 'market://details?id=$androidPackageName'
          : 'https://apps.apple.com/app/id$appId',
    );

    final canLaunchIntent = await canLaunchUrl(url);
    if (canLaunchIntent) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await launchUrlString(
        'https://play.google.com/store/apps/details?id=$androidPackageName',
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

class AyudaView extends StatelessWidget {
  const AyudaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adcontroller = Get.find<AdsController>();

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          adcontroller.staticHomeAd.load();
          Get.offAllNamed('/home');
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.home,
              color: PRIMARY_COLOR,
              size: 26.sp,
            ),
            onPressed: () {
              adcontroller.staticHomeAd.load();
              Get.offAllNamed('/home');
            },
          ),
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Ayuda',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsGroup(
                  title: "Tutorial",
                  children: [
                    AyudaRowWidget(
                      title: "Resumen",
                      subtitle:
                          "Presiona aquí para ver el resumen que aparece la primera vez que instalas la aplicacion.",
                      onTap: () => Get.toNamed('/boarding'),
                    ),
                    AyudaRowWidget(
                      title: "Videotutoriales",
                      subtitle:
                          "Aquí podrás ver videotutoriales para ver ejemplos de uso de la aplicación.",
                      onTap: () => Get.toNamed('/videotutoriales'),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SettingsGroup(
                  title: "Feedback",
                  children: [
                    AyudaRowWidget(
                      title: "Enviar Feedback",
                      subtitle:
                          "Sugiera sus comentarios y solicitudes para que esta aplicación sea imprescindible para usted",
                      onTap: () => _giveFeedbackClicked(context),
                    ),
                    AyudaRowWidget(
                      title: "Califica app",
                      subtitle: "Comparte tu experiencia en Play Store",
                      onTap: _onRateThisAppPress,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SettingsGroup(
                  title: "Contacto",
                  children: [
                    AyudaRowWidget(
                      title: "Email",
                      subtitle:
                          "Contacta con nosotros por email para cualquier duda, sugerencia o reportar algun error.",
                      onTap: () => _launchGmail(),
                    ),
                    AyudaRowWidget(
                      title: "Twitter",
                      subtitle:
                          "Síguenos para conocer todas las novedades o comunícate con nosotros a través de Twitter",
                      onTap: () => _launchTwitter(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
