import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:collection';
import 'dart:io';

import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/notas/views/widgets/taskCard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/table_calendar.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/home/widgets/calendar/widget/selected_day_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config/util/constant.dart';

import '../../../components/toast.dart';
import '../../../components/custom_dialog.dart';
import '../../../controllers/tutorial_provider.dart';
import '../../../controllers/tutorialController.dart';
import '../../../data/local/taskDatabase.dart';
import '../../../data/model/cuadranteDay.dart';
import '../../menu/views/menu_view.dart';
import '../widgets/calendar/dialog_onLongPress_calendar.dart';

typedef HomeCallback = void Function(int id, DateTime selectedDate);
typedef HomeCallback2 = void Function();
typedef HomeCallbackSetState = void Function(DateTime selectedDate);

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  State<HomeView> createState() => _HomeViewState();

  static notaHomeDelete(
      BuildContext context, id, selectedDay, focusedDay) async {
    await NotasDB.instance.delete(id);
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(notasProvider.notifier).reload();
    await container.read(notasListProvider.notifier).reload();

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
        Get.back();
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

  onDaySelectedLongPress(
    DateTime selectedDate,
    DateTime focusedDate,
    Offset tapPosition,
  ) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OnLongPressDialog(
          selectedDate: selectedDate,
          getCuadrante: getCuadrante(),
          tapPosition: tapPosition,
        );
      },
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

      // Esperar al siguiente frame: las claves ya estarán en el árbol.
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

    // Cargar el cuadrante antes de consultar los turnos del día inicial.
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
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            //? to close quick order floating if its open when click back btn
            if (isDialOpen.value) {
              isDialOpen.value = false;
              return false;
            } else {
              _appCloseConfirm(context);
            }
          }
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    key: _showHomeTutorial
                        ? tutorialController.keyButton6
                        : widget.key,
                    icon: Icon(
                      Icons.menu,
                      color: PRIMARY_COLOR,
                      size: 26.sp,
                    ),
                    onPressed: () {
                      Get.to(() => const MenuView(),
                          duration: const Duration(milliseconds: 100),
                          transition: Transition.leftToRight);
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
                  icon: const Icon(
                    Icons.today,
                  ),
                  tooltip: 'today',
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isAndroid
                ? Consumer(
                    builder: (context, ref, child) {
                      final ads = ref.watch(adsProvider);
                      final banner = ads.homeBanner;

                      if (!ads.isLoaded || banner == null) {
                        return const SizedBox.shrink();
                      }

                      return FloatingActionButton.extended(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () {},
                        label: SizedBox(
                          width: banner.size.width.toDouble(),
                          height: banner.size.height.toDouble(),
                          child: AdWidget(ad: banner),
                        ),
                      );
                    },
                  )
                : null,
            body: Column(
              children: [
                SizedBox(height: 2.h),
                Column(
                  key: _showHomeTutorial
                      ? tutorialController.keyButton8
                      : widget.key,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: TableCalendarWidget(
                        onDaySelected: onDaySelected,
                        onDaySelectedLongPress: onDaySelectedLongPress,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: LineWidget(),
                ),
                // SizedBox(height: 2.h),
                // Obx(() => _buildSelectedDay()),
                SizedBox(height: 2.h),

                Expanded(
                  key: _showHomeTutorial
                      ? tutorialController.keyButton9
                      : widget.key,
                  child: Consumer(
                    builder: (context, ref, child) {
                      ref.watch(notasProvider);
                      final DateTime selectedDate =
                          ref.watch(selectedDayProvider) ??
                              ref.watch(focusedMonthProvider);
                      final selectedDayNotas = ref
                          .read(notasProvider.notifier)
                          .getNotasOfDay(selectedDate);

                      return _buildListEvent(context, selectedDayNotas);
                    },
                  ),
                )
              ],
            )));
  }

  Widget _buildListEvent(BuildContext context, List<Task> events) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: events
                  .map(
                    (event) => Column(
                      children: [
                        // CardEvent(event: event),
                        TaskCard(
                          noteData: event,
                          onTapAction: (Task noteData) {
                            Get.toNamed(
                              '/notas-view',
                              arguments: {
                                'id': noteData.id!,
                                'noteData': noteData,
                              },
                            );
                          },
                          routeToNotas: false,
                          selectedDay:
                              ProviderScope.containerOf(context, listen: false)
                                  .read(selectedDayProvider),
                          focusedDay:
                              ProviderScope.containerOf(context, listen: false)
                                  .read(focusedMonthProvider),
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
