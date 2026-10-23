import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:collection';
import 'dart:math' as math;
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
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../config/util/constant.dart';

import '../../../components/toast.dart';
import '../../../components/custom_dialog.dart';
import '../../../controllers/tutorial_provider.dart';
import '../../../controllers/tutorialController.dart';
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
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    final overlayObject = overlay?.context.findRenderObject();
    final overlayBox = overlayObject is RenderBox ? overlayObject : null;
    final overlaySize = overlayBox?.size ?? MediaQuery.sizeOf(context);
    final tap = overlayBox?.globalToLocal(tapPosition) ?? tapPosition;

    final horizontalMargin = math.min(12.w, overlaySize.width / 4);
    final availableWidth = math.max(
      1.0,
      overlaySize.width - horizontalMargin * 2,
    );
    final popupWidth = math.min(360.w, availableWidth);
    final verticalMargin = math.min(12.h, overlaySize.height / 4);

    final maxLeft = math.max(
      horizontalMargin,
      overlaySize.width - popupWidth - horizontalMargin,
    );
    final left = (tap.dx - popupWidth / 2)
        .clamp(horizontalMargin, maxLeft)
        .toDouble();
    final arrowInset = math.min(20.w, popupWidth / 2);
    final arrowX = (tap.dx - left)
        .clamp(arrowInset, popupWidth - arrowInset)
        .toDouble();

    final spaceBelow = math.max(
      0.0,
      overlaySize.height - tap.dy - verticalMargin,
    );
    final spaceAbove = math.max(0.0, tap.dy - verticalMargin);
    final showBelow = spaceBelow >= spaceAbove;
    final availableHeight = showBelow ? spaceBelow : spaceAbove;
    final popupMaxHeight = math.max(
      1.0,
      math.min(overlaySize.height * .68, availableHeight),
    );

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar acciones del día',
      barrierColor: Colors.black.withOpacity(.10),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: showBelow ? tap.dy : null,
              bottom: showBelow ? null : overlaySize.height - tap.dy,
              width: popupWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: popupMaxHeight),
                child: CalendarDaySheet(
                  selectedDate: selectedDate,
                  getCuadrante: getCuadrante(),
                  arrowX: arrowX,
                  pointerOnTop: showBelow,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    );
  }

  DateTime _selectedCalendarDate() {
    final container = ProviderScope.containerOf(context, listen: false);
    return container.read(selectedDayProvider) ?? container.read(focusedMonthProvider);
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _monthStart(DateTime date) => DateTime(date.year, date.month, 1);

  DateTime _monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);

  DateTime _yearStart(DateTime date) => DateTime(date.year, 1, 1);

  DateTime _yearEnd(DateTime date) => DateTime(date.year, 12, 31);

  String _periodDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Future<void> _openShareMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final onSurface = theme.colorScheme.onSurface;
        return Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: onSurface.withOpacity(.18),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: PRIMARY_COLOR.withOpacity(.12),
                        child: Icon(Icons.share_rounded, color: PRIMARY_COLOR, size: 21.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Compartir calendario',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Periodo',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: onSurface.withOpacity(.58)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _ShareMenuTile(
                    icon: Icons.today_rounded,
                    title: 'Compartir día',
                    subtitle: 'El día seleccionado',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final DateTime selected = _selectedCalendarDate();
                      await _shareCalendarPeriod(_dateOnly(selected), _dateOnly(selected), 'Día ${_periodDate(selected)}');
                    },
                  ),
                  _ShareMenuTile(
                    icon: Icons.date_range_rounded,
                    title: 'Compartir días',
                    subtitle: 'Seleccionar un periodo de días',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _shareCustomRange('Días');
                    },
                  ),
                  _ShareMenuTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'Compartir mes',
                    subtitle: 'El mes que estás viendo',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final selected = ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider);
                      await _shareCalendarPeriod(_monthStart(selected), _monthEnd(selected), DateFormat('MMMM yyyy', 'es_ES').format(selected));
                    },
                  ),
                  _ShareMenuTile(
                    icon: Icons.calendar_view_month_rounded,
                    title: 'Compartir meses',
                    subtitle: 'Seleccionar varios meses',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _shareCustomMonths();
                    },
                  ),
                  _ShareMenuTile(
                    icon: Icons.event_note_rounded,
                    title: 'Compartir año',
                    subtitle: 'Todo el año seleccionado',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final selected = ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider);
                      await _shareCalendarPeriod(_yearStart(selected), _yearEnd(selected), 'Año ${selected.year}');
                    },
                  ),
                  _ShareMenuTile(
                    icon: Icons.tune_rounded,
                    title: 'Rango personalizado',
                    subtitle: 'Elegir cualquier fecha de inicio y fin',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _shareCustomRange('Rango personalizado');
                    },
                  ),
                  SizedBox(height: 8.h),
                  Divider(color: onSurface.withOpacity(.10)),
                  SizedBox(height: 6.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Formatos',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: onSurface.withOpacity(.58)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _ShareMenuTile(
                    icon: Icons.text_snippet_outlined,
                    title: 'Texto',
                    subtitle: 'Disponible ahora',
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                  _ShareMenuTile(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'PDF',
                    subtitle: 'Lo añadiremos con plantillas de día, mes y año',
                    enabled: false,
                    onTap: () {},
                  ),
                  _ShareMenuTile(
                    icon: Icons.image_outlined,
                    title: 'Imagen / captura',
                    subtitle: 'Calendario listo para enviar o guardar',
                    enabled: false,
                    onTap: () {},
                  ),
                  _ShareMenuTile(
                    icon: Icons.event_available_outlined,
                    title: 'Archivo de calendario',
                    subtitle: 'Exportación compatible tipo ICS',
                    enabled: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareCustomRange(String title) async {
    final selected = _selectedCalendarDate();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      initialDateRange: DateTimeRange(start: _dateOnly(selected), end: _dateOnly(selected)),
      helpText: title,
      saveText: 'Compartir',
    );
    if (!mounted || range == null) return;
    await _shareCalendarPeriod(_dateOnly(range.start), _dateOnly(range.end), '${_periodDate(range.start)} - ${_periodDate(range.end)}');
  }

  Future<void> _shareCustomMonths() async {
    final selected = ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      initialDateRange: DateTimeRange(start: _monthStart(selected), end: _monthEnd(selected)),
      helpText: 'Selecciona los meses',
      saveText: 'Compartir',
    );
    if (!mounted || range == null) return;
    final start = _monthStart(range.start);
    final end = _monthEnd(range.end);
    final label = start.year == end.year
        ? 'Meses ${DateFormat('MMMM', 'es_ES').format(start)} - ${DateFormat('MMMM yyyy', 'es_ES').format(end)}'
        : 'Meses ${DateFormat('MMMM yyyy', 'es_ES').format(start)} - ${DateFormat('MMMM yyyy', 'es_ES').format(end)}';
    await _shareCalendarPeriod(start, end, label);
  }

  Future<void> _shareCalendarPeriod(DateTime start, DateTime end, String label) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    final calendar = container.read(cuadranteMapProvider);
    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    final lines = <String>[];
    final entries = <CuadranteDay>[];

    for (final values in calendar.values) {
      for (final day in values) {
        final date = day.dateTime;
        if (date == null) continue;
        final normalized = _dateOnly(date);
        if (!normalized.isBefore(startDay) && !normalized.isAfter(endDay)) {
          entries.add(day);
        }
      }
    }

    entries.sort((a, b) {
      final dateCompare = (a.dateTime ?? DateTime(1900)).compareTo(b.dateTime ?? DateTime(1900));
      if (dateCompare != 0) return dateCompare;
      return (a.startHour ?? '').compareTo(b.startHour ?? '');
    });

    lines.add('Calendario — $label');
    lines.add('');

    if (entries.isEmpty) {
      lines.add('No hay turnos registrados en este periodo.');
    } else {
      DateTime? lastDate;
      for (final day in entries) {
        final date = _dateOnly(day.dateTime!);
        if (lastDate == null || !isSameDay(lastDate, date)) {
          if (lastDate != null) lines.add('');
          lines.add(DateFormat('EEEE dd/MM/yyyy', 'es_ES').format(date));
          lastDate = date;
        }
        final title = (day.description ?? '').trim().isNotEmpty
            ? day.description!.trim()
            : ((day.title ?? '').trim().isNotEmpty ? day.title!.trim() : 'Turno');
        final startHour = (day.startHour ?? '').trim();
        final endHour = (day.endHour ?? '').trim();
        final hours = startHour.isNotEmpty && endHour.isNotEmpty ? ' · $startHour - $endHour' : '';
        lines.add('• $title$hours');
      }
    }

    await SharePlus.instance.share(
      ShareParams(
        text: lines.join('\n'),
        title: 'Compartir calendario',
        subject: 'Calendario — $label',
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
                    Icons.my_location_rounded,
                    size: 22.sp,
                  ),
                  tooltip: 'Volver a hoy',
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
                IconButton(
                  color: PRIMARY_COLOR,
                  icon: Icon(
                    Icons.share_rounded,
                    size: 22.sp,
                  ),
                  tooltip: 'Compartir calendario',
                  onPressed: _openShareMenu,
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton:
                (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                    ? Consumer(
                        builder: (context, ref, child) {
                          final ads = ref.watch(adsProvider);
                          final banner = ads.homeBanner;

                          return FloatingActionButton.extended(
                            heroTag: 'homeBannerAd',
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            elevation: 0,
                            highlightElevation: 0,
                            onPressed: () {},
                            label: ads.isLoaded && banner != null
                                ? SizedBox(
                                    width: banner.size.width.toDouble(),
                                    height: banner.size.height.toDouble(),
                                    child: AdWidget(ad: banner),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      )
                    : null,
            body: Column(
              children: [
                SizedBox(height: 4.h),
                Column(
                  key: _showHomeTutorial
                      ? tutorialController.keyButton8
                      : widget.key,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: TableCalendarWidget(
                        onDaySelected: onDaySelected,
                        onDayTap: onDayTap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: LineWidget(),
                ),
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
                        TaskCard(
                          noteData: event,
                          onTapAction: (Task noteData) {
                            context.push('/notas-view', extra: {
                              'id': noteData.id!,
                              'noteData': noteData,
                            });
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

class _ShareMenuTile extends StatelessWidget {
  const _ShareMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return Opacity(
      opacity: enabled ? 1 : .48,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(.55),
        borderRadius: BorderRadius.circular(15.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.r),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            child: Row(
              children: [
                Icon(icon, color: PRIMARY_COLOR, size: 22.sp),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: color)),
                      SizedBox(height: 2.h),
                      Text(subtitle, style: TextStyle(fontSize: 11.sp, color: color.withOpacity(.58))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20.sp, color: color.withOpacity(.35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
