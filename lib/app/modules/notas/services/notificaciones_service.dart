import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio único para todos los recordatorios locales de Calendario.
class NotificacionesService {
  NotificacionesService._();

  static final NotificacionesService instance = NotificacionesService._();

  static const String _channelId = 'calendario_recordatorios_v2';
  static const String _channelName = 'Recordatorios de Calendario';
  static const String _channelDescription =
      'Avisos de notas y turnos programados en Calendario';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;
  bool _zonasHorariasInicializadas = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    tz.initializeTimeZones();
    _zonasHorariasInicializadas = true;

    if (kIsWeb) {
      _inicializado = true;
      return;
    }

    const android = AndroidInitializationSettings('ic_stat_notification');
    final iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(
        android: android,
        iOS: iOS,
      ),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      if (await androidPlugin.areNotificationsEnabled() == false) {
        await androidPlugin.requestNotificationsPermission();
      }
    }

    final iOSPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iOSPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _inicializado = true;
  }

  Future<void> inicializarZonasHorarias() async {
    if (_zonasHorariasInicializadas) return;
    tz.initializeTimeZones();
    _zonasHorariasInicializadas = true;
  }

  Future<AndroidScheduleMode> _obtenerModoProgramacionAndroid() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return AndroidScheduleMode.exactAllowWhileIdle;

    if (await android.areNotificationsEnabled() == false) {
      await android.requestNotificationsPermission();
    }

    if (await android.areNotificationsEnabled() == false) {
      throw StateError('Las notificaciones de Android están desactivadas.');
    }

    if (await android.canScheduleExactNotifications() == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    // Android puede abrir Ajustes para conceder alarmas exactas. Si el
    // usuario no las concede, seguimos con una alarma inexacta para no
    // perder el recordatorio.
    await android.requestExactAlarmsPermission();

    if (await android.canScheduleExactNotifications() == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _detalles() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        icon: 'ic_stat_notification',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );
  }

  Future<bool> programar({
    required int id,
    required String titulo,
    required String mensaje,
    required DateTime fechaRecordatorio,
  }) async {
    if (kIsWeb) return false;

    await inicializar();
    await inicializarZonasHorarias();

    if (!fechaRecordatorio.isAfter(DateTime.now())) {
      await cancelar(id);
      return false;
    }

    final fechaZonaHoraria = tz.TZDateTime.from(
      fechaRecordatorio,
      tz.local,
    );

    final modo = await _obtenerModoProgramacionAndroid();

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: titulo,
        body: mensaje.isEmpty ? 'Tienes un recordatorio pendiente.' : mensaje,
        scheduledDate: fechaZonaHoraria,
        notificationDetails: _detalles(),
        androidScheduleMode: modo,
        payload: 'calendario:$id',
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('[NOTIFICACIONES] Error programando $id: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> programarTurno({
    required int id,
    required String titulo,
    required DateTime inicioTurno,
    required int minutosAntes,
  }) async {
    final fecha = inicioTurno.subtract(Duration(minutes: minutosAntes));
    return programar(
      id: id,
      titulo: 'Turno: $titulo',
      mensaje: minutosAntes == 0
          ? 'Comienza tu turno.'
          : 'Tu turno comienza en $minutosAntes minutos.',
      fechaRecordatorio: fecha,
    );
  }

  Future<void> cancelar(int id) async {
    if (kIsWeb) return;
    await inicializar();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelarTodas() async {
    if (kIsWeb) return;
    await inicializar();
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pendientes() async {
    if (kIsWeb) return const <PendingNotificationRequest>[];
    await inicializar();
    return _plugin.pendingNotificationRequests();
  }
}
