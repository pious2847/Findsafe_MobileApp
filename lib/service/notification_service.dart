import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _logger = AppLogger.getLogger('NotificationService');

  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel definitions
  static const String _alertChannelId = 'findsafe_alerts';
  static const String _alertChannelName = 'FindSafe Alerts';
  static const String _alertChannelDesc =
      'Important alerts like geofence breaches and security events';

  Future<void> initialize() async {
    _logger.info('Initializing notification service');

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _requestPermissions();
      _logger.info('Notification service initialized');
    } catch (e, stackTrace) {
      _logger.severe('Error initializing notification service', e, stackTrace);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error requesting notification permissions', e, stackTrace);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
    if (response.payload == null) return;

    final payload = response.payload!;

    try {
      if (payload.startsWith('geofence:')) {
        Get.to(() => const CustomBottomNav(initialIndex: 0));
      } else if (payload.startsWith('device:')) {
        Get.to(() => const CustomBottomNav(initialIndex: 1));
      } else if (payload == 'alarm') {
        Get.to(() => const CustomBottomNav(initialIndex: 0));
      } else if (payload == 'lock_notification' ||
          payload == 'wipe_notification' ||
          payload == 'security') {
        Get.to(() => const CustomBottomNav(initialIndex: 3));
      }
    } catch (e, stackTrace) {
      _logger.severe('Error handling notification tap', e, stackTrace);
    }
  }

  /// Show a user-facing alert notification (high priority, with sound)
  Future<void> showNotification({
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

      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e, stackTrace) {
      _logger.severe('Error showing notification', e, stackTrace);
    }
  }

  Future<void> showGeofenceNotification({
    required GeofenceModel geofence,
    required bool isEntry,
    required String deviceName,
  }) async {
    final eventType = isEntry ? 'entered' : 'exited';
    final title = '$deviceName $eventType geofence';
    final body = geofence.name +
        (geofence.description != null ? ': ${geofence.description}' : '');

    await showNotification(
      id: geofence.id.hashCode,
      title: title,
      body: body,
      payload: 'geofence:${geofence.id}',
    );
  }

  Future<void> showDeviceStatusNotification({
    required String deviceId,
    required String deviceName,
    required String status,
    String? details,
  }) async {
    await showNotification(
      id: deviceId.hashCode,
      title: '$deviceName status changed',
      body: '$status${details != null ? ': $details' : ''}',
      payload: 'device:$deviceId',
    );
  }

  Future<void> showLowBatteryNotification({
    required String deviceId,
    required String deviceName,
    required int batteryLevel,
  }) async {
    await showNotification(
      id: 'device:$deviceId:battery'.hashCode,
      title: 'Low Battery Alert',
      body: '$deviceName battery is at $batteryLevel%',
      payload: 'device:$deviceId',
    );
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling notification', e, stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling all notifications', e, stackTrace);
    }
  }
}
