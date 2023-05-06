import 'dart:developer';

import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../controllers/ayuda_controller.dart';
import '../widgets/ayuda_group_widget.dart';
import '../widgets/ayuda_row_widget.dart';


class NotasVersionAnteriorScreen extends GetView<AyudaController> {
  const NotasVersionAnteriorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Notas'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: <Widget>[
         Container(child:
         SingleChildScrollView(
           child: Column(
             // physics: BouncingScrollPhysics(),
             children: <Widget>[
               Container(height: 6.h),
               ...controller.buildNoteBkpComponentsList(),
             ],
           ),
         ),

         )
        ],
      ),
    );
  }
}
