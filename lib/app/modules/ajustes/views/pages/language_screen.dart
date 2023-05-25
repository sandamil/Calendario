import 'dart:developer';

import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';


class LanguageScreen extends GetView<AjustesController> {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Idioma'.tr,
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.languages.length,
        itemBuilder: (context, index) {
          final name = controller.languages[index].name;
          final languageCode = controller.languages[index].languageCode;

          return ListTile(
            onTap: () => controller.onLanguageTilePressed(languageCode),
            title: Text(name),
            trailing: Obx(
              () => Radio(
                value: controller.languages[index].languageCode,
                groupValue: controller.selectedLanguage.value.languageCode,
                onChanged: (value) {
                  log('pressed: ');
                  controller.onLanguageTilePressed(languageCode);
                },
              ),
            ),
          );
        },
        //   RadioListTile(
        //     title: Text(controller.languages[index].name),
        //     value: controller.languages[index].languageCode,
        //     groupValue: controller.selectedLanguage.value.languageCode,
        //     onChanged: (value) {
        //       log('pressed: ${controller.languages[index].languageCode}');
        //       controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
        //     },
        //   ),
        // ),
        // children: [
        //   ...List.generate(
        //     controller.languages.length,
        //     (index) => RadioListTile(
        //       title: Text(controller.languages[index].name),
        //       value: controller.languages[index].languageCode,
        //       groupValue: controller.selectedLanguage.value.languageCode,
        //       onChanged: (value) {
        //         controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
        //       },
        //     ),
        //     // ListTile(leading: ,trailing: ,)
        //   ),
        // ],
      ),
    );
  }
}
