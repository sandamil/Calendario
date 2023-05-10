import 'package:calendario2/app/modules/ayuda/views/widgets/ayuda_row_widget.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../config/theme/my_colors.dart';
import '../../ayuda/views/widgets/ayuda_group_widget.dart';
import '../controllers/version_anterior_controller.dart';

class VersionAnteriorView extends GetView<VersionAnteriorController> {
  const VersionAnteriorView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 26.sp,
            color: PRIMARY_COLOR,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Version anterior',
          style: CustomTextStyle.appBarTitle(context: context),

        ),
      ),
      body: Column(
        children: <Widget>[
          SettingsGroup(
            title: "Notas",
            children: [
              AyudaRowWidget(
                title: "Notas Guardadas",
                subtitle:
                "Consulta las notas guardadas en tu calendario",
                onTap: () {
                  controller.goToNotasVersionAnteriorScreen();
                },
              ),
            ],
          ),
          SettingsGroup(
            title: "Turnos Guardados",
            children: [
              AyudaRowWidget(
                title: "Turnos en Calendario",
                subtitle:
                "Consulta los turnos creados en tu calendario, de forma manual",
                onTap: () {
                  controller.goToTurnosCalendarioScreen();
                },
              ),
            ],
          ),
          SettingsGroup(
            title: "Mis Turnos",
            children: [
              AyudaRowWidget(
                title: "Turnos creados",
                subtitle:
                "Consulta los turnos personalizados creados",
                onTap: () {
                  controller.goToTurnosPersonalizadosScreen();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
