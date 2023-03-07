import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/crear_turno_controller.dart';

class CrearTurnoView extends GetView<CrearTurnoController> {
  const CrearTurnoView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrearTurnoView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CrearTurnoView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
