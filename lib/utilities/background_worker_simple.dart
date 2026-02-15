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

/// In-app foreground background service using Timer.
/// Complements the Workmanager periodic task for when the app is in the foreground.
class BackgroundService {
  static Timer? _timer;
  static const Duration _interval = Duration(minutes: 15);
  static const Duration _reconnectInterval = Duration(minutes: 1);
  static int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;
  static bool _isRunning = false;
  static Duration _currentInterval = _interval;

  static Future<void> start() async {
    _logger.info('Starting background service');

    if (_isRunning) {
      _logger.info('Background service already running');
      return;
    }

    _timer?.cancel();
    _isRunning = true;

    try {
      // Run immediately once
      await updateLocationTask();

      // Schedule periodic updates
      _timer = Timer.periodic(_interval, (timer) async {
        await updateLocationTask();
      });

      _currentInterval = _interval;
      _logger.info('Background service started');
    } catch (e, stackTrace) {
      _logger.severe('Error starting background service', e, stackTrace);
      _isRunning = false;
    }
  }

  static void stop() {
    _logger.info('Stopping background service');
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  static bool isRunning() => _isRunning;

  /// Handle failed attempts with exponential backoff
  static void _handleFailedAttempt() {
    _failedAttempts++;

    if (_failedAttempts >= _maxFailedAttempts) {
      _logger.warning('Max failed attempts reached, backing off');

      _timer?.cancel();

      // Exponential backoff: 15min * multiplier
      final backoffMinutes = 15 * (_failedAttempts - _maxFailedAttempts + 2);
      final backoffInterval = Duration(minutes: backoffMinutes);

      _timer = Timer.periodic(backoffInterval, (timer) async {
        await updateLocationTask();
      });

      _currentInterval = backoffInterval;
      _logger
          .info('Retry interval set to ${backoffInterval.inMinutes} minutes');
    }
  }

  /// Reset failed attempts and restore normal interval
  static void _resetFailedAttempts() {
    if (_failedAttempts > 0) {
      _failedAttempts = 0;

      if (_currentInterval != _interval) {
        _timer?.cancel();
        _timer = Timer.periodic(_interval, (timer) async {
          await updateLocationTask();
        });
        _currentInterval = _interval;
        _logger.info('Restored normal update interval');
      }
    }
  }
}

Future<void> initializeBackgroundService() async {
  _logger.info('Initializing background service');

  try {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.warning('Location permission permanently denied');
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _logger.info('Location permission granted: $permission');

      await _notificationService.initializeNotifications();
      await BackgroundService.start();
    } else {
      _logger.warning('Location permissions not granted: $permission');
    }
  } catch (e, stackTrace) {
    _logger.severe('Error initializing background service', e, stackTrace);
  }
}

Future<void> connectWebSocket() async {
  _logger.info('Connecting to WebSocket');

  try {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('deviceId');

    if (deviceId == null) {
      _logger.warning('Cannot connect WebSocket: no device ID');
      return;
    }

    await _webSocketService.connect();
    _logger.info('WebSocket connected');
  } catch (e, stackTrace) {
    _logger.severe('Error connecting to WebSocket', e, stackTrace);

    // Schedule reconnection
    Timer(BackgroundService._reconnectInterval, () {
      connectWebSocket();
    });
  }
}

Future<void> updateLocationTask() async {
  _logger.info('Running location update task');

  try {
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      _logger.warning('No network, skipping location update');
      BackgroundService._handleFailedAttempt();
      return;
    }

    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );

    _logger.info(
        'Location: ${currentPosition.latitude}, ${currentPosition.longitude}');

    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('deviceId');

    if (deviceId != null) {
      await _locationService.updateLocation(deviceId, currentPosition);
      _logger.info('Location updated for device: $deviceId');

      // Store last successful update
      await prefs.setString(
        'lastLocationUpdate',
        DateTime.now().toIso8601String(),
      );

      // Reconnect WebSocket if needed
      if (!_webSocketService.isConnected()) {
        await connectWebSocket();
      }

      BackgroundService._resetFailedAttempts();
    } else {
      _logger.warning('Device ID not found');
      BackgroundService._handleFailedAttempt();
    }
  } catch (e, stackTrace) {
    _logger.severe('Error updating location', e, stackTrace);
    BackgroundService._handleFailedAttempt();
  }
}

Future<bool> _checkNetworkConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } catch (e) {
    return false;
  }
}
