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
  bool _solicitudPermisoExactoRealizada = false;

  Future<void> inicializarZonasHorarias() async {
    if (_zonasHorariasInicializadas) return;

    tz.initializeTimeZones();
    _zonasHorariasInicializadas = true;
  }

  /// Comprueba y solicita los permisos Android necesarios.
  ///
  /// Si el usuario no concede alarmas exactas, se utilizará una
  /// programación aproximada que también permite avisos en reposo.
  Future<AndroidScheduleMode> _obtenerModoProgramacionAndroid() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // En iOS y otras plataformas, el modo Android no se utiliza.
    if (android == null) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    // Android 13 o posterior puede requerir permiso para notificaciones.
    var notificacionesPermitidas = await android.areNotificationsEnabled();

    if (notificacionesPermitidas == false) {
      await android.requestNotificationsPermission();
      notificacionesPermitidas = await android.areNotificationsEnabled();
    }

    // No programar silenciosamente si las notificaciones están bloqueadas.
    if (notificacionesPermitidas == false) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    var alarmasExactasPermitidas =
        await android.canScheduleExactNotifications();

    // Solicitar acceso a alarmas exactas como máximo una vez por sesión.
    if (alarmasExactasPermitidas == false &&
        !_solicitudPermisoExactoRealizada) {
      _solicitudPermisoExactoRealizada = true;

      await android.requestExactAlarmsPermission();

      // Volver a consultar el permiso al regresar de Ajustes de Android.
      alarmasExactasPermitidas =
          await android.canScheduleExactNotifications();
    }

    if (alarmasExactasPermitidas == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    // Alternativa si el usuario no concede alarmas exactas.
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Programa o sustituye el recordatorio asociado a [id].
  ///
  /// Devuelve false si la fecha ya pasó o si Android tiene bloqueadas
  /// las notificaciones. Devuelve true cuando la programación termina.
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

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    var modoProgramacion = AndroidScheduleMode.exactAllowWhileIdle;

    if (android != null) {
      var notificacionesPermitidas = await android.areNotificationsEnabled();

      if (notificacionesPermitidas == false) {
        await android.requestNotificationsPermission();
        notificacionesPermitidas = await android.areNotificationsEnabled();
      }

      if (notificacionesPermitidas == false) {
        await cancelar(id);
        return false;
      }

      modoProgramacion = await _obtenerModoProgramacionAndroid();
    }

    await _plugin.zonedSchedule(
      id: id,
      title: titulo,
      body: mensaje,
      scheduledDate: fechaZonaHoraria,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'calendario_recordatorios',
          'Recordatorios de notas',
          channelDescription: 'Avisos programados para las notas del calendario',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: modoProgramacion,
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
