import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/notas/views/widgets/taskCard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/table_calendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/dialog_onLongPress_calendar.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config/util/constant.dart';

import '../../../components/toast.dart';
import '../../../components/custom_dialog.dart';
import '../../../controllers/tutorial_provider.dart';
import '../../../controllers/tutorialController.dart';
import '../../../data/model/cuadranteDay.dart';
import '../../menu/views/menu_view.dart';

typedef HomeCallback = void Function(int id, DateTime selectedDate);
typedef HomeCallback2 = void Function();
typedef HomeCallbackSetState = void Function(DateTime selectedDate);

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  State<HomeView> createState() => _HomeViewState();

  static notaHomeDelete(
      BuildContext context, id, selectedDay, focusedDay) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(notasListProvider.notifier).eliminarNota(id);

    Toast.toast(context, msg: "Eliminada!");
  }
}

class _HomeViewState extends State<HomeView> {
  void _appCloseConfirm(BuildContext context) {
    MyCustomDialog.myConfirmDialogBody(
      context: context,
      title: '¿ Salir de la aplicacion ?',
      desc: 'Quieres cerrar la aplicación?'
          '\\nPuedes dejarla en segundo plano'
          '\\nsi pulsas el botón: o en vez de: <',
      btnCancelText: 'Salir',
      btnOkText: 'Quedarme',
      onTapOK: () async {
        Navigator.of(context).pop();
      },
      onTapCancel: () async {
        SystemNavigator.pop();
      },
    );
  }

  final isDialOpen = ValueNotifier(false);
  late final TutorialController tutorialController;

  bool _showHomeTutorial = false;

  DateTime? _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  Future<Map<DateTime, List<CuadranteDay>>> getCuadrante() async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    final result = container.read(cuadranteMapProvider);
    if (mounted) setState(() {});
    return result;
  }

  onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    if (!isSameDay(
      ProviderScope.containerOf(context, listen: false)
          .read(selectedDayProvider),
      selectedDate,
    )) {
      setState(() {
        ProviderScope.containerOf(context, listen: false)
            .read(selectedDayProvider.notifier)
            .setSelectedDay(selectedDate);
        ProviderScope.containerOf(context, listen: false)
            .read(focusedMonthProvider.notifier)
            .setFocusedDay(focusedDate);
      });
    }

    final container = ProviderScope.containerOf(context, listen: false);
    container
        .read(selectedDayTurnosProvider.notifier)
        .setTurnos(getTurnosOfDayFromMap(
          selectedDate,
          container.read(cuadranteMapProvider),
        ));
  }

  Future<void> onDayTap(
    DateTime selectedDate,
    DateTime focusedDate,
    Offset tapPosition,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarDaySheet(
        selectedDate: selectedDate,
        getCuadrante: getCuadrante(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ProviderScope.containerOf(context, listen: false)
          .read(adsProvider.notifier)
          .ensureHomeBanner();
    });
    tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !MySharedPref.getTutoHomeFirst()) return;

      setState(() {
        _showHomeTutorial = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_showHomeTutorial) return;

        tutorialController.firstInstall(
          'home',
          context: context,
          onFinished: () {
            if (!mounted) return;
            setState(() {
              _showHomeTutorial = false;
            });
          },
        );
      });
    });

    _selectedDays.add(ProviderScope.containerOf(context, listen: false)
        .read(focusedMonthProvider));

    getCuadrante().then((mapa) {
      if (!mounted) return;
      ProviderScope.containerOf(context, listen: false)
          .read(selectedDayTurnosProvider.notifier)
          .setTurnos(getTurnosOfDayFromMap(
            ProviderScope.containerOf(context, listen: false)
                .read(focusedMonthProvider),
            mapa,
          ));
      setState(() {});
    });

    Future.microtask(() async {
      final container = ProviderScope.containerOf(context, listen: false);
      await container.read(notasProvider.notifier).reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !(!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if ((!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) {
            if (isDialOpen.value) {
              isDialOpen.value = false;
            } else {
              _appCloseConfirm(context);
            }
          }
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              toolbarHeight: 58.h,
              titleSpacing: 2.w,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    key: _showHomeTutorial
                        ? tutorialController.keyButton6
                        : widget.key,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      context.push('/menu');
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              ),
              title: SelectedDayWidget(),
              actions: [
                IconButton(
                  key: _showHomeTutorial
                      ? tutorialController.keyButton7
                      : widget.key,
                  color: PRIMARY_COLOR,
                  icon: Icon(
                    Icons.today_rounded,
                    size: 22.sp,
                  ),
                  tooltip: 'Ir a hoy',
                  onPressed: () {
                    final hoy = DateTime.now();
                    final container =
                        ProviderScope.containerOf(context, listen: false);
                    container
                        .read(focusedMonthProvider.notifier)
                        .setFocusedDay(hoy);
                    container
                        .read(selectedDayProvider.notifier)
                        .setSelectedDay(hoy);
                  },
                ),
              ],
            ),
            bottomNavigationBar: null,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: TableCalendarWidget(
                      onDaySelected: onDaySelected,
                      onDayTap: onDayTap,
                    ),
                  ),
                  const LineWidget(),
                  SizedBox(height: 4.h),
                  _buildSelectedDayTasks(),
                ],
              ),
            )));
  }

  Widget _buildSelectedDayTasks() {
    final container = ProviderScope.containerOf(context, listen: false);
    final selectedDay = container.read(selectedDayProvider);
    if (selectedDay == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final notas = ref.watch(notasProvider);
        final tasks = ref.read(notasProvider.notifier).getNotasOfDay(selectedDay);
        if (tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 210.h),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
            shrinkWrap: true,
            itemCount: tasks.length,
            separatorBuilder: (_, __) => SizedBox(height: 4.h),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onDelete: () async {
                  await HomeView.notaHomeDelete(
                    context,
                    task.id,
                    selectedDay,
                    container.read(focusedMonthProvider),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
