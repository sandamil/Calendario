import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    context.push('/notas-view', extra: {'id': note.id!, 'noteData': note});
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

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return PopScope(
      canPop: !isAndroid,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (isAndroid) {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: () {
              ProviderScope.containerOf(context, listen: false)
                  .read(adsProvider.notifier)
                  .ensureHomeBanner();
              context.go('/home');
            },
          ),
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 58.h,
          titleSpacing: 2.w,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          backgroundColor: PRIMARY_COLOR,
          foregroundColor: Colors.white,
          onPressed: () => context.push('/add-notas'),
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
          margin: EdgeInsets.only(top: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ButtonRowView(),
                const ImportantIndicatorTextView(),
                SizedBox(height: 6.h),
                if (state.notas.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 18.w),
                    child: Column(
                      children: [
                        Container(width: 68.w, height: 68.w, decoration: BoxDecoration(color: PRIMARY_COLOR.withValues(alpha: .14), borderRadius: BorderRadius.circular(22.r)), child: Icon(Icons.sticky_note_2_outlined, color: PRIMARY_COLOR, size: 34.sp)),
                        SizedBox(height: 14.h),
                        Text('Aún no tienes notas', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(height: 6.h),
                        Text('Crea una nota para no olvidar nada importante.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62))),
                      ],
                    ),
                  )
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
