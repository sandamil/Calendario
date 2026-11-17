import 'dart:convert';

import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';

import '../services/shift_analytics.dart';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InformesView extends StatelessWidget {
  const InformesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al menú',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text('Informes'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        children: [
          Text(
            'Informes',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Consulta y analiza la información de tu calendario.',
            style: TextStyle(
              fontSize: 13.sp,
              color: text.withValues(alpha: .62),
            ),
          ),
          SizedBox(height: 20.h),
          _ReportOption(
            icon: Icons.work_history_rounded,
            title: 'Resumen de turnos',
            subtitle: 'Días, horas y distribución de tus turnos por periodo.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResumenTurnosView()),
            ),
          ),
          SizedBox(height: 12.h),
          _ReportOption(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Exportar informe',
            subtitle: 'Comparte el resumen y los turnos en PDF o CSV.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResumenTurnosView()),
            ),
          ),
          SizedBox(height: 12.h),
          _ReportOption(
            icon: Icons.bar_chart_rounded,
            title: 'Estadísticas',
            subtitle:
                'Más estadísticas y análisis del calendario próximamente.',
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReportOption extends StatelessWidget {
  const _ReportOption({
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
    final text = theme.colorScheme.onSurface;
    final opacity = enabled ? 1.0 : .48;
    return Opacity(
      opacity: opacity,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: .04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(icon, color: PRIMARY_COLOR, size: 25.sp),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.3,
                          color: text.withValues(alpha: .62),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: text.withValues(alpha: .45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResumenTurnosView extends StatefulWidget {
  const ResumenTurnosView({super.key});

  @override
  State<ResumenTurnosView> createState() => _ResumenTurnosViewState();
}

class _ResumenTurnosViewState extends State<ResumenTurnosView> {
  late Future<List<CuadranteDay>> _future;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  _ReportPeriod _period = _ReportPeriod.month;
  SalarySettings _salarySettings = const SalarySettings();

  @override
  void initState() {
    super.initState();
    _future = CalendarioDB().getCuadranteList();
    _loadSalarySettings();
  }

  Future<void> _loadSalarySettings() async {
    try {
      final settings = await SalarySettingsStore().load();
      if (mounted) setState(() => _salarySettings = settings);
    } catch (_) {
      // El informe sigue disponible aunque fallen las preferencias salariales.
    }
  }

  Future<void> _editSalarySettings() async {
    final hourly = TextEditingController(
      text: _salarySettings.hourlyRate.toStringAsFixed(2),
    );
    final night = TextEditingController(
      text: _salarySettings.nightExtraPerHour.toStringAsFixed(2),
    );
    final weekend = TextEditingController(
      text: _salarySettings.weekendExtraPerHour.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<SalarySettings>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Estimación salarial'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Introduce importes brutos por hora. Los pluses se suman a las horas que correspondan.',
                ),
                const SizedBox(height: 12),
                _rateField(hourly, 'Tarifa base por hora (€)'),
                const SizedBox(height: 8),
                _rateField(night, 'Plus nocturno por hora (€)'),
                const SizedBox(height: 8),
                _rateField(weekend, 'Plus fin de semana por hora (€)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                SalarySettings(
                  hourlyRate: _parseRate(hourly.text),
                  nightExtraPerHour: _parseRate(night.text),
                  weekendExtraPerHour: _parseRate(weekend.text),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    hourly.dispose();
    night.dispose();
    weekend.dispose();
    if (result == null || !mounted) return;
    try {
      await SalarySettingsStore().save(result);
      if (mounted) setState(() => _salarySettings = result);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron guardar los importes: $error'),
          ),
        );
    }
  }

  Widget _rateField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.euro_rounded),
        ),
        validator: (value) {
          final parsed = _parseRate(value ?? '');
          return parsed.isFinite && parsed >= 0 && parsed <= 10000
              ? null
              : 'Introduce un importe válido';
        },
      );

  double _parseRate(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.')) ?? double.nan;

  Future<void> _exportReport(
    List<CuadranteDay> rows,
    ShiftAnalyticsResult analytics,
  ) async {
    final format = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('Compartir PDF'),
              onTap: () => Navigator.pop(sheetContext, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('Compartir CSV (Excel)'),
              onTap: () => Navigator.pop(sheetContext, 'csv'),
            ),
          ],
        ),
      ),
    );
    if (format == null || !mounted) return;
    final label = _periodLabel();
    if (format == 'pdf') {
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Informe de turnos')),
            pw.Paragraph(text: 'Periodo: ' + label),
            pw.Paragraph(
              text:
                  'Turnos: ' +
                  analytics.workedShifts.toString() +
                  ' · Horas: ' +
                  _formatHours(analytics.totalHours) +
                  ' · Nocturnas: ' +
                  _formatHours(analytics.nightHours) +
                  ' · Fin de semana: ' +
                  _formatHours(analytics.weekendHours),
            ),
            pw.Paragraph(
              text:
                  'Días libres: ' +
                  analytics.freeDays.toString() +
                  ' · Bruto estimado: ' +
                  _salarySettings.estimate(analytics).toStringAsFixed(2) +
                  ' €',
            ),
            pw.Table(
              border: pw.TableBorder.all(
                color: const pdf.PdfColor(0.75, 0.75, 0.75),
              ),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: pdf.PdfColor(0.9, 0.92, 0.96),
                  ),
                  children: ['Fecha', 'Turno', 'Inicio', 'Fin', 'Horas']
                      .map(
                        (value) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            value,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...rows.map((row) {
                  final date = row.dateTime;
                  final rowStats = ShiftAnalytics.calculate([row]);
                  final dateLabel = date == null
                      ? ''
                      : date.day.toString().padLeft(2, '0') +
                            '/' +
                            date.month.toString().padLeft(2, '0') +
                            '/' +
                            date.year.toString();
                  return pw.TableRow(
                    children:
                        [
                              dateLabel,
                              row.description ?? row.title ?? 'Turno',
                              row.startHour ?? '',
                              row.endHour ?? '',
                              _formatHours(rowStats.totalHours),
                            ]
                            .map(
                              (value) => pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  value,
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            )
                            .toList(),
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Estimación bruta orientativa. No sustituye una nómina ni incluye retenciones, convenio u otros complementos no configurados.',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      );
      final bytes = await document.save();
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
              name: 'informe-turnos.pdf',
            ),
          ],
          title: 'Informe de turnos - ' + label,
        ),
      );
      return;
    }

    String csvField(Object? value) {
      final text = value?.toString() ?? '';
      return '"' + text.replaceAll('"', '""') + '"';
    }

    final lines = <List<Object?>>[
      [
        'Fecha',
        'Cuadrante',
        'Turno',
        'Inicio',
        'Fin',
        'Horas',
        'Horas nocturnas',
        'Horas fin de semana',
      ],
    ];
    for (final row in rows) {
      final date = row.dateTime;
      final dateLabel = date == null
          ? ''
          : date.year.toString() +
                '-' +
                date.month.toString().padLeft(2, '0') +
                '-' +
                date.day.toString().padLeft(2, '0');
      final stats = ShiftAnalytics.calculate([row]);
      lines.add([
        dateLabel,
        row.cuadranteName,
        row.description ?? row.title,
        row.startHour,
        row.endHour,
        stats.totalHours.toStringAsFixed(2),
        stats.nightHours.toStringAsFixed(2),
        stats.weekendHours.toStringAsFixed(2),
      ]);
    }
    final csv =
        '\uFEFF' +
        lines.map((line) => line.map(csvField).join(';')).join('\r\n');
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(csv),
            mimeType: 'text/csv',
            name: 'informe-turnos.csv',
          ),
        ],
        title: 'Informe de turnos - ' + label,
      ),
    );
  }

  void _reload() {
    setState(() => _future = CalendarioDB().getCuadranteList());
  }

  Future<void> _selectRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
      initialDateRange: _rangeStart != null && _rangeEnd != null
          ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
          : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      helpText: 'Selecciona el periodo del informe',
      saveText: 'Aplicar',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeStart = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      _rangeEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
        999,
      );
      _period = _ReportPeriod.range;
    });
  }

  String _periodLabel() {
    switch (_period) {
      case _ReportPeriod.month:
        return '${_monthName(_month)} $_year';
      case _ReportPeriod.year:
        return 'Año $_year';
      case _ReportPeriod.range:
        if (_rangeStart == null || _rangeEnd == null) return 'Rango de fechas';
        return '${_dateLabel(_rangeStart!)} – ${_dateLabel(_rangeEnd!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver a Informes',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Resumen de turnos'),
        actions: [
          IconButton(
            tooltip: 'Configurar estimación salarial',
            onPressed: _editSalarySettings,
            icon: const Icon(Icons.euro_rounded),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<CuadranteDay>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'No se ha podido cargar el informe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, color: text),
                ),
              ),
            );
          final all = snapshot.data ?? const <CuadranteDay>[];
          final rows = all.where(_matchesPeriod).toList()
            ..sort(
              (a, b) => (a.dateTime ?? DateTime(1900)).compareTo(
                b.dateTime ?? DateTime(1900),
              ),
            );
          final analytics = ShiftAnalytics.calculate(rows);
          final shiftCounts = analytics.distribution;
          final estimatedGross = _salarySettings.estimate(analytics);
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
              children: [
                Text(
                  'Resumen de turnos',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Consulta rápidamente cuántos días y horas tienes asignados.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: text.withValues(alpha: .62),
                  ),
                ),
                SizedBox(height: 16.h),
                _PeriodSelector(
                  period: _period,
                  year: _year,
                  month: _month,
                  label: _periodLabel(),
                  onPeriodChanged: (value) => setState(() => _period = value),
                  onYearChanged: (value) => setState(() => _year = value),
                  onMonthChanged: (value) => setState(() => _month = value),
                  onRangeTap: _selectRange,
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.event_available_rounded,
                        value: '${rows.length}',
                        label: 'Días',
                        text: text,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.schedule_rounded,
                        value: _formatHours(analytics.totalHours),
                        label: 'Horas',
                        text: text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _SummaryCard(
                  icon: Icons.work_history_rounded,
                  value: '${analytics.workedShifts}',
                  label: 'Turnos trabajados',
                  text: text,
                  wide: true,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.nightlight_round,
                        value: _formatHours(analytics.nightHours),
                        label: 'Horas nocturnas',
                        text: text,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.weekend_rounded,
                        value: _formatHours(analytics.weekendHours),
                        label: 'Horas fin de semana',
                        text: text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.beach_access_rounded,
                        value: '${analytics.freeDays}',
                        label: 'Días libres',
                        text: text,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.euro_rounded,
                        value: '${estimatedGross.toStringAsFixed(2)} €',
                        label: 'Bruto estimado',
                        text: text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                OutlinedButton.icon(
                  onPressed: () => _exportReport(rows, analytics),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Exportar informe PDF o CSV'),
                ),
                SizedBox(height: 22.h),
                Text(
                  'Distribución',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                SizedBox(height: 9.h),
                if (shiftCounts.isEmpty)
                  _EmptyCard(text: text)
                else
                  ...shiftCounts.entries.map(
                    (entry) => _DistributionRow(
                      name: entry.key,
                      count: entry.value,
                      total: analytics.workedShifts,
                      text: text,
                    ),
                  ),
                SizedBox(height: 22.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: PRIMARY_COLOR,
                        size: 21.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Estimación bruta orientativa: tarifa base más los pluses configurados. No sustituye una nómina ni incluye retenciones, convenio u otros complementos. Los registros con horarios no válidos se excluyen (${analytics.invalidShifts}).',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.35,
                            color: text.withValues(alpha: .72),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesPeriod(CuadranteDay item) {
    final date = item.dateTime;
    if (date == null) return false;
    switch (_period) {
      case _ReportPeriod.month:
        return date.year == _year && date.month == _month;
      case _ReportPeriod.year:
        return date.year == _year;
      case _ReportPeriod.range:
        if (_rangeStart == null || _rangeEnd == null) return false;
        return !date.isBefore(_rangeStart!) && !date.isAfter(_rangeEnd!);
    }
  }

  String _formatHours(double value) => value == value.roundToDouble()
      ? '${value.toInt()} h'
      : '${value.toStringAsFixed(1)} h';

  String _monthName(int month) => const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ][month - 1];
  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

enum _ReportPeriod { month, year, range }

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.period,
    required this.year,
    required this.month,
    required this.label,
    required this.onPeriodChanged,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onRangeTap,
  });

  final _ReportPeriod period;
  final int year;
  final int month;
  final String label;
  final ValueChanged<_ReportPeriod> onPeriodChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;
  final VoidCallback onRangeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SegmentedButton<_ReportPeriod>(
          segments: const [
            ButtonSegment(
              value: _ReportPeriod.month,
              label: Text('Mes'),
              icon: Icon(Icons.calendar_view_month_rounded),
            ),
            ButtonSegment(
              value: _ReportPeriod.year,
              label: Text('Año'),
              icon: Icon(Icons.calendar_today_rounded),
            ),
            ButtonSegment(
              value: _ReportPeriod.range,
              label: Text('Rango'),
              icon: Icon(Icons.date_range_rounded),
            ),
          ],
          selected: {period},
          onSelectionChanged: (value) {
            final selected = value.first;
            if (selected == _ReportPeriod.range) {
              onRangeTap();
            } else {
              onPeriodChanged(selected);
            }
          },
        ),
        SizedBox(height: 10.h),
        if (period == _ReportPeriod.month)
          Row(
            children: [
              Expanded(
                child: _Drop<int>(
                  value: month,
                  items: List.generate(
                    12,
                    (i) => MapEntry(
                      i + 1,
                      const [
                        'Enero',
                        'Febrero',
                        'Marzo',
                        'Abril',
                        'Mayo',
                        'Junio',
                        'Julio',
                        'Agosto',
                        'Septiembre',
                        'Octubre',
                        'Noviembre',
                        'Diciembre',
                      ][i],
                    ),
                  ),
                  onChanged: onMonthChanged,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _YearDrop(value: year, onChanged: onYearChanged),
              ),
            ],
          )
        else if (period == _ReportPeriod.year)
          _YearDrop(value: year, onChanged: onYearChanged)
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: .55,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: .35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: TextStyle(fontSize: 14.sp)),
                ),
                Icon(Icons.edit_calendar_rounded, color: PRIMARY_COLOR),
              ],
            ),
          ),
      ],
    );
  }
}

class _Drop<T> extends StatelessWidget {
  const _Drop({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final T value;
  final List<MapEntry<T, String>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: .55),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant
            .withValues(alpha: .35),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ),
  );
}

class _YearDrop extends StatelessWidget {
  const _YearDrop({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = DateTime.now().year;
    final years = List.generate(21, (index) => current - 10 + index);
    return _Drop<int>(
      value: years.contains(value) ? value : current,
      items: years.map((year) => MapEntry(year, '$year')).toList(),
      onChanged: onChanged,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.text,
    this.wide = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color text;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: PRIMARY_COLOR.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(icon, color: PRIMARY_COLOR, size: 22.sp),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: text.withValues(alpha: .58),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.name,
    required this.count,
    required this.total,
    required this.text,
  });
  final String name;
  final int count;
  final int total;
  final Color text;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Container(
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: .48),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                ),
                Text(
                  '$count días',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(value: fraction, minHeight: 7.h),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final Color text;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: .45),
      borderRadius: BorderRadius.circular(18.r),
    ),
    child: Text(
      'No hay turnos trabajados en el periodo seleccionado.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13.sp, color: text.withValues(alpha: .6)),
    ),
  );
}
