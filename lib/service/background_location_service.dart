import 'package:workmanager/workmanager.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

// Background task dispatcher — runs in an isolate, must be top-level
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final locationService = LocationApiService();

      // Check location permissions silently
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        // No permission — skip silently, don't spam the user
        return Future.value(true);
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
          throw TimeoutException('Location request timed out');
        },
      );

      // Get device ID
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId');

      if (deviceId == null) {
        // No device registered yet — not an error, just skip
        return Future.value(true);
      }

      // Update location on server
      await locationService.updateLocation(deviceId, currentPosition);

      // Store last successful update timestamp
      await prefs.setString(
        'lastLocationUpdate',
        DateTime.now().toIso8601String(),
      );

      // Always return true to prevent workmanager from showing failure notifications
      return Future.value(true);
    } catch (e) {
      // Return true even on failure to prevent workmanager debug notifications.
      // Failures are handled silently — the next periodic run will retry.
      return Future.value(true);
    }
  });
}

class BackgroundLocationService {
  static final _logger = AppLogger.getLogger('BackgroundLocationService');
  static final _locationService = LocationApiService();
  static final _notificationService = NotificationService();
  static bool _isInitialized = false;
  static const String _taskName = 'locationUpdateTask';
  static const Duration _updateInterval = Duration(minutes: 15);

  /// Initialize the workmanager service. Called once at app startup.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.info('Initializing background location service');

      final permission = await _checkLocationPermissions();
      if (!permission) {
        _logger.warning('Location permissions not granted, skipping init');
        return;
      }

      // Initialize notifications
      await _notificationService.initializeNotifications();

      // Initialize workmanager — debug mode OFF for production
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      _isInitialized = true;
      _logger.info('Background location service initialized');

      // Register the periodic task
      await _registerPeriodicTask();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error initializing background location service', e, stackTrace);
    }
  }

  /// Register the periodic background task. Idempotent — safe to call multiple times.
  static Future<void> _registerPeriodicTask() async {
    try {
      // Cancel existing task to avoid duplicates
      await Workmanager().cancelByUniqueName(_taskName);

      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: _updateInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
      );

      _logger.info(
          'Periodic location task registered (${_updateInterval.inMinutes}min interval)');
    } catch (e, stackTrace) {
      _logger.severe('Error registering periodic task', e, stackTrace);
    }
  }

  /// Start background location tracking
  static Future<void> start() async {
    try {
      _logger.info('Starting background location tracking');

      if (!_isInitialized) {
        await initialize();
      }

      await _registerPeriodicTask();
      _logger.info('Background location tracking started');
    } catch (e, stackTrace) {
      _logger.severe(
          'Error starting background location tracking', e, stackTrace);
    }
  }

  /// Stop background location tracking
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

  /// Restart background location tracking
  static Future<void> restart() async {
    try {
      _logger.info('Restarting background location tracking');
      await stop();
      await Future.delayed(const Duration(seconds: 1));
      await start();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error restarting background location tracking', e, stackTrace);
    }
  }

  /// Manual location update — for user-triggered "update now" actions
  static Future<void> updateLocationNow() async {
    _logger.info('Manual location update requested');

    try {
      final hasNetwork = await _checkNetworkConnectivity();
      if (!hasNetwork) {
        _logger.warning('No network connectivity');
        await _notificationService.showBasicNotification(
          id: 994,
          title: 'FindSafe',
          body:
              'Unable to update location. Please check your internet connection.',
          payload: 'location_no_network',
        );
        return;
      }

      final hasPermission = await _checkLocationPermissions();
      if (!hasPermission) {
        _logger.warning('No location permission');
        return;
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId');

      if (deviceId == null) {
        _logger.warning('Device ID not found');
        return;
      }

      await _locationService.updateLocation(deviceId, currentPosition);

      // Store last successful update
      await prefs.setString(
        'lastLocationUpdate',
        DateTime.now().toIso8601String(),
      );

      _logger.info('Manual location update completed');
    } catch (e, stackTrace) {
      _logger.severe('Error in manual location update', e, stackTrace);
    }
  }

  /// Check location permissions — requests only if denied (not denied forever)
  static Future<bool> _checkLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.warning('Location permission permanently denied');
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e, stackTrace) {
      _logger.severe('Error checking location permissions', e, stackTrace);
      return false;
    }
  }

  /// Check network connectivity
  static Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- Status getters for UI ---

  static bool get isInitialized => _isInitialized;

  static Future<bool> getStatus() async => _isInitialized;

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

  static Future<bool> canTrackInBackground() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}
