import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NotasComponentListView extends GetView {
  const NotasComponentListView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotasComponentListView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NotasComponentListView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
