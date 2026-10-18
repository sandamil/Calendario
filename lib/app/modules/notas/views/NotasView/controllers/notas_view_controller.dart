import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/home/views/home_view.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';

import '../../../../../controllers/ads_controller.dart';

class NotasViewController extends GetxController {
  Future<void> _recargarNotas(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(notasListProvider.notifier).reload();
    await container.read(notasProvider.notifier).reload();
  }


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
    // adcontroller.staticNotesListAd.dispose();
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
    final parentContext = Get.context;
    if (parentContext == null || !parentContext.mounted) return;

    final providerContainer =
        ProviderScope.containerOf(parentContext, listen: false);

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('Borrar nota'),
          content: const Text('Se borrará permanentemente'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'BORRAR',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () async {
                await NotasDB.instance.delete(id);
                await providerContainer
                    .read(notasListProvider.notifier)
                    .reload();
                await providerContainer
                    .read(notasProvider.notifier)
                    .reload();

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();

                if (!parentContext.mounted) return;
                Toast.toast(
                  parentContext,
                  msg: "Eliminado exitosamente!",
                );
                Get.offAllNamed('/notas');
              },
            ),
            TextButton(
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: Theme.of(dialogContext).primaryColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  notaNotasDelete(context, id) async {
    await NotasDB.instance.delete(id);
    await _recargarNotas(context);
    if (!context.mounted) return;
    Toast.toast(context, msg: "Eliminada!");
    Get.offAllNamed('/notas');
  }
   notaHomeDelete(context, id)async{
    await NotasDB.instance.delete(id);
    await _recargarNotas(context);
    Toast.toast(context, msg: "Eliminada!");
  }


  void handleDeleteCalendar(
    id,
    routeToNotas,
    selectedDay,
    focusedDay,
  ) async {
    final parentContext = Get.context;
    if (parentContext == null || !parentContext.mounted) return;

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('Borrar nota'),
          content: const Text('Se borrará permanentemente'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'BORRAR',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                if (!parentContext.mounted) return;

                if (routeToNotas) {
                  await notaNotasDelete(parentContext, id);
                } else {
                  await HomeView.notaHomeDelete(
                    parentContext,
                    id,
                    selectedDay,
                    focusedDay,
                  );
                }
              },
            ),
            TextButton(
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: Theme.of(dialogContext).primaryColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }


}
