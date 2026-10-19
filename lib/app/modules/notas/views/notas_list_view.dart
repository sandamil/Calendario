import 'dart:io';

import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/controllers/ads_provider.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/notas/views/widgets/important_indicator_text_view.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'widgets/button_row_view.dart';
import 'widgets/taskCard.dart';

class NotasListView extends ConsumerStatefulWidget {
  NotasListView({Key? key}) : super(key: key);

  @override
  ConsumerState<NotasListView> createState() => _NotasListViewState();
}

class _NotasListViewState extends ConsumerState<NotasListView> {
  bool _tutorialStartScheduled = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(notasListProvider.notifier).reload();
    });
  }

  void _openNote(Task note) {
    Get.toNamed(
      '/notas-view',
      arguments: {'id': note.id!, 'noteData': note},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notasListProvider);
    final notifier = ref.read(notasListProvider.notifier);

    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    if (!_tutorialStartScheduled && MySharedPref.getTutoTaskFirst()) {
      _tutorialStartScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        notifier.setTutorialVisible(true);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          tutorialController.firstInstall(
            'task',
            context: context,
            onFinished: () {
              if (mounted) {
                notifier.setTutorialVisible(false);
              }
            },
          );
        });
      });
    }

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();
          Get.offAllNamed('/home');
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: () {
              ProviderScope.containerOf(context, listen: false)
                  .read(adsProvider.notifier)
                  .ensureHomeBanner();
              Get.offAllNamed('/home');
            },
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Notas',
            style: CustomTextStyle.appBarTitle(context: context),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
          actions: [
            IconButton(
              key: state.tutorialVisible
                  ? tutorialController.keyNotasListAyuda
                  : widget.key,
              icon: const AppIcon(
                AppIcons.informacion,
                color: Colors.green,
              ),
              tooltip: '',
              onPressed: () {
                notifier.setTutorialVisible(true);
                tutorialController.showTutorial(
                  context,
                  'task',
                  onFinished: () {
                    if (mounted) {
                      notifier.setTutorialVisible(false);
                    }
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: PRIMARY_COLOR,
          onPressed: () => Get.toNamed('/add-notas'),
          label: Text(
            'Añade Nota'.toUpperCase(),
            key: state.tutorialVisible
                ? tutorialController.keyButton10
                : widget.key,
          ),
          icon: const Icon(Icons.add),
        ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.only(left: 15.w, right: 15.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ButtonRowView(),
                const ImportantIndicatorTextView(),
                SizedBox(height: 6.h),
                if (state.notas.isEmpty)
                  const SizedBox.shrink()
                else
                  ...state.notasFiltradas.map(
                    (nota) => TaskCard(
                      noteData: nota,
                      onTapAction: _openNote,
                      routeToNotas: true,
                    ),
                  ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
