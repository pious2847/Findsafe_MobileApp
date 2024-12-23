import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmService {
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AudioPlayer _player;
  int _playCount = 0;

  AlarmService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }
   void _lockDevice(String message) async {
    // Implement device locking logic here
    // This might involve using platform-specific code
    // For example, on Android:
    const platform = MethodChannel('com.example.app/device_admin');
    try {
      await platform.invokeMethod('lockDevice', {'message': message});
    } on PlatformException catch (e) {
      print("Failed to lock device: '${e.message}'.");
    }
  }
  void playAlarm() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: false,
      enableVibration: true,
    );
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      0,
      'FindSafe Alert',
      'An alarm has been triggered on your device for easy tracking',
      platformChannelSpecifics,
      payload: 'alarm',
    );
  _player = AudioPlayer();
  _playCount = 0;

    playAudioThreeTimes();
  }

  void playAudioThreeTimes() async {
    if (_playCount < 3) {
      try {
        print('Playing audio. Count: $_playCount');
        await _player.setSource(AssetSource('audio/alarm.mp3'));
        await _player.resume();
        _playCount++;

        // Wait for the audio to finish before playing again
        _player.onPlayerComplete.listen((_) {
          print('Audio completed. Play count: $_playCount');
          if (_playCount < 3) {
            playAudioThreeTimes();
          } else {
            print('Finished playing 3 times. Stopping.');
            _player.stop();
            _player.dispose();
          }
        });
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }

  Future<void> showLostModeNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'lost_mode_channel',
      'Lost Mode',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    // const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'FindSafe Security Alert',
      'Your device has been placed in Lost Mode for safety',
      platformChannelSpecifics,
      payload: 'lost_mode_notification',
    );
  }
}
