import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class NotasView extends ConsumerStatefulWidget {
  const NotasView({Key? key, this.routeArguments}) : super(key: key);

  final Object? routeArguments;

  @override
  ConsumerState<NotasView> createState() => _NotasViewState();
}

class _NotasViewState extends ConsumerState<NotasView> {
  late Task _note;
  bool _headerVisible = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();

    final args = widget.routeArguments;
    final noteData = args is Map ? args['noteData'] : null;

    if (noteData is Task) {
      _note = noteData;
    } else {
      _note = Task();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _headerVisible = true);
    });
  }

  DateTime? get _start {
    final value = _note.startTimeMilliseconds;
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  DateTime? get _end {
    final value = _note.endTimeMilliseconds;
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  String _dateTime(DateTime? value) =>
      value == null ? '—' : value.formatDateTime24H.toString();

  String _date(DateTime? value) =>
      value == null ? '—' : value.formatDateYMMMd.toString();

  Future<void> _toggleImportant() async {
    final id = _note.id;
    if (id == null) {
      Toast.toast(context, msg: 'No se puede actualizar una nota sin ID.');
      return;
    }

    final updated = Task(
      id: _note.id,
      title: _note.title,
      site: _note.site,
      notes: _note.notes,
      startTimeMilliseconds: _note.startTimeMilliseconds,
      endTimeMilliseconds: _note.endTimeMilliseconds,
      isImportant: !(_note.isImportant ?? false),
      idAlarma: _note.idAlarma,
      alarmaHora: _note.alarmaHora,
      alarmaTimestamp: _note.alarmaTimestamp,
      alarmaActivadaString: _note.alarmaActivadaString,
      isAlarmaCreated: _note.isAlarmaCreated,
    );

    await ref.read(notasListProvider.notifier).actualizarNota(updated);
    if (!mounted) return;

    setState(() => _note = updated);
  }

  Future<void> _shareNote() async {
    final start = _start;
    final end = _end;

    await SharePlus.instance.share(
      ShareParams(
        text: 'Titulo: ${_note.title ?? ''}'
            '\nNota: ${_note.notes ?? ''}'
            '\nInicio: ${_dateTime(start)} h. ${_date(start)}'
            '\nFin: ${_dateTime(end)} h. ${_date(end)}',
      ),
    );
  }

  void _editNote() {
    final id = _note.id;
    if (id == null) {
      Toast.toast(context, msg: 'No se puede editar una nota sin ID.');
      return;
    }

    context.push('/edit-notas', extra: {'id': id, 'noteData': _note});
  }

  Future<void> _deleteNote() async {
    final id = _note.id;
    if (id == null || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Borrar nota'),
        content: const Text('Se borrará permanentemente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'CANCELAR',
              style: TextStyle(color: Theme.of(dialogContext).primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'BORRAR',
              style: TextStyle(
                color: Colors.red.shade300,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(notasListProvider.notifier).eliminarNota(id);
      if (!mounted) return;
      Toast.toast(context, msg: 'Eliminado exitosamente!');
      context.go('/notas');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 7.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
        ),
      ),
    );
  }

  Widget _infoCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .35),
        ),
      ),
      child: child,
    );
  }

  Widget _dateCard(DateTime? start, DateTime? end) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .62);
    return _infoCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: PRIMARY_COLOR, size: 21.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inicio', style: TextStyle(fontSize: 12.sp, color: muted)),
                    SizedBox(height: 2.h),
                    Text(
                      '${_dateTime(start)} · ${_date(start)}',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .3)),
          ),
          Row(
            children: [
              Icon(Icons.event_available_rounded, color: PRIMARY_COLOR, size: 21.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fin', style: TextStyle(fontSize: 12.sp, color: muted)),
                    SizedBox(height: 2.h),
                    Text(
                      '${_dateTime(end)} · ${_date(end)}',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusTile({required bool important, required bool hasAlarm}) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: .58);
    return _infoCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      child: Row(
        children: [
          Icon(
            important ? Icons.flag_rounded : Icons.outlined_flag,
            color: important ? Colors.red : PRIMARY_COLOR,
            size: 21.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              important ? 'Nota importante' : 'Nota normal',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
          if (hasAlarm) ...[
            Container(
              width: 1,
              height: 22.h,
              color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
            ),
            SizedBox(width: 10.w),
            Icon(Icons.notifications_active_outlined, color: PRIMARY_COLOR, size: 20.sp),
            SizedBox(width: 7.w),
            Text(
              _note.alarmaActivadaString ?? 'Recordatorio',
              style: TextStyle(fontSize: 12.sp, color: muted, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _start;
    final end = _end;
    final important = _note.isImportant ?? false;
    final hasAlarm = _note.isAlarmaCreated ?? false;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: .62);
    final title = (_note.title == null || _note.title!.trim().isEmpty)
        ? 'Sin título'
        : _note.title!;
    final site = (_note.site == null || _note.site!.trim().isEmpty)
        ? 'No hay ubicación'
        : _note.site!;
    final notes = (_note.notes == null || _note.notes!.trim().isEmpty)
        ? 'No has añadido descripción'
        : _note.notes!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notas',
          style: CustomTextStyle.appBarTitle(context: context),
          overflow: TextOverflow.visible,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: PRIMARY_COLOR, size: 24.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: important ? 'Quitar importancia' : 'Marcar importante',
            icon: Icon(
              important ? Icons.flag_rounded : Icons.outlined_flag,
              size: 24.sp,
              color: important ? Colors.red : PRIMARY_COLOR,
            ),
            onPressed: _toggleImportant,
          ),
          IconButton(
            tooltip: 'Eliminar nota',
            icon: Icon(Icons.delete_outline_rounded, color: PRIMARY_COLOR, size: 24.sp),
            onPressed: _deleteNote,
          ),
          IconButton(
            tooltip: 'Compartir nota',
            icon: Icon(Icons.share_outlined, color: PRIMARY_COLOR, size: 24.sp),
            onPressed: _shareNote,
          ),
          IconButton(
            tooltip: 'Editar nota',
            icon: Icon(Icons.edit_outlined, color: PRIMARY_COLOR, size: 24.sp),
            onPressed: _editNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: _headerVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 18.h),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 27.sp,
                        height: 1.12,
                      ),
                    ),
                  ),
                ),
                _sectionLabel('FECHA Y HORA'),
                _dateCard(start, end),
                SizedBox(height: 16.h),
                _sectionLabel('UBICACIÓN'),
                _infoCard(
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: PRIMARY_COLOR, size: 21.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          site,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: (_note.site == null || _note.site!.trim().isEmpty)
                                ? muted
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _sectionLabel('ESTADO'),
                _statusTile(important: important, hasAlarm: hasAlarm),
                SizedBox(height: 16.h),
                _sectionLabel('DESCRIPCIÓN'),
                _infoCard(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: (_note.notes == null || _note.notes!.trim().isEmpty)
                          ? muted
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_deleting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
