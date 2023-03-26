import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/Notas/controllers/notas_controller.dart';
import 'package:calendario2/config/util/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotasViewController extends GetxController {
  NotasController notasController = Get.put(NotasController());

  RxBool headerShouldShow = false.obs;
  RxBool important = false.obs;

  Rx<Task> currentNote = Task().obs;
  late int id;

  @override
  void onInit() {
    if (Get.arguments != null) {
      currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    important.value = currentNote.value.isImportant!;
    showHeader();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void showHeader() async {
    Future.delayed(const Duration(milliseconds: 100), () {
      headerShouldShow.value = true;
      update();
    });
  }

  void handleSave() async {
    await DbProvider.instance.update(
      Task(
          id: currentNote.value.id,
          title: currentNote.value.title,
          isImportant: currentNote.value.isImportant,
          site: currentNote.value.site,
          notes: currentNote.value.notes,
          startTimeMilliseconds: currentNote.value.startTimeMilliseconds,
          endTimeMilliseconds: currentNote.value.endTimeMilliseconds,
          time: currentNote.value.time),
    );

    // Toast.toast(Get.context!, msg: "Editado! ", showTime: 3000);
    // DbProvider.instance.close();
  }

  void markImportantAsDirty() async {
    print(currentNote.value.isImportant);
    important.value = !important.value!;
    currentNote.value.isImportant = !currentNote.value.isImportant!;
    handleSave();
    print(currentNote.value.isImportant);
  }

  void handleEdit() {
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => EditTaskPage(widget.currentNote, _warnList)));
  }

  ///todo share
  void handleShare() {
    //   Share.share(
    //       '${widget.currentNote.title!.trim()}\n(On: ${widget.currentNote.startTimeMilliseconds.toString().substring(0, 10)})\n\n${widget.currentNote.title}');
  }

  void handleDelete() async {
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Borrar nota'),
            content: const Text('Se borrará permanentemente'),
            actions: <Widget>[
              TextButton(
                child: Text('BORRAR',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () async {
                  await DbProvider.instance.delete(id);
                  Get.offAllNamed('/notas');
                  notasController.refetchNotesFromDB();
                  //删除本次提醒
                  // for (int i = 0; i < 10; i++) {
                  //   push.cancelNotifications(widget.currentNote.id * 10 + i);
                  // }

                  Toast.toast(context, msg: "Eliminado exitosamente!");
                },
              ),
              TextButton(
                child: Text('CANCELAR',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
