import 'package:workmanager/workmanager.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/services/location_permission_service.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

// Background task dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('[BackgroundLocationService] Background task started: $task');

    try {
      // Initialize services for background execution
      final locationService = LocationApiService();
      final notificationService = NotificationService();

      // Initialize notifications
      await notificationService.initializeNotifications();

      print('[BackgroundLocationService] Checking location permissions...');

      // Check location permissions - only check, don't request in background
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        print(
            '[BackgroundLocationService] Insufficient location permission: $permission');
        return Future.value(false);
      }

      print('[BackgroundLocationService] Getting current position...');

      // Get current position
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException(
              'Location request timed out', const Duration(seconds: 45));
        },
      );

      print(
          '[BackgroundLocationService] Location obtained: ${currentPosition.latitude}, ${currentPosition.longitude}');

      // Get device ID
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId');

      if (deviceId == null) {
        print('[BackgroundLocationService] Device ID not found');
        return Future.value(false);
      }

      // Update location on server
      await locationService.updateLocation(deviceId, currentPosition);
      print(
          '[BackgroundLocationService] Location updated successfully for device: $deviceId');

      // Show success notification
      await notificationService.showBasicNotification(
        id: 996,
        title: 'Location Updated',
        body:
            'Device location updated at ${DateTime.now().toString().substring(11, 19)}',
        payload: 'location_success',
      );

      print(
          '[BackgroundLocationService] Background location update completed successfully');
      return Future.value(true);
    } catch (e, stackTrace) {
      print('[BackgroundLocationService] Error in background task: $e');
      print('[BackgroundLocationService] Stack trace: $stackTrace');
      return Future.value(false);
    }
  });
}

class BackgroundLocationService {
  static final _logger = AppLogger.getLogger('BackgroundLocationService');
  static final _locationService = LocationApiService();
  static final _notificationService = NotificationService();
  static bool _isInitialized = false;
  static const String _taskName = 'locationUpdateTask';

  // Initialize the workmanager service
  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.info('Background location service already initialized');
      return;
    }

    try {
      _logger.info('Initializing background location service');

      // Check location permissions first
      final permission = await _checkLocationPermissions();
      if (!permission) {
        _logger.warning(
            'Location permissions not granted, cannot initialize background service');
        return;
      }

      // Initialize notifications
      await _notificationService.initializeNotifications();

      // Initialize workmanager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true,
      );

      _isInitialized = true;
      _logger.info('Background location service initialized successfully');

      // Start the background task
      await start();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error initializing background location service', e, stackTrace);
    }
  }

  // Start background location tracking
  static Future<void> start() async {
    try {
      _logger.info('Starting background location tracking');

      // Cancel any existing tasks first
      await Workmanager().cancelByUniqueName(_taskName);

      // Register periodic task for location updates
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      _logger.info(
          'Background location tracking started with 15-minute intervals');

      // Show notification that service is active
      await _notificationService.showBasicNotification(
        id: 999,
        title: 'FindSafe Location Tracking',
        body: 'Your device location is being tracked every 15 minutes',
        payload: 'background_location',
      );
    } catch (e, stackTrace) {
      _logger.severe(
          'Error starting background location tracking', e, stackTrace);
    }
  }

  // Stop background location tracking
  static Future<void> stop() async {
    try {
      _logger.info('Stopping background location tracking');
      await Workmanager().cancelByUniqueName(_taskName);
      _logger.info('Background location tracking stopped');
    } catch (e, stackTrace) {
      _logger.severe(
          'Error stopping background location tracking', e, stackTrace);
    }
  }

  // Restart background location tracking
  static Future<void> restart() async {
    try {
      _logger.info('Restarting background location tracking');
      await stop();
      await Future.delayed(const Duration(seconds: 2));
      await start();
      _logger.info('Background location tracking restarted');
    } catch (e, stackTrace) {
      _logger.severe(
          'Error restarting background location tracking', e, stackTrace);
    }
  }

  // Check location permissions
  static Future<bool> _checkLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.warning('Location permission permanently denied');

        await _notificationService.showBasicNotification(
          id: 998,
          title: 'Location Access Required',
          body:
              'FindSafe needs location access to protect your device. Please enable in settings.',
          payload: 'location_permission',
        );

        return false;
      }

      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      _logger.info(
          'Location permission status: $permission, hasPermission: $hasPermission');
      return hasPermission;
    } catch (e, stackTrace) {
      _logger.severe('Error checking location permissions', e, stackTrace);
      return false;
    }
  }

  // Manual location update for testing
  static Future<void> updateLocationNow() async {
    _logger.info('Manual location update requested');

    try {
      // Check network connectivity
      final hasNetwork = await _checkNetworkConnectivity();
      if (!hasNetwork) {
        _logger.warning('No network connectivity, skipping location update');
        return;
      }

      // Check location permissions
      final hasPermission = await _checkLocationPermissions();
      if (!hasPermission) {
        _logger.warning('No location permission, skipping location update');
        return;
      }

      // Get current position with timeout
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException(
              'Location request timed out', const Duration(seconds: 45));
        },
      );

      _logger.info(
          'Current location obtained: ${currentPosition.latitude}, ${currentPosition.longitude}');

      // Get device ID
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId');

      if (deviceId == null) {
        _logger.warning('Device ID not found, cannot update location');
        return;
      }

      // Update location on server
      await _locationService.updateLocation(deviceId, currentPosition);
      _logger.info('Location updated successfully for device: $deviceId');

      // Show success notification
      await _notificationService.showBasicNotification(
        id: 995,
        title: 'Manual Location Update',
        body:
            'Location updated manually at ${DateTime.now().toString().substring(11, 19)}',
        payload: 'manual_location_success',
      );

      // Log successful update
      final timestamp = DateTime.now().toIso8601String();
      _logger.info('Manual location update completed at $timestamp');
    } catch (e, stackTrace) {
      _logger.severe('Error in manual location update', e, stackTrace);

      // Show error notification
      await _notificationService.showBasicNotification(
        id: 994,
        title: 'Location Update Failed',
        body: 'Manual location update failed: ${e.toString()}',
        payload: 'manual_location_error',
      );
    }
  }

  // Check network connectivity
  static Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      _logger.warning('No network connectivity');
      return false;
    } catch (e) {
      _logger.warning('Error checking network connectivity: $e');
      return false;
    }
  }

  // Get current status
  static Future<bool> getStatus() async {
    try {
      return _isInitialized;
    } catch (e) {
      _logger.warning('Error getting background service status: $e');
      return false;
    }
  }

  // Check if service is running
  static bool get isInitialized => _isInitialized;

  // Get permission status for UI
  static Future<String> getPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();
      switch (permission) {
        case LocationPermission.always:
          return 'Always (Background tracking enabled)';
        case LocationPermission.whileInUse:
          return 'While using app (Background tracking limited)';
        case LocationPermission.denied:
          return 'Denied';
        case LocationPermission.deniedForever:
          return 'Permanently denied';
        case LocationPermission.unableToDetermine:
          return 'Unable to determine';
      }
    } catch (e) {
      return 'Error checking permission';
    }
  }

  // Check if background tracking is possible
  static Future<bool> canTrackInBackground() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    } catch (e) {
      _logger.severe('Error checking background location permission', e);
      return false;
    }
  }

  // Check if we have any location permission
  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      _logger.severe('Error checking location permission', e);
      return false;
    }
  }
}
