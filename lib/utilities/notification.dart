import 'package:findsafe/utilities/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _logger = AppLogger.getLogger('NotificationService');

  Future<void> initializeNotifications() async {
    _logger.info('Initializing notification service');

    try {
      // Android initialization settings
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize settings for both platforms
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _logger.info('Notification service initialized successfully');

      // Request permissions
      await _requestPermissions();
    } catch (e, stackTrace) {
      _logger.severe('Error initializing notification service', e, stackTrace);
    }
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
    // Handle notification tap based on payload
    // This would typically navigate to a specific screen
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      _logger.info('Requesting notification permissions');

      // Request iOS permissions
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Request Android permissions
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _logger.info('Notification permissions requested');
    } catch (e, stackTrace) {
      _logger.severe(
          'Error requesting notification permissions', e, stackTrace);
    }
  }

  // Show a notification
  Future<void> show(
    int id,
    String title,
    String body,
    NotificationDetails platformChannelSpecifics, {
    required String payload,
  }) async {
    _logger
        .info('Showing notification: ID=$id, Title=$title, Payload=$payload');

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      _logger.info('Notification shown successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error showing notification', e, stackTrace);
    }
  }

  // Show a basic notification
  Future<void> showBasicNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    _logger.info('Showing basic notification: ID=$id, Title=$title');

    try {
      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'findsafe_channel',
        'FindSafe Notifications',
        channelDescription: 'Notifications from FindSafe app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combine platform-specific details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Show the notification
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      _logger.info('Basic notification shown successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error showing basic notification', e, stackTrace);
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    _logger.info('Cancelling notification with ID: $id');

    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      _logger.info('Notification cancelled successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling notification', e, stackTrace);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    _logger.info('Cancelling all notifications');

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      _logger.info('All notifications cancelled successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling all notifications', e, stackTrace);
    }
  }
}
