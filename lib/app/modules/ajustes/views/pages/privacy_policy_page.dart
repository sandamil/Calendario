
import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/util/connector_parameter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/theme/my_colors.dart';
import '../../../../../config/util/app_link.dart';


class PrivacyPolicyPage extends StatelessWidget {
  PrivacyPolicyPage({super.key});
  final ajustesController = Get.find<AjustesController>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          title: Text(
            'Política de privacidad',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: FutureBuilder<String>(
          future: ajustesController.getDataByGet(ConnectorParameter(AppLink.privacyPolicyUrlString)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data ?? '',
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Icon(Icons.error),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: PRIMARY_COLOR,
              ),
            );
          },
        ),
      );

}
