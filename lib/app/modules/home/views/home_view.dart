import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
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
import 'package:cross_file/cross_file.dart';
import 'package:pdf/widgets.dart' as pw;
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
    var period = 'Día seleccionado';
    var includeTurnos = true;
    var includeNotas = true;
    var format = 'Texto';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final onSurface = theme.colorScheme.onSurface;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .86,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 38.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: onSurface.withOpacity(.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(Icons.share_rounded, color: PRIMARY_COLOR, size: 23.sp),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Compartir calendario',
                                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(false),
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Cerrar',
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text('PERIODO', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: .8, color: onSurface.withOpacity(.58))),
                        SizedBox(height: 6.h),
                        DropdownButtonFormField<String>(
                          value: period,
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.date_range_rounded, color: PRIMARY_COLOR),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.r)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Día seleccionado', child: Text('Día seleccionado')),
                            DropdownMenuItem(value: 'Mes visible', child: Text('Mes visible')),
                            DropdownMenuItem(value: 'Año visible', child: Text('Año visible')),
                            DropdownMenuItem(value: 'Rango de días', child: Text('Rango de días…')),
                            DropdownMenuItem(value: 'Varios meses', child: Text('Varios meses…')),
                          ],
                          onChanged: (value) {
                            if (value != null) setSheetState(() => period = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        Text('QUÉ QUIERES COMPARTIR', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: .8, color: onSurface.withOpacity(.58))),
                        SizedBox(height: 4.h),
                        CheckboxListTile(
                          value: includeTurnos,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: PRIMARY_COLOR,
                          title: const Text('Turnos'),
                          secondary: Icon(Icons.work_history_outlined, color: PRIMARY_COLOR),
                          onChanged: (value) => setSheetState(() => includeTurnos = value ?? false),
                        ),
                        CheckboxListTile(
                          value: includeNotas,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: PRIMARY_COLOR,
                          title: const Text('Notas'),
                          secondary: Icon(Icons.sticky_note_2_outlined, color: PRIMARY_COLOR),
                          onChanged: (value) => setSheetState(() => includeNotas = value ?? false),
                        ),
                        SizedBox(height: 10.h),
                        Text('FORMATO', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: .8, color: onSurface.withOpacity(.58))),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _ShareFormatChip(icon: Icons.text_snippet_outlined, label: 'Texto', selected: format == 'Texto', onTap: () => setSheetState(() => format = 'Texto')),
                            _ShareFormatChip(icon: Icons.picture_as_pdf_outlined, label: 'PDF', selected: format == 'PDF', onTap: () => setSheetState(() => format = 'PDF')),
                            _ShareFormatChip(icon: Icons.image_outlined, label: 'Imagen bonita', selected: format == 'Imagen bonita', onTap: () => setSheetState(() => format = 'Imagen bonita')),
                            _ShareFormatChip(icon: Icons.photo_camera_outlined, label: 'Captura', selected: format == 'Captura', onTap: () => setSheetState(() => format = 'Captura')),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: (includeTurnos || includeNotas)
                                ? () => Navigator.of(sheetContext).pop(true)
                                : null,
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Continuar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: PRIMARY_COLOR,
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || confirmed != true) return;
    DateTime start;
    DateTime end;
    String label;
    final selected = _selectedCalendarDate();
    switch (period) {
      case 'Mes visible':
        start = _monthStart(ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider));
        end = _monthEnd(ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider));
        label = DateFormat('MMMM yyyy', 'es_ES').format(start);
        break;
      case 'Año visible':
        start = _yearStart(ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider));
        end = _yearEnd(ProviderScope.containerOf(context, listen: false).read(focusedMonthProvider));
        label = 'Año ${start.year}';
        break;
      case 'Rango de días':
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
          initialDateRange: DateTimeRange(start: _dateOnly(selected), end: _dateOnly(selected)),
          helpText: 'Selecciona los días',
          saveText: 'Continuar',
        );
        if (!mounted || range == null) return;
        start = _dateOnly(range.start);
        end = _dateOnly(range.end);
        label = '${_periodDate(start)} - ${_periodDate(end)}';
        break;
      case 'Varios meses':
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
          initialDateRange: DateTimeRange(start: _monthStart(selected), end: _monthEnd(selected)),
          helpText: 'Selecciona los meses',
          saveText: 'Continuar',
        );
        if (!mounted || range == null) return;
        start = _monthStart(range.start);
        end = _monthEnd(range.end);
        label = '${DateFormat('MMMM yyyy', 'es_ES').format(start)} - ${DateFormat('MMMM yyyy', 'es_ES').format(end)}';
        break;
      default:
        start = _dateOnly(selected);
        end = start;
        label = 'Día ${_periodDate(selected)}';
    }
    await _shareCalendarPeriod(start, end, label, includeTurnos: includeTurnos, includeNotas: includeNotas, format: format);
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

  Future<void> _shareCalendarPeriod(DateTime start, DateTime end, String label, {bool includeTurnos = true, bool includeNotas = true, String format = 'Texto'}) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(cuadranteMapProvider.notifier).reload();
    final calendar = container.read(cuadranteMapProvider);
    await container.read(notasProvider.notifier).reload();
    final notes = container.read(notasProvider);
    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    final lines = <String>[];
    final entries = <CuadranteDay>[];

    if (includeTurnos) for (final values in calendar.values) {
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

    final selectedNotes = includeNotas
        ? notes.where((note) {
            final timestamp = note.startTimeMilliseconds;
            if (timestamp == null) return false;
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final day = _dateOnly(date);
            return !day.isBefore(startDay) && !day.isAfter(endDay);
          }).toList()
        : <Task>[];
    selectedNotes.sort((a, b) => (a.startTimeMilliseconds ?? 0).compareTo(b.startTimeMilliseconds ?? 0));

    lines.add('Calendario — $label');
    lines.add('');

    if (includeTurnos) {
      lines.add('TURNOS');
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
      lines.add('');
    }
    if (includeNotas) {
      lines.add('NOTAS');
      if (selectedNotes.isEmpty) {
        lines.add('No hay notas registradas en este periodo.');
      } else {
        for (final note in selectedNotes) {
          final date = DateTime.fromMillisecondsSinceEpoch(note.startTimeMilliseconds!);
          lines.add('${DateFormat('EEEE dd/MM/yyyy', 'es_ES').format(date)} · ${(note.title ?? 'Nota').trim()}');
          if ((note.site ?? '').trim().isNotEmpty) lines.add('  Lugar: ${note.site!.trim()}');
          if ((note.notes ?? '').trim().isNotEmpty) lines.add('  ${note.notes!.trim()}');
        }
      }
    }

    final exportText = lines.join('\\n');
    switch (format) {
      case 'PDF':
        final document = pw.Document();
        document.addPage(
          pw.MultiPage(
            build: (context) => [
              pw.Header(level: 0, child: pw.Text('Calendario — $label')),
              pw.SizedBox(height: 8),
              ...lines.map((line) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(line.isEmpty ? ' ' : line),
                  )),
            ],
          ),
        );
        final bytes = await document.save();
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: 'calendario.pdf')],
            title: 'Calendario — $label',
            subject: 'Calendario — $label',
          ),
        );
        return;
      case 'Imagen bonita':
      case 'Captura':
        final bytes = await _renderShareImage(lines, label, pretty: format == 'Imagen bonita');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'calendario.png')],
            title: 'Calendario — $label',
            subject: 'Calendario — $label',
          ),
        );
        return;
      default:
        await SharePlus.instance.share(
          ShareParams(
            text: exportText,
            title: 'Compartir calendario',
            subject: 'Calendario — $label',
          ),
        );
    }
  }

  Future<Uint8List> _renderShareImage(List<String> lines, String label, {required bool pretty}) async {
    const double width = 1080;
    const double margin = 64;
    const double contentWidth = width - margin * 2;
    final visibleLines = lines.take(55).toList();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final backgroundPaint = ui.Paint()..color = const Color(0xFFF3F6FB);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, width, 4000), backgroundPaint);
    final headerHeight = pretty ? 220.0 : 150.0;
    final headerPaint = ui.Paint()..color = pretty ? const Color(0xFF3157A4) : const Color(0xFF374151);
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(const ui.Rect.fromLTWH(32, 32, width - 64, 4000), const ui.Radius.circular(34)),
      ui.Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndCorners(
        ui.Rect.fromLTWH(32, 32, width - 64, headerHeight),
        topLeft: const ui.Radius.circular(34),
        topRight: const ui.Radius.circular(34),
      ),
      headerPaint,
    );

    double drawText(String text, double x, double y, double maxWidth, double fontSize, ui.Color color, {bool bold = false}) {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: fontSize,
        fontWeight: bold ? ui.FontWeight.bold : ui.FontWeight.normal,
        maxLines: 3,
      ))
        ..pushStyle(ui.TextStyle(color: color))
        ..addText(text);
      final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
      canvas.drawParagraph(paragraph, ui.Offset(x, y));
      return paragraph.height;
    }

    drawText('CALENDARIO', margin, 58, contentWidth, 24, const ui.Color(0xFFDDE7FF), bold: true);
    drawText(label, margin, 100, contentWidth, pretty ? 38 : 32, const ui.Color(0xFFFFFFFF), bold: true);
    double y = headerHeight + 60;
    for (final line in visibleLines) {
      if (line.isEmpty) {
        y += 14;
        continue;
      }
      final isSection = line == 'TURNOS' || line == 'NOTAS';
      if (isSection) {
        y += 12;
        canvas.drawRRect(
          ui.RRect.fromRectAndRadius(ui.Rect.fromLTWH(margin - 12, y - 4, contentWidth + 24, 46), const ui.Radius.circular(12)),
          ui.Paint()..color = const ui.Color(0xFFE8EEF9),
        );
      }
      final height = drawText(
        line,
        margin,
        y,
        contentWidth,
        isSection ? 23 : (pretty ? 21 : 19),
        isSection ? const ui.Color(0xFF3157A4) : const ui.Color(0xFF263247),
        bold: isSection || line.startsWith('Calendario') || line.contains('·'),
      );
      y += height + (pretty ? 17 : 12);
    }
    y += 48;
    final image = await recorder.endRecording().toImage(width.toInt(), y.ceil().clamp(1, 4000).toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('No se pudo generar la imagen del calendario.');
    return data.buffer.asUint8List();
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
                Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: TextButton(
                    key: _showHomeTutorial
                        ? tutorialController.keyButton7
                        : widget.key,
                    onPressed: () {
                      final hoy = DateTime.now();
                      final container = ProviderScope.containerOf(context, listen: false);
                      container.read(focusedMonthProvider.notifier).setFocusedDay(hoy);
                      container.read(selectedDayProvider.notifier).setSelectedDay(hoy);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: PRIMARY_COLOR,
                      backgroundColor: PRIMARY_COLOR.withOpacity(.10),
                      minimumSize: Size(0, 32.h),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('HOY', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: .35)),
                  ),
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

class _ShareFormatChip extends StatelessWidget {
  const _ShareFormatChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 17.sp, color: selected ? Colors.white : PRIMARY_COLOR),
      label: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      selectedColor: PRIMARY_COLOR,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55),
      labelStyle: TextStyle(color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      side: BorderSide(color: selected ? PRIMARY_COLOR : Theme.of(context).dividerColor.withOpacity(.35)),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
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
