import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AudioPlayer _player;
  int _playCount = 0;
  final _logger = AppLogger.getLogger('AlarmService');

  AlarmService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    _logger.info('Initializing notifications');

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

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _logger.info('Notification tapped: ${response.payload}');
        },
      );

      _logger.info('Notifications initialized successfully');

      // Request permissions
      await _requestNotificationPermissions();
    } catch (e, stackTrace) {
      _logger.severe('Error initializing notifications', e, stackTrace);
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
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

  // Platform channel for device admin features
  static const platform = MethodChannel('com.example.findsafe/device_admin');

  // Check if device admin is active
  Future<bool> isDeviceAdminActive() async {
    try {
      _logger.info('Checking if device admin is active');
      final bool isActive = await platform.invokeMethod('isDeviceAdminActive');
      _logger.info('Device admin active: $isActive');
      return isActive;
    } on PlatformException catch (e) {
      _logger.severe('Failed to check device admin status', e);
      return false;
    }
  }

  // Request device admin privileges
  Future<void> requestDeviceAdmin() async {
    try {
      _logger.info('Requesting device admin privileges');
      await platform.invokeMethod('requestDeviceAdmin');
      _logger.info('Device admin request sent');
    } on PlatformException catch (e) {
      _logger.severe('Failed to request device admin', e);
    }
  }

  // Lock the device remotely
  Future<bool> lockDevice() async {
    _logger.info('Locking device remotely');

    // Show a notification that the device is being locked
    await showLockNotification();

    try {
      // Check if device admin is active
      final bool isActive = await isDeviceAdminActive();
      if (!isActive) {
        _logger.warning('Device admin not active, requesting privileges');
        await requestDeviceAdmin();
        return false;
      }

      // Invoke platform method to lock device
      _logger.info('Invoking platform method to lock device');
      final bool success = await platform.invokeMethod('lockDevice',
          {'message': 'This device has been locked remotely by FindSafe'});

      if (success) {
        _logger.info('Device locked successfully');
      } else {
        _logger.warning('Device lock command failed');
      }

      return success;
    } on PlatformException catch (e) {
      _logger.severe('Failed to lock device', e);
      // Fallback to showing a notification if we can't lock the device
      await showLockNotification();
      return false;
    }
  }

  // Wipe device data remotely
  Future<bool> wipeData() async {
    _logger.info('Wiping device data remotely');

    // Show a notification that the device is being wiped
    await showWipeNotification();

    try {
      // Check if device admin is active
      final bool isActive = await isDeviceAdminActive();
      if (!isActive) {
        _logger.warning('Device admin not active, requesting privileges');
        await requestDeviceAdmin();
        return false;
      }

      // Invoke platform method to wipe data
      _logger.info('Invoking platform method to wipe device data');
      final bool success = await platform.invokeMethod('wipeData',
          {'message': 'This device is being wiped remotely by FindSafe'});

      if (success) {
        _logger.info('Device data wipe initiated successfully');
      } else {
        _logger.warning('Device wipe command failed');
      }

      return success;
    } on PlatformException catch (e) {
      _logger.severe('Failed to wipe device data', e);
      // Fallback to showing a notification if we can't wipe the device
      await showWipeNotification();
      return false;
    }
  }

  Future<void> playAlarm() async {
    _logger.info('Playing alarm sound');

    // Android notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: false,
      enableVibration: true,
    );

    // iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false, // We'll play our own sound
      interruptionLevel: InterruptionLevel.critical,
    );

    // Combined platform details
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      // Show notification
      _logger.info('Showing alarm notification');
      await flutterLocalNotificationsPlugin.show(
        0,
        'FindSafe Alert',
        'An alarm has been triggered on your device for easy tracking',
        platformChannelSpecifics,
        payload: 'alarm',
      );

      // Initialize audio player
      _player = AudioPlayer();
      _playCount = 0;

      // Play alarm sound
      await playAudioThreeTimes();
    } catch (e, stackTrace) {
      _logger.severe('Error showing alarm notification', e, stackTrace);
    }
  }

  Future<void> playAudioThreeTimes() async {
    if (_playCount < 3) {
      try {
        _logger.info('Playing audio. Count: $_playCount');

        // Create a completer to wait for audio completion
        final completer = Completer<void>();

        // Set up completion listener
        final subscription = _player.onPlayerComplete.listen((_) {
          _logger.info('Audio completed. Play count: $_playCount');
          completer.complete();
        });

        // Set source and play
        await _player.setSource(AssetSource('audio/alarm.mp3'));
        await _player.resume();
        _playCount++;

        // Wait for audio to complete
        await completer.future;

        // Clean up subscription
        subscription.cancel();

        // Play again if needed
        if (_playCount < 3) {
          await playAudioThreeTimes();
        } else {
          _logger.info('Finished playing 3 times. Stopping.');
          await _player.stop();
          await _player.dispose();
        }
      } catch (e, stackTrace) {
        _logger.severe('Error playing audio', e, stackTrace);

        // Clean up on error
        try {
          await _player.stop();
          await _player.dispose();
        } catch (disposeError) {
          _logger.warning('Error disposing audio player: $disposeError');
        }
      }
    }
  }

  Future<void> showLostModeNotification() async {
    _logger.info('Showing lost mode notification');

    // Android notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'lost_mode_channel',
      'Lost Mode',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    // Combined platform details
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'FindSafe Security Alert',
        'Your device has been placed in Lost Mode for safety',
        platformChannelSpecifics,
        payload: 'lost_mode_notification',
      );
      _logger.info('Lost mode notification shown successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error showing lost mode notification', e, stackTrace);
    }
  }

  Future<void> showLockNotification() async {
    _logger.info('Showing lock notification');

    // Android notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'lock_channel',
      'Lock Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    // Combined platform details
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        1,
        'FindSafe Security Alert',
        'This device has been locked remotely for security',
        platformChannelSpecifics,
        payload: 'lock_notification',
      );
      _logger.info('Lock notification shown successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error showing lock notification', e, stackTrace);
    }
  }

  Future<void> showWipeNotification() async {
    _logger.info('Showing wipe notification');

    // Android notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'wipe_channel',
      'Wipe Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Color.fromARGB(255, 255, 0, 0), // Red color for critical alert
    );

    // iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    // Combined platform details
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        2,
        'FindSafe Security Alert',
        'This device is being wiped remotely for security',
        platformChannelSpecifics,
        payload: 'wipe_notification',
      );
      _logger.info('Wipe notification shown successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error showing wipe notification', e, stackTrace);
    }
  }
}
