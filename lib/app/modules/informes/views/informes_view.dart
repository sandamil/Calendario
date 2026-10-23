import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/model/cuadranteDay.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InformesView extends StatefulWidget {
  const InformesView({super.key});

  @override
  State<InformesView> createState() => _InformesViewState();
}

class _InformesViewState extends State<InformesView> {
  late int _month;
  late Future<List<CuadranteDay>> _future;

  @override
  void initState() {
    super.initState();
    _month = DateTime.now().month;
    _future = CalendarioDB().getCuadranteList();
  }

  void _reload() {
    setState(() {
      _future = CalendarioDB().getCuadranteList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes'),
        actions: [
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
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
          }

          final all = snapshot.data ?? const <CuadranteDay>[];
          final rows = all.where((item) => item.dateTime?.month == _month).toList()
            ..sort((a, b) => (a.dateTime ?? DateTime(1900)).compareTo(b.dateTime ?? DateTime(1900)));

          final totalDays = rows.length;
          final workingRows = rows.where((item) => !_isFree(item)).toList();
          final totalHours = workingRows.fold<double>(0, (sum, item) => sum + _hours(item));
          final shiftCounts = <String, int>{};
          for (final item in workingRows) {
            final name = (item.description?.trim().isNotEmpty ?? false)
                ? item.description!.trim()
                : (item.title?.trim().isNotEmpty ?? false)
                    ? item.title!.trim()
                    : 'Sin nombre';
            shiftCounts[name] = (shiftCounts[name] ?? 0) + 1;
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
              children: [
                Text(
                  'Resumen de turnos',
                  style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w800, color: text),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Consulta rápidamente cuántos días y horas tienes asignados.',
                  style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.62)),
                ),
                SizedBox(height: 16.h),
                _MonthSelector(
                  month: _month,
                  onChanged: (value) => setState(() => _month = value),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(icon: Icons.event_available_rounded, value: '$totalDays', label: 'Días', text: text)),
                    SizedBox(width: 10.w),
                    Expanded(child: _SummaryCard(icon: Icons.schedule_rounded, value: _formatHours(totalHours), label: 'Horas', text: text)),
                  ],
                ),
                SizedBox(height: 10.h),
                _SummaryCard(
                  icon: Icons.work_history_rounded,
                  value: '${workingRows.length}',
                  label: 'Turnos trabajados',
                  text: text,
                  wide: true,
                ),
                SizedBox(height: 22.h),
                Text(
                  'Distribución',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: text),
                ),
                SizedBox(height: 9.h),
                if (shiftCounts.isEmpty)
                  _EmptyCard(text: text)
                else
                  ...shiftCounts.entries.map(
                    (entry) => _DistributionRow(
                      name: entry.key,
                      count: entry.value,
                      total: workingRows.length,
                      text: text,
                    ),
                  ),
                SizedBox(height: 22.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR.withOpacity(.08),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: PRIMARY_COLOR, size: 21.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Las horas se calculan a partir de la hora de inicio y fin de cada turno. Los días libres no suman horas.',
                          style: TextStyle(fontSize: 12.5.sp, height: 1.35, color: text.withOpacity(.72)),
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

  String _formatHours(double value) {
    if (value == value.roundToDouble()) return '${value.toInt()} h';
    return '${value.toStringAsFixed(1)} h';
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month, required this.onChanged});

  final int month;
  final ValueChanged<int> onChanged;

  static const _months = <String>[
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(.55),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.35)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: month,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: List.generate(
            _months.length,
            (index) => DropdownMenuItem(value: index + 1, child: Text(_months[index])),
          ),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.4)),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(color: PRIMARY_COLOR.withOpacity(.12), borderRadius: BorderRadius.circular(13.r)),
            child: Icon(icon, color: PRIMARY_COLOR, size: 22.sp),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800, color: text)),
                SizedBox(height: 2.h),
                Text(label, style: TextStyle(fontSize: 11.5.sp, color: text.withOpacity(.58))),
              ],
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Container(
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.48),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: text))),
                Text('$count días', style: TextStyle(fontSize: 12.sp, color: text.withOpacity(.6))),
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.45),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        'No hay turnos trabajados en el mes seleccionado.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.6)),
      ),
    );
  }
}
