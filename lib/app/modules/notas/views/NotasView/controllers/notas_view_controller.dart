import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/controllers/notas_controller.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../controllers/ads_controller.dart';

class NotasViewController extends GetxController {
  NotasListController notasListController = Get.put(NotasListController());
  final adcontroller = Get.find<AdsController>();

  RxBool headerShouldShow = false.obs;
  RxBool important = false.obs;
  RxBool isAlarmaCreated = false.obs;

  Rx<Task> currentNote = Task().obs;
  late int id;

  @override
  void onInit() {
    if (Get.arguments != null) {
      currentNote.value = Get.arguments['noteData'];
      id = Get.arguments['id'];
    }
    important.value = currentNote.value.isImportant!;
    isAlarmaCreated.value = currentNote.value.isAlarmaCreated!;
    showHeader();
    super.onInit();

  }



  void showHeader() async {
    Future.delayed(const Duration(milliseconds: 100), () {
      headerShouldShow.value = true;
      update();
    });
  }

  void handleSave() async {
    await NotasDB.instance.update(
      Task(
          id: currentNote.value.id,
          title: currentNote.value.title,
          isImportant: currentNote.value.isImportant,
          site: currentNote.value.site,
          notes: currentNote.value.notes,
          startTimeMilliseconds: currentNote.value.startTimeMilliseconds,
          endTimeMilliseconds: currentNote.value.endTimeMilliseconds,
          // time: currentNote.value.time
      ),
    );

    // Toast.toast(Get.context!, msg: "Editado! ", showTime: 3000);
    // DbProvider.instance.close();
  }

  void markImportantAsDirty() async {
    important.value = !important.value;
    currentNote.value.isImportant = !currentNote.value.isImportant!;
    handleSave();
  }

  void handleEdit() {
    adcontroller.staticNotesListAd.dispose();

    print('===============================================');
    print(currentNote.value.alarmaHora);

    print('===============================================');
    print('===============================================');
    print('===============================================');

    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print('===============================================');
    print('===============================================');
    print('===============================================');
    print('===============================================');
    print('===============================================');
    print('===============================================');
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    print(currentNote.value.alarmaHora);
    Get.toNamed(
      '/edit-notas',
      arguments: {'id': currentNote.value.id!, 'noteData': currentNote.value},
    );
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => EditTaskPage(widget.currentNote, _warnList)));
  }


  Future<void> shareApp() async {
    print('Titulo: ${currentNote.value.title}'
        '\nNota: ${currentNote.value.notes}'
        '\nInicio: ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.startTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.startTimeMilliseconds!).formatDateYMMMd}'
        '\nFin: ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.endTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.endTimeMilliseconds!).formatDateYMMMd}'
    );
    Share.share(''
        'Titulo: ${currentNote.value.title}'
        '\nNota: ${currentNote.value.notes}'
        '\nInicio: ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.startTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.startTimeMilliseconds!).formatDateYMMMd}'
        '\nFin: ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.endTimeMilliseconds!).formatDateTime24H} h.  ${DateTime.fromMillisecondsSinceEpoch(currentNote.value.endTimeMilliseconds!).formatDateYMMMd}'
    );
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
                  await NotasDB.instance.delete(id);
                  Get.offAllNamed('/notas');
                  notasListController.refetchNotesFromDB();
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

  void handleDeleteCalendar(id) async{
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
                  await NotasDB.instance.delete(id);
                  Get.offAllNamed('/notas');
                  notasListController.refetchNotesFromDB();
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
