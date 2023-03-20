import 'package:calendario2/app/modules/Notas/controllers/notas_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ButtonRowView extends StatelessWidget {
  const ButtonRowView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<NotasController>(
      init: NotasController(),
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  controller.isFlagOn.value ?? controller.isFlagOn.value;
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 160),
                  height: 50,
                  width: 50,
                  curve: Curves.slowMiddle,
                  // key: keyButton11,

                  child: Icon(
                    controller.isFlagOn.value ? Icons.flag : Icons
                        .flag_outlined,
                    color: controller.isFlagOn.value
                        ? Colors.white
                        : Colors.grey.shade300,
                  ),
                  decoration: BoxDecoration(
                      color: controller.isFlagOn.value
                          ? Colors.red
                          : Colors.transparent,
                      border: Border.all(
                        width: controller.isFlagOn.value ? 2 : 1,
                        color: controller.isFlagOn.value
                            ? Colors.red.shade700
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.only(left: 16),
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          maxLines: 1,
                          // key: keyButton12,

                          onChanged: (value) {
                            controller.handleSearch(value);
                          },
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                              controller.isSearchEmpty.value
                                  ? Icons.search
                                  : Icons.cancel,
                              color: Colors.grey.shade300),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(
                                new FocusNode());
                            controller.cancelSearch;
                          }),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
