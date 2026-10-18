import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class ButtonRowView extends StatelessWidget {
  const ButtonRowView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);
    return GetX<NotasListController>(
      init: NotasListController(),
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(left: 2.w, right: 2.w),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (controller.isFlagOn.value) {
                    controller.isFlagOn.value = false;
                  } else {
                    controller.isFlagOn.value = true;
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 42.h,
                  width: 35.w,
                  curve: Curves.slowMiddle,
                  decoration: BoxDecoration(
                      color: controller.isFlagOn.value
                          ? Colors.red
                          : Colors.transparent,
                      border: Border.all(
                        width: controller.isFlagOn.value ? 2 : 1,
                        color: controller.isFlagOn.value
                            ? Colors.red.shade700
                            : MyColors.borderAccentLine,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.r))),
                  key: controller.firstTime.value
                      ? tutorialController.keyButton11
                      : key,
                  child: Icon(
                    controller.isFlagOn.value
                        ? Icons.flag
                        : Icons.flag_outlined,
                    color: controller.isFlagOn.value
                        ? Colors.white
                        : MyColors.borderAccentLine,
                  ),
                ),
              ),
              Expanded(
                key: controller.firstTime.value
                    ? tutorialController.keyButton12
                    : key,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 4.w),
                  padding: EdgeInsets.only(left: 10.w),
                  height: 42.h,
                  decoration: BoxDecoration(
                      border: Border.all(color: MyColors.borderAccentLine),
                      borderRadius: BorderRadius.all(Radius.circular(10.r))),
                  child: Obx(() {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller.searchController.value,
                            maxLines: 1,
                            onChanged: (value) {
                              controller.handleSearch(value);
                            },
                            autofocus: false,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w500),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Busqueda',
                              hintStyle: TextStyle(
                                  color: MyColors.borderAccentLine,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500),
                              border: InputBorder.none,
                            ).copyWith(
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.transparent),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.0, color: Colors.transparent)),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.0, color: Colors.transparent)),
                            ),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                                controller.isSearchEmpty.value
                                    ? Icons.search
                                    : Icons.cancel,
                                color: MyColors.borderAccentLine),
                            onPressed: () {
                              controller.isSearchEmpty.value
                                  ? FocusScope.of(context)
                                      .requestFocus(FocusNode())
                                  : controller.cancelSearch();
                            }),
                      ],
                    );
                  }),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
