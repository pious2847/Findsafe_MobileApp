import 'package:findsafe/utilities/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _logger = AppLogger.getLogger('NotificationService');

  // Notification channel IDs
  static const String _alertChannelId = 'findsafe_alerts';
  static const String _alertChannelName = 'FindSafe Alerts';
  static const String _alertChannelDesc =
      'Important alerts like geofence breaches and security events';

  static const String _silentChannelId = 'findsafe_background';
  static const String _silentChannelName = 'Background Updates';
  static const String _silentChannelDesc = 'Silent background location updates';

  Future<void> initializeNotifications() async {
    _logger.info('Initializing notification service');

    try {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _logger.info('Notification service initialized');
      await _requestPermissions();
    } catch (e, stackTrace) {
      _logger.severe('Error initializing notification service', e, stackTrace);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
  }

  Future<void> _requestPermissions() async {
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error requesting notification permissions', e, stackTrace);
    }
  }

  /// Show a user-facing notification (alerts, geofence, security events).
  /// Uses high-priority channel with sound.
  Future<void> showBasicNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _alertChannelId,
        _alertChannelName,
        channelDescription: _alertChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error showing notification', e, stackTrace);
    }
  }

  /// Show a low-priority silent notification (background status updates).
  /// No sound, no vibration, minimal interruption.
  Future<void> showSilentNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _silentChannelId,
        _silentChannelName,
        channelDescription: _silentChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        showWhen: false,
        playSound: false,
        enableVibration: false,
        ongoing: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error showing silent notification', e, stackTrace);
    }
  }

  /// Show the raw notification with custom NotificationDetails.
  Future<void> show(
    int id,
    String title,
    String body,
    NotificationDetails platformChannelSpecifics, {
    required String payload,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error showing notification', e, stackTrace);
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling notification', e, stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling all notifications', e, stackTrace);
    }
  }
}
