import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Centraliza la programación y cancelación de recordatorios de notas.
/// No depende de GetX ni de Riverpod.
class NotificacionesService {
  NotificacionesService._();

  static final NotificacionesService instance = NotificacionesService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _zonasHorariasInicializadas = false;

  Future<void> inicializarZonasHorarias() async {
    if (_zonasHorariasInicializadas) return;
    tz.initializeTimeZones();
    _zonasHorariasInicializadas = true;
  }

  /// Programa o sustituye el recordatorio asociado a [id].
  ///
  /// Si [fechaRecordatorio] ya ha pasado, cancela el recordatorio anterior
  /// con ese mismo ID y devuelve false.
  Future<bool> programar({
    required int id,
    required String titulo,
    required String mensaje,
    required DateTime fechaRecordatorio,
  }) async {
    await inicializarZonasHorarias();

    if (!fechaRecordatorio.isAfter(DateTime.now())) {
      await cancelar(id);
      return false;
    }

    final fechaZonaHoraria =
        tz.TZDateTime.from(fechaRecordatorio, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: titulo,
      body: mensaje,
      scheduledDate: fechaZonaHoraria,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    return true;
  }

  Future<void> cancelar(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<List<PendingNotificationRequest>> pendientes() {
    return _plugin.pendingNotificationRequests();
  }
}
