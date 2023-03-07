import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/crear_cuadrante_controller.dart';

class CrearCuadranteView extends GetView<CrearCuadranteController> {
  const CrearCuadranteView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrearCuadranteView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CrearCuadranteView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
