import 'package:findsafe/service/location.dart';
import 'package:findsafe/service/websocket.dart';
import 'package:findsafe/utilities/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_background/flutter_background.dart';

final locationservice = LocationApiService();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'updateLocation') {
        print('Background task started: $task');

        // Re-initialize services
        final geolocator = Geolocator();
        await updateLocationTask(geolocator);

        // Attempt WebSocket reconnection
        final webSocketService = WebSocketService();
        await webSocketService.connect();

        print('Background task completed: $task');
      }
    } catch (e) {
      print('Error in background task: $e');
    }
    return Future.value(true);
  });
}

Future<void> initializeBackgroundService() async {
  late LocationPermission permission;

  permission = await Geolocator.requestPermission();

  // Initialize background execution
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Device Tracking Enabled",
    notificationText: "Lost Mode is active. We’re tracking your device’s location.",
    notificationImportance: AndroidNotificationImportance.high,
  );

  bool hasPermissions =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  if (hasPermissions) {
    await FlutterBackground.enableBackgroundExecution();
  }

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    // Initialize the WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register the periodic task
    await Workmanager().registerPeriodicTask(
      'updateLocation',
      'updateLocation',
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(seconds: 10),
    );
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

Future<void> updateLocationTask(Geolocator geolocator) async {
  try {
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    print(
        'Current Location: ${currentPosition.latitude}, ${currentPosition.longitude}');

    final deviceData = await SharedPreferences.getInstance();
    final deviceId = deviceData.getString('deviceId');

    // await updateLocation(deviceId!, currentPosition);
    if (deviceId != null) {
      await locationservice.updateLocation(deviceId, currentPosition);
    } else {
      print('Device ID not found in SharedPreferences');
    }
  } catch (e) {
    print('Error updating location: $e');
  }
}
