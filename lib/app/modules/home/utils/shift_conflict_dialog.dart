import 'package:flutter/material.dart';

import '../../../components/ad_banner_slot.dart';

import '../../../data/model/cuadranteDay.dart';
import 'shift_time_utils.dart';

Future<bool> confirmShiftConflicts(
  BuildContext context, {
  required CuadranteDay candidate,
  required Iterable<CuadranteDay> existing,
  int? ignoreId,
}) async {
  final date = candidate.dateTime;
  if (date == null) return false;
  final start = DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(const Duration(days: 1));
  final end = DateTime(
    date.year,
    date.month,
    date.day,
  ).add(const Duration(days: 1));
  final nearby = existing.where((item) {
    if (ignoreId != null && item.id == ignoreId) return false;
    final itemDate = item.dateTime;
    if (itemDate == null) return false;
    final normalized = DateTime(itemDate.year, itemDate.month, itemDate.day);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }).toList();
  final conflicts = ShiftTimeUtils.findOverlaps([...nearby, candidate]);
  final relevant = conflicts
      .where(
        (pair) =>
            pair.first.id == candidate.id ||
            pair.second.id == candidate.id ||
            identical(pair.first, candidate) ||
            identical(pair.second, candidate),
      )
      .toList();
  if (relevant.isEmpty) return true;

  final labels = relevant
      .map((pair) {
        final other =
            identical(pair.first, candidate) || pair.first.id == candidate.id
            ? pair.second
            : pair.first;
        final name = other.description?.trim().isNotEmpty == true
            ? other.description!.trim()
            : (other.title ?? 'Turno');
        return '• $name (${other.startHour ?? '--:--'}–${other.endHour ?? '--:--'})';
      })
      .toSet()
      .join('\n');

  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Posible solapamiento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Este turno coincide en horario con otro turno:\n\n$labels\n\n¿Quieres guardarlo de todas formas?',
              ),
              const AdBannerSlot(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Guardar igualmente'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> confirmShiftBatchConflicts(
  BuildContext context, {
  required List<CuadranteDay> candidates,
  required Iterable<CuadranteDay> existing,
}) async {
  if (candidates.isEmpty) return false;
  final candidateSet = Set<CuadranteDay>.identity()..addAll(candidates);
  final conflicts = ShiftTimeUtils.findOverlaps([...existing, ...candidates])
      .where(
        (pair) =>
            candidateSet.contains(pair.first) ||
            candidateSet.contains(pair.second),
      )
      .toList();
  if (conflicts.isEmpty) return true;

  final descriptions = conflicts
      .map((pair) {
        final candidate = candidateSet.contains(pair.first)
            ? pair.first
            : pair.second;
        final other = identical(candidate, pair.first)
            ? pair.second
            : pair.first;
        final name = other.description?.trim().isNotEmpty == true
            ? other.description!.trim()
            : (other.title ?? 'Turno');
        return '• ${candidate.dateTime?.day ?? ''}/${candidate.dateTime?.month ?? ''}: $name (${other.startHour ?? '--:--'}–${other.endHour ?? '--:--'})';
      })
      .toSet()
      .take(8)
      .join('\n');

  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Hay turnos que se solapan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Al repetir este turno se producirán estos solapamientos:\n\n$descriptions\n\n¿Quieres crear igualmente las repeticiones?',
              ),
              const AdBannerSlot(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Repetir igualmente'),
            ),
          ],
        ),
      ) ??
      false;
}
