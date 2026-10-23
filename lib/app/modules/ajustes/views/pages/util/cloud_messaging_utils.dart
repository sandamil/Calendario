import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications/notifications.dart';

class CloudMessagingUtils {
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackGroundMessage);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((event) => _onMessage(event));
  }

  static Future<String?> getInstallationId() async {
    final messaging = FirebaseMessaging.instance;
    final installationId = Completer<String?>();
    final subscription = messaging.onRegistered.listen(
      (id) {
        if (!installationId.isCompleted) installationId.complete(id);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!installationId.isCompleted) installationId.completeError(error, stackTrace);
      },
    );

    try {
      await messaging.register();
      return await installationId.future.timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    } finally {
      await subscription.cancel();
    }
  }

  static Future<void> _onBackGroundMessage(RemoteMessage message) {
    ReceivedNotification receivedNotification = ReceivedNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      payload: json.encode({
        "type": "cloud_message_background",
        "id": Notifications.instance.notificationId,
        "data": message.data,
      }),
    );
    return Notifications.instance.showNotification(receivedNotification);
  }

  static Future<void> _onMessage(RemoteMessage message) {
    ReceivedNotification receivedNotification = ReceivedNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      payload: json.encode({
        "type": "cloud_message",
        "id": Notifications.instance.notificationId,
        "data": message.data,
      }),
    );
    return Notifications.instance.showNotification(receivedNotification);
  }
}
