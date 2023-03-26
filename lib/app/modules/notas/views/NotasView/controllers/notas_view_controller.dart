import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotasViewController extends GetxController {
  bool headerShouldShow = false;


  late Task currentNote;
  late int id;


  @override
  void onInit() {
    if(Get.arguments != null){
      currentNote = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    super.onInit();
  }

  @override
  void onReady() {


    print(currentNote.title);

    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void showHeader() async {
    Future.delayed(const Duration(milliseconds: 100), () {
        headerShouldShow = true;
     update();
    });
  }

  void handleSave() async {

    DbProvider.instance.update(
      Task(
          id: currentNote.id,
          title: currentNote.title,
          isImportant: currentNote.isImportant,
          site: currentNote.site,
          notes: currentNote.notes,
          startTimeMilliseconds: currentNote.startTimeMilliseconds,
          endTimeMilliseconds: currentNote.endTimeMilliseconds,
          time: currentNote.time),
    );

    Toast.toast(Get.context!, msg: "Editado! ", showTime: 3000);
    DbProvider.instance.close();

  }

  void markImportantAsDirty() {

      currentNote.isImportant = !currentNote.isImportant!;
   update();
    handleSave();
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
                onPressed: () {
                  Navigator.of(context).pop(true); //关闭对话框
                  // DbProvider.instance.delete( widget.currentNote.id);

                  //删除本次提醒
                  // for (int i = 0; i < 10; i++) {
                  //   push.cancelNotifications(widget.currentNote.id * 10 + i);
                  // }

                  Navigator.pushReplacementNamed(context, '/home');
                  Toast.toast(context, msg: "Eliminado exitosamente!");
                  DbProvider.instance.close();

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
