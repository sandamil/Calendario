import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({required this.noteData, required this.onTapAction, required this.routeToNotas, this.focusedDay, this.selectedDay, super.key});
  final Task noteData;
  final Function(Task noteData) onTapAction;
  final bool routeToNotas;
  final selectedDay;
  final focusedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final start = DateTime.fromMillisecondsSinceEpoch(noteData.startTimeMilliseconds ?? DateTime.now().millisecondsSinceEpoch);
    final end = DateTime.fromMillisecondsSinceEpoch(noteData.endTimeMilliseconds ?? noteData.startTimeMilliseconds ?? DateTime.now().millisecondsSinceEpoch);
    final accent = noteData.isImportant == true ? Colors.deepOrange : PRIMARY_COLOR;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Slidable(
        key: ValueKey('note-${noteData.id}'),
        endActionPane: ActionPane(motion: const DrawerMotion(), extentRatio: .42, children: [
          SlidableAction(label: 'Compartir', icon: Icons.share_rounded, backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.black, borderRadius: BorderRadius.circular(16.r), onPressed: (_) => Share.share('Título: ${noteData.title}\nNota: ${noteData.notes}\nInicio: ${start.formatDateTime24H} h.  ${start.formatDateYMMMd}\nFin: ${end.formatDateTime24H} h.  ${end.formatDateYMMMd}')),
          SlidableAction(label: 'Eliminar', icon: Icons.delete_outline_rounded, backgroundColor: Colors.redAccent, foregroundColor: Colors.white, borderRadius: BorderRadius.circular(16.r), onPressed: (_) => _confirmDelete(context, ref)),
        ]),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            onTap: () => onTapAction(noteData),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.42)),
                boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(.035), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 43.w, height: 43.w, alignment: Alignment.center, decoration: BoxDecoration(color: accent.withOpacity(.14), borderRadius: BorderRadius.circular(14.r)), child: Icon(noteData.isImportant == true ? Icons.star_rounded : Icons.sticky_note_2_outlined, color: accent, size: 22.sp)),
                SizedBox(width: 11.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((noteData.title ?? '').trim().isEmpty ? 'Nota sin título' : noteData.title!.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: text)),
                  if ((noteData.notes ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(noteData.notes!.trim().split('\n').first, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, height: 1.3, color: text.withOpacity(.65))),
                  ],
                  SizedBox(height: 8.h),
                  Wrap(spacing: 10.w, runSpacing: 4.h, children: [
                    _NoteMeta(icon: Icons.calendar_today_rounded, text: DateFormat('dd/MM/yyyy').format(start)),
                    _NoteMeta(icon: Icons.schedule_rounded, text: DateFormat('HH:mm').format(start)),
                    if (noteData.isAlarmaCreated == true) const _NoteMeta(icon: Icons.notifications_active_outlined, text: 'Recordatorio'),
                  ]),
                ])),
                SizedBox(width: 3.w),
                Icon(Icons.chevron_right_rounded, color: text.withOpacity(.42)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        title: const Text('Eliminar nota'),
        content: const Text('La nota se eliminará permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final id = noteData.id;
    if (id == null) {
      Toast.toast(context, msg: 'No se puede eliminar una nota sin ID.');
      return;
    }
    await ref.read(notasListProvider.notifier).eliminarNota(id);
    if (!context.mounted) return;
    if (routeToNotas) context.go('/notas');
    Toast.toast(context, msg: 'Nota eliminada');
  }
}

class _NoteMeta extends StatelessWidget {
  const _NoteMeta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(.58);
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13.sp, color: color), SizedBox(width: 4.w), Text(text, style: TextStyle(fontSize: 11.sp, color: color))]);
  }
}
