import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_group_widget.dart';
import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_row_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/ayuda_controller.dart';

class AyudaView extends GetView<AyudaController> {
  const AyudaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: PRIMARY_COLOR,
              size: 26.sp,
            ),
            onPressed: () {
              Get.back();
            }),
        title: Text(
          'Ayuda',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
              SizedBox(height: 10.h),
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
              SizedBox(height: 10.h),
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
              ),
              SizedBox(height: 10.h),

              SettingsGroup(
                title: "Version Anterior",
                children: [
                  AyudaRowWidget(
                    title: "Datos Guardados",
                    subtitle:
                    "Consulta aquí, los datos guardados de tu versión anterior a Calendario 2.0, o Mayo 2023.",
                    onTap: () => controller.goToVersionAnteriorScreen(),
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
