import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/crear_turno_controller.dart';

class TurnosView extends GetView<CrearTurnoController> {
  const TurnosView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TurnosView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TurnosView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
