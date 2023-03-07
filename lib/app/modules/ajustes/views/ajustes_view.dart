import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ajustes_controller.dart';

class AjustesView extends GetView<AjustesController> {
  const AjustesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjustesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AjustesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
