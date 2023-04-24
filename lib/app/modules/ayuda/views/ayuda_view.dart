import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_group_widget.dart';
import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_row_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/assets.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/widgets/customText.dart';
import 'package:calendario2/widgets/setting_title.dart';
import 'package:calendario2/widgets/setting_title_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/ayuda_controller.dart';

class AyudaView extends GetView<AyudaController> {
  const AyudaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        centerTitle: true,
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
                    onTap: () => controller.reportProblem(),
                  ),
                  AyudaRowWidget(
                    title: "Videotutoriales",
                    subtitle: "Aquí podrás ver videotutoriales para ver ejemplos de uso de la aplicación.",
                    onTap:  () => controller.launchTwitter(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              SettingsGroup(
                title: "Contacto",
                children: [
                  AyudaRowWidget(
                    title: "Email",
                    subtitle:
                    "Contacta con nosotros por email para cualquier duda, sugerencia o reportar algun error.",
                    onTap: () => controller.reportProblem(),
                  ),
                  AyudaRowWidget(
                    title: "Twitter",
                    subtitle: "Síguenos para conocer todas las novedades o comunícate con nosotros a través de Twitter",
                    onTap:  () => controller.launchTwitter(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SettingsGroup(
                title: "Feedback",
                children: [
                  AyudaRowWidget(
                    title: "Enviar Feedback",
                    subtitle:
                    "Sugiera sus comentarios y solicitudes para que esta aplicación sea imprescindible para usted",
                    onTap: () => controller.giveFeedbackClicked(context),
                  ),
                  AyudaRowWidget(
                    title: "Califica app",
                    subtitle: "Comparte tu experiencia en Play Store",
                    onTap: controller.rateAppClicked,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
