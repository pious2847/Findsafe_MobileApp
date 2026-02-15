import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _logger = AppLogger.getLogger('NotificationService');

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    _logger.info('Initializing notification service');

    try {
      // Initialize timezone
      _logger.info('Initializing timezones');
      tz.initializeTimeZones();

      // Initialize notification settings
      _logger.info('Setting up notification settings');
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _logger.info('Notification plugin initialized');

      // Request permissions
      await _requestPermissions();
      _logger.info('Notification service initialization complete');
    } catch (e, stackTrace) {
      _logger.severe('Error initializing notification service', e, stackTrace);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      _logger.info('Requesting iOS notification permissions');
      // Request permissions for iOS
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      _logger.info('iOS notification permissions requested');

      _logger.info('Requesting Android notification permissions');
      // Request permissions for Android
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _logger.info('Android notification permissions requested');
    } catch (e, stackTrace) {
      _logger.severe(
          'Error requesting notification permissions', e, stackTrace);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    _logger.info('Notification tapped: ${response.payload}');

    if (response.payload == null) {
      _logger.warning('Notification payload is null');
      return;
    }

    final String payload = response.payload!;
    _logger.info('Processing notification payload: $payload');

    try {
      // Navigate based on payload type
      if (payload.startsWith('geofence:')) {
        // Extract geofence ID from payload
        final String geofenceId = payload.substring('geofence:'.length);
        _logger
            .info('Geofence notification tapped for geofence ID: $geofenceId');

        // Navigate to geofence screen
        _logger.info('Navigating to geofence screen');
        Get.to(() => const CustomBottomNav(initialIndex: 0));

        // TODO: Navigate to specific geofence details if needed
        // Get.to(() => GeofenceDetailsScreen(geofenceId: geofenceId));
      } else if (payload.startsWith('device:')) {
        // Extract device ID from payload
        final String deviceId = payload.substring('device:'.length);
        _logger.info('Device notification tapped for device ID: $deviceId');

        // Navigate to location screen
        _logger.info('Navigating to location screen');
        Get.to(() => const CustomBottomNav(initialIndex: 1));

        // TODO: Select the specific device if needed
      } else if (payload == 'alarm') {
        _logger.info('Alarm notification tapped');
        // Navigate to home screen
        _logger.info('Navigating to home screen');
        Get.to(() => const CustomBottomNav(initialIndex: 0));
      } else if (payload == 'lock_notification' ||
          payload == 'wipe_notification') {
        _logger.info('Security notification tapped: $payload');
        // Navigate to security screen
        _logger.info('Navigating to security screen');
        Get.to(() => const CustomBottomNav(initialIndex: 3));
      } else if (payload == 'security') {
        _logger.info('Security notification tapped');
        // Navigate to security screen
        _logger.info('Navigating to security screen');
        Get.to(() => const CustomBottomNav(initialIndex: 3));
      } else {
        _logger.warning('Unknown notification payload type: $payload');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error handling notification tap', e, stackTrace);
    }
  }

  // Show a basic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    _logger
        .info('Showing notification: ID=$id, Title=$title, Payload=$payload');

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'findsafe_channel',
        'FindSafe Notifications',
        channelDescription: 'Notifications from FindSafe app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
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

  // Show a geofence notification
  Future<void> showGeofenceNotification({
    required GeofenceModel geofence,
    required bool isEntry,
    required String deviceName,
  }) async {
    _logger.info(
        'Showing geofence notification: Geofence=${geofence.name}, Device=$deviceName, Event=${isEntry ? 'entry' : 'exit'}');

    final String eventType = isEntry ? 'entered' : 'exited';
    final String title = '$deviceName $eventType geofence';
    final String body = '${geofence.name}: ${geofence.description ?? ''}';

    await showNotification(
      id: geofence.id.hashCode,
      title: title,
      body: body,
      payload: 'geofence:${geofence.id}',
    );
  }

  // Show a device status notification
  Future<void> showDeviceStatusNotification({
    required String deviceId,
    required String deviceName,
    required String status,
    String? details,
  }) async {
    _logger.info(
        'Showing device status notification: Device=$deviceName, Status=$status, Details=$details');

    final String title = '$deviceName status changed';
    final String body = '$status${details != null ? ': $details' : ''}';

    await showNotification(
      id: deviceId.hashCode,
      title: title,
      body: body,
      payload: 'device:$deviceId',
    );
  }

  // Show a low battery notification
  Future<void> showLowBatteryNotification({
    required String deviceId,
    required String deviceName,
    required int batteryLevel,
  }) async {
    _logger.info(
        'Showing low battery notification for device: $deviceId, battery level: $batteryLevel%');

    const String title = 'Low Battery Alert';
    final String body = '$deviceName battery is at $batteryLevel%';

    await showNotification(
      id: 'device:$deviceId:battery'.hashCode,
      title: title,
      body: body,
      payload: 'device:$deviceId',
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    _logger.info(
        'Scheduling notification: ID=$id, Title=$title, Date=${scheduledDate.toIso8601String()}, Payload=$payload');

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'findsafe_scheduled_channel',
        'FindSafe Scheduled Notifications',
        channelDescription: 'Scheduled notifications from FindSafe app',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      _logger.info('Notification scheduled successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error scheduling notification', e, stackTrace);
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    _logger.info('Cancelling notification with ID: $id');

    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      _logger.info('Notification cancelled successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling notification', e, stackTrace);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    _logger.info('Cancelling all notifications');

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      _logger.info('All notifications cancelled successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling all notifications', e, stackTrace);
    }
  }
}
