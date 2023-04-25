import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../controllers/notas_controller.dart';

class ImportantIndicatorTextView extends GetView {
  const ImportantIndicatorTextView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NotasListController controller = NotasListController();

    return Obx(() {
      return AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        firstChild: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Solo se estan mostrando las marcadas como importantes'
                .toUpperCase(),
            style: const TextStyle(
                fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
        secondChild: Container(
          height: 2,
        ),
        crossFadeState:
        controller.isFlagOn.value ? CrossFadeState.showFirst : CrossFadeState
            .showSecond,
      );
    });
  }
}
