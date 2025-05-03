import 'package:findsafe/service/location.dart';
import 'package:findsafe/service/websocket.dart';
import 'package:findsafe/utilities/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

final locationservice = LocationApiService();

// A simple timer-based background service
class BackgroundService {
  static Timer? _timer;
  static const Duration _interval = Duration(minutes: 15);
  
  // Start the background service
  static void start() {
    if (_timer != null) {
      _timer!.cancel();
    }
    
    // Run immediately once
    updateLocationTask();
    
    // Then schedule periodic updates
    _timer = Timer.periodic(_interval, (timer) {
      updateLocationTask();
    });
    
    print('Background service started');
  }
  
  // Stop the background service
  static void stop() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      print('Background service stopped');
    }
  }
}

Future<void> initializeBackgroundService() async {
  late LocationPermission permission;

  permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    // Start the background service
    BackgroundService.start();
  } else {
    // Handle the case when location permissions are not granted
    print('Location permissions are not granted');
  }

  // Initialize notifications
  await NotificationService().initializeNotifications();
}

Future<void> connectWebSocket() async {
  WebSocketService webSocketService = WebSocketService();
  await webSocketService.connect();
}

Future<void> updateLocationTask() async {
  try {
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    print(
        'Current Location: ${currentPosition.latitude}, ${currentPosition.longitude}');

    final deviceData = await SharedPreferences.getInstance();
    final deviceId = deviceData.getString('deviceId');

    if (deviceId != null) {
      await locationservice.updateLocation(deviceId, currentPosition);
      
      // Attempt WebSocket reconnection
      final webSocketService = WebSocketService();
      await webSocketService.connect();
      
      print('Location updated successfully');
    } else {
      print('Device ID not found in SharedPreferences');
    }
  } catch (e) {
    print('Error updating location: $e');
  }
}
