import 'dart:developer';

import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:calendario2/app/modules/ayuda/controllers/ayuda_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../widgets/ayuda_group_widget.dart';
import '../widgets/ayuda_row_widget.dart';


class VersionAnteriorScreen extends GetView<AyudaController> {
  const VersionAnteriorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Version anterior'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
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
                onTap: () => controller.goToNotasVersionAnteriorScreen(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
