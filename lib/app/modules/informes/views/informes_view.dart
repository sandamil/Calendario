import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
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
          Text('Informes', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: text)),
          SizedBox(height: 5.h),
          Text('Consulta y analiza la información de tu calendario.', style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.62))),
          SizedBox(height: 20.h),
          _ReportOption(
            icon: Icons.work_history_rounded,
            title: 'Resumen de turnos',
            subtitle: 'Días, horas y distribución de tus turnos por periodo.',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResumenTurnosView())),
          ),
          SizedBox(height: 12.h),
          _ReportOption(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Exportar a PDF',
            subtitle: 'Prepararemos la exportación de informes en PDF.',
            enabled: false,
            onTap: () {},
          ),
          SizedBox(height: 12.h),
          _ReportOption(
            icon: Icons.bar_chart_rounded,
            title: 'Estadísticas',
            subtitle: 'Más estadísticas y análisis del calendario próximamente.',
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReportOption extends StatelessWidget {
  const _ReportOption({required this.icon, required this.title, required this.subtitle, required this.onTap, this.enabled = true});

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
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.4)),
              boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(width: 48.w, height: 48.w, decoration: BoxDecoration(color: PRIMARY_COLOR.withOpacity(.12), borderRadius: BorderRadius.circular(15.r)), child: Icon(icon, color: PRIMARY_COLOR, size: 25.sp)),
                SizedBox(width: 13.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: text)),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, height: 1.3, color: text.withOpacity(.62))),
                ])),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right_rounded, color: text.withOpacity(.45)),
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

  @override
  void initState() {
    super.initState();
    _future = CalendarioDB().getCuadranteList();
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
      initialDateRange: _rangeStart != null && _rangeEnd != null ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!) : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      helpText: 'Selecciona el periodo del informe',
      saveText: 'Aplicar',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeStart = DateTime(picked.start.year, picked.start.month, picked.start.day);
      _rangeEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);
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
        leading: IconButton(tooltip: 'Volver a Informes', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Resumen de turnos'),
        actions: [IconButton(tooltip: 'Actualizar', onPressed: _reload, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<CuadranteDay>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Padding(padding: EdgeInsets.all(24.w), child: Text('No se ha podido cargar el informe.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, color: text))));
          final all = snapshot.data ?? const <CuadranteDay>[];
          final rows = all.where(_matchesPeriod).toList()..sort((a, b) => (a.dateTime ?? DateTime(1900)).compareTo(b.dateTime ?? DateTime(1900)));
          final workingRows = rows.where((item) => !_isFree(item)).toList();
          final totalHours = workingRows.fold<double>(0, (sum, item) => sum + _hours(item));
          final shiftCounts = <String, int>{};
          for (final item in workingRows) {
            final name = (item.description?.trim().isNotEmpty ?? false) ? item.description!.trim() : (item.title?.trim().isNotEmpty ?? false) ? item.title!.trim() : 'Sin nombre';
            shiftCounts[name] = (shiftCounts[name] ?? 0) + 1;
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
              children: [
                Text('Resumen de turnos', style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w800, color: text)),
                SizedBox(height: 5.h),
                Text('Consulta rápidamente cuántos días y horas tienes asignados.', style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.62))),
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
                Row(children: [
                  Expanded(child: _SummaryCard(icon: Icons.event_available_rounded, value: '${rows.length}', label: 'Días', text: text)),
                  SizedBox(width: 10.w),
                  Expanded(child: _SummaryCard(icon: Icons.schedule_rounded, value: _formatHours(totalHours), label: 'Horas', text: text)),
                ]),
                SizedBox(height: 10.h),
                _SummaryCard(icon: Icons.work_history_rounded, value: '${workingRows.length}', label: 'Turnos trabajados', text: text, wide: true),
                SizedBox(height: 22.h),
                Text('Distribución', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: text)),
                SizedBox(height: 9.h),
                if (shiftCounts.isEmpty) _EmptyCard(text: text) else ...shiftCounts.entries.map((entry) => _DistributionRow(name: entry.key, count: entry.value, total: workingRows.length, text: text)),
                SizedBox(height: 22.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(color: PRIMARY_COLOR.withOpacity(.08), borderRadius: BorderRadius.circular(18.r)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: PRIMARY_COLOR, size: 21.sp),
                    SizedBox(width: 10.w),
                    Expanded(child: Text('Las horas se calculan a partir de la hora de inicio y fin de cada turno. Los días libres no suman horas.', style: TextStyle(fontSize: 12.5.sp, height: 1.35, color: text.withOpacity(.72)))),
                  ]),
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

  bool _isFree(CuadranteDay item) {
    final title = item.title?.trim().toLowerCase();
    final description = item.description?.trim().toLowerCase();
    return title == 'l' || description == 'libre';
  }

  double _hours(CuadranteDay item) {
    final start = _minutes(item.startHour);
    final end = _minutes(item.endHour);
    if (start == null || end == null) return 0;
    var difference = end - start;
    if (difference < 0) difference += 24 * 60;
    return difference / 60;
  }

  int? _minutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  String _formatHours(double value) => value == value.roundToDouble() ? '${value.toInt()} h' : '${value.toStringAsFixed(1)} h';

  String _monthName(int month) => const ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][month - 1];
  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

enum _ReportPeriod { month, year, range }

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.year, required this.month, required this.label, required this.onPeriodChanged, required this.onYearChanged, required this.onMonthChanged, required this.onRangeTap});

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
    return Column(children: [
      SegmentedButton<_ReportPeriod>(
        segments: const [
          ButtonSegment(value: _ReportPeriod.month, label: Text('Mes'), icon: Icon(Icons.calendar_view_month_rounded)),
          ButtonSegment(value: _ReportPeriod.year, label: Text('Año'), icon: Icon(Icons.calendar_today_rounded)),
          ButtonSegment(value: _ReportPeriod.range, label: Text('Rango'), icon: Icon(Icons.date_range_rounded)),
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
      if (period == _ReportPeriod.month) Row(children: [
        Expanded(child: _Drop<int>(value: month, items: List.generate(12, (i) => MapEntry(i + 1, const ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][i])), onChanged: onMonthChanged)),
        SizedBox(width: 10.w),
        Expanded(child: _YearDrop(value: year, onChanged: onYearChanged)),
      ]) else if (period == _ReportPeriod.year) _YearDrop(value: year, onChanged: onYearChanged) else Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(.55), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35))),
        child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: 14.sp))), Icon(Icons.edit_calendar_rounded, color: PRIMARY_COLOR)]),
      ),
    ]);
  }
}

class _Drop<T> extends StatelessWidget {
  const _Drop({required this.value, required this.items, required this.onChanged});
  final T value;
  final List<MapEntry<T, String>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.35))),
    child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value, isExpanded: true, items: items.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(), onChanged: (value) { if (value != null) onChanged(value); })),
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
    return _Drop<int>(value: years.contains(value) ? value : current, items: years.map((year) => MapEntry(year, '$year')).toList(), onChanged: onChanged);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.value, required this.label, required this.text, this.wide = false});
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
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.4)), boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(width: 42.w, height: 42.w, decoration: BoxDecoration(color: PRIMARY_COLOR.withOpacity(.12), borderRadius: BorderRadius.circular(13.r)), child: Icon(icon, color: PRIMARY_COLOR, size: 22.sp)),
        SizedBox(width: 11.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800, color: text)), SizedBox(height: 2.h), Text(label, style: TextStyle(fontSize: 11.5.sp, color: text.withOpacity(.58)))])),
      ]),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({required this.name, required this.count, required this.total, required this.text});
  final String name;
  final int count;
  final int total;
  final Color text;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(padding: EdgeInsets.only(bottom: 9.h), child: Container(padding: EdgeInsets.all(13.w), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.48), borderRadius: BorderRadius.circular(16.r)), child: Column(children: [
      Row(children: [Expanded(child: Text(name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: text))), Text('$count días', style: TextStyle(fontSize: 12.sp, color: text.withOpacity(.6)))]),
      SizedBox(height: 8.h),
      ClipRRect(borderRadius: BorderRadius.circular(20.r), child: LinearProgressIndicator(value: fraction, minHeight: 7.h)),
    ])));
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final Color text;
  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.all(18.w), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.45), borderRadius: BorderRadius.circular(18.r)), child: Text('No hay turnos trabajados en el periodo seleccionado.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.6))));
}
