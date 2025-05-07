import 'package:findsafe/service/location.dart';
import 'package:findsafe/service/websocket.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

final _locationService = LocationApiService();
final _logger = AppLogger.getLogger('BackgroundService');
final _notificationService = NotificationService();
final _webSocketService = WebSocketService();

// A more robust background service implementation
class BackgroundService {
  static Timer? _timer;
  static const Duration _interval = Duration(minutes: 15);
  static const Duration _reconnectInterval = Duration(minutes: 1);
  static int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;
  static bool _isRunning = false;
  static Duration _currentInterval = const Duration(minutes: 15);

  // Start the background service
  static Future<void> start() async {
    _logger.info('Starting background service');

    if (_isRunning) {
      _logger.info('Background service is already running');
      return;
    }

    if (_timer != null) {
      _timer!.cancel();
    }

    _isRunning = true;

    try {
      // Run immediately once
      await updateLocationTask();

      // Then schedule periodic updates
      _timer = Timer.periodic(_interval, (timer) async {
        await updateLocationTask();
      });

      _currentInterval = _interval;
      _logger.info('Background service started successfully');

      // Show a notification that the service is running
      await _notificationService.showBasicNotification(
        id: 999,
        title: 'FindSafe is active',
        body: 'Your device is being protected',
        payload: 'background_service',
      );
    } catch (e, stackTrace) {
      _logger.severe('Error starting background service', e, stackTrace);
      _isRunning = false;
    }
  }

  // Stop the background service
  static void stop() {
    _logger.info('Stopping background service');

    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    _isRunning = false;
    _logger.info('Background service stopped');

    // Cancel the service notification
    _notificationService.cancelNotification(999);
  }

  // Check if the service is running
  static bool isRunning() {
    return _isRunning;
  }

  // Handle failed attempts with exponential backoff
  static void _handleFailedAttempt() {
    _failedAttempts++;

    if (_failedAttempts >= _maxFailedAttempts) {
      _logger.warning(
          'Maximum failed attempts reached, reducing update frequency');

      // Restart with a longer interval
      if (_timer != null) {
        _timer!.cancel();

        // Use exponential backoff for retry interval
        final backoffInterval =
            Duration(minutes: 15 * (_failedAttempts - _maxFailedAttempts + 1));
        _timer = Timer.periodic(backoffInterval, (timer) async {
          await updateLocationTask();
        });

        _currentInterval = backoffInterval;
        _logger.info(
            'Retry scheduled with interval: ${backoffInterval.inMinutes} minutes');
      }
    }
  }

  // Reset failed attempts counter
  static void _resetFailedAttempts() {
    if (_failedAttempts > 0) {
      _failedAttempts = 0;
      _logger.info('Reset failed attempts counter');

      // If we were in backoff mode, restore normal interval
      if (_currentInterval != _interval) {
        if (_timer != null) {
          _timer!.cancel();
          _timer = Timer.periodic(_interval, (timer) async {
            await updateLocationTask();
          });
        }
        _currentInterval = _interval;
        _logger.info('Restored normal update interval');
      }
    }
  }
}

Future<void> initializeBackgroundService() async {
  _logger.info('Initializing background service');

  try {
    // Check and request location permissions
    LocationPermission permission;

    // Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      _logger.info('Location permission denied, requesting permission');
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.warning('Location permission permanently denied');

      // Show a notification to inform the user
      await _notificationService.showBasicNotification(
        id: 998,
        title: 'Location Access Required',
        body: 'FindSafe needs location access to protect your device',
        payload: 'location_permission',
      );

      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _logger.info('Location permission granted: $permission');

      // Initialize notifications first
      await _notificationService.initializeNotifications();

      // Start the background service
      await BackgroundService.start();
    } else {
      _logger.warning('Location permissions not granted: $permission');

      // Show a notification to inform the user
      await _notificationService.showBasicNotification(
        id: 998,
        title: 'Location Access Required',
        body: 'FindSafe needs location access to protect your device',
        payload: 'location_permission',
      );
    }
  } catch (e, stackTrace) {
    _logger.severe('Error initializing background service', e, stackTrace);
  }
}

Future<void> connectWebSocket() async {
  _logger.info('Connecting to WebSocket service');

  try {
    // Get device ID
    final deviceData = await SharedPreferences.getInstance();
    final deviceId = deviceData.getString('deviceId');

    if (deviceId == null) {
      _logger.warning('Cannot connect to WebSocket: Device ID is null');
      return;
    }

    // Connect to WebSocket
    await _webSocketService.connect();
    _logger.info('WebSocket connected successfully');
  } catch (e, stackTrace) {
    _logger.severe('Error connecting to WebSocket', e, stackTrace);

    // Schedule a reconnection attempt
    Timer(BackgroundService._reconnectInterval, () {
      connectWebSocket();
    });
  }
}

Future<void> updateLocationTask() async {
  _logger.info('Running location update task');

  try {
    // Check network connectivity first
    bool hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      _logger.warning('No network connectivity, skipping location update');
      BackgroundService._handleFailedAttempt();
      return;
    }

    // Get current position
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );

    _logger.info(
        'Current Location: ${currentPosition.latitude}, ${currentPosition.longitude}');

    // Get device ID
    final deviceData = await SharedPreferences.getInstance();
    final deviceId = deviceData.getString('deviceId');

    if (deviceId != null) {
      // Update location on server
      await _locationService.updateLocation(deviceId, currentPosition);
      _logger.info('Location updated successfully for device: $deviceId');

      // Attempt WebSocket reconnection if needed
      if (!_webSocketService.isConnected()) {
        _logger.info('WebSocket not connected, attempting to reconnect');
        await connectWebSocket();
      }

      // Reset failed attempts counter on success
      BackgroundService._resetFailedAttempts();
    } else {
      _logger.warning('Device ID not found in SharedPreferences');
      BackgroundService._handleFailedAttempt();
    }
  } catch (e, stackTrace) {
    _logger.severe('Error updating location', e, stackTrace);
    BackgroundService._handleFailedAttempt();

    // Try to recover by scheduling a retry
    Timer(const Duration(minutes: 1), () {
      updateLocationTask();
    });
  }
}

// Check if the device has network connectivity
Future<bool> _checkNetworkConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (e) {
    _logger.warning('No network connectivity: $e');
    return false;
  } catch (e) {
    _logger.warning('Error checking network connectivity: $e');
    return false;
  }
}
