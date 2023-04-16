import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ayuda_controller.dart';

class AyudaView extends GetView<AyudaController> {
  const AyudaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AyudaView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AyudaView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
