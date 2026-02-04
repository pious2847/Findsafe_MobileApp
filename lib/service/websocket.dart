import 'dart:async';
import 'dart:convert';
import 'package:findsafe/utilities/alarm.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _alarmService = AlarmService();
  Timer? _reconnectTimer;
  final _logger = AppLogger.getLogger('WebSocketService');
  bool _isConnected = false;
  String? _deviceId;

  // Check if WebSocket is connected
  bool isConnected() {
    return _isConnected;
  }

  // Get the current device ID
  String? get deviceId => _deviceId;

  Future<void> connect() async {
    // If already connected, don't reconnect
    if (_isConnected && _channel != null) {
      _logger.info('WebSocket already connected');
      return;
    }

    try {
      // Cancel any existing reconnect timer
      if (_reconnectTimer != null) {
        _reconnectTimer!.cancel();
        _reconnectTimer = null;
      }

      // Get device ID from shared preferences
      final deviceData = await SharedPreferences.getInstance();
      _deviceId = deviceData.getString('deviceId');

      if (_deviceId == null) {
        _logger.warning('Cannot connect to WebSocket: Device ID is null');
        _isConnected = false;
        return;
      }

      const String webSocketUrl =
          'wss://findsafe-backend.onrender.com'; // Use 'wss' for secure WebSocket connection
      _logger.info('Connecting to WebSocket: $webSocketUrl');
      _logger.info('Device ID: $_deviceId');

      // Close existing channel if any
      await _closeChannel();

      // Create new connection
      _channel = IOWebSocketChannel.connect(
        Uri.parse('$webSocketUrl/$_deviceId'),
      );

      // Listen for messages
      _channel?.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _logger.warning('WebSocket connection closed');
          _isConnected = false;
          _reconnect();
        },
        onError: (error, stackTrace) {
          _logger.severe('WebSocket Error', error, stackTrace);
          _isConnected = false;
          _reconnect();
        },
      );

      _isConnected = true;
      _logger.info('WebSocket connection established');
    } catch (e, stackTrace) {
      _isConnected = false;
      _logger.severe('Error connecting to WebSocket', e, stackTrace);
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decodedMessage = utf8.decode(message);
      final data = jsonDecode(decodedMessage);

      _logger.info('Received command: $data');

      // Check if the message is for this device
      if (data['deviceId'] == _deviceId) {
        switch (data['command']) {
          case 'play_alarm':
            _logger.info('Executing play_alarm command');
            _alarmService.playAlarm();
            break;
          case 'lock_device':
            _logger.info('Executing lock_device command');
            _alarmService.lockDevice();
            break;
          case 'wipe_data':
            _logger.info('Executing wipe_data command');
            _alarmService.wipeData();
            break;
          default:
            _logger.warning('Unknown command: ${data['command']}');
        }
      } else {
        _logger.warning(
            'Received command for different device: ${data['deviceId']}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error in message handling', e, stackTrace);
    }
  }

  void _reconnect() {
    // Only schedule reconnection if not already scheduled
    if (_reconnectTimer != null) {
      return;
    }

    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      _logger.info('Reconnecting to WebSocket...');
      connect();
    });
  }

  // Close the WebSocket channel safely
  Future<void> _closeChannel() async {
    if (_channel != null) {
      try {
        await _channel?.sink.close();
      } catch (e) {
        _logger.warning('Error closing WebSocket channel: $e');
      }
      _channel = null;
    }
  }

  Future<void> disconnect() async {
    try {
      _logger.info('Disconnecting from WebSocket');

      // Cancel reconnect timer if active
      if (_reconnectTimer != null) {
        _reconnectTimer!.cancel();
        _reconnectTimer = null;
      }

      // Close the channel
      await _closeChannel();

      _isConnected = false;
      _logger.info('WebSocket disconnected');
    } catch (e, stackTrace) {
      _logger.severe('Error disconnecting from WebSocket', e, stackTrace);
    }
  }

  Future<bool> sendCommand(String command) async {
    if (!_isConnected || _channel == null) {
      _logger.warning('Cannot send command: WebSocket not connected');

      // Try to reconnect
      await connect();

      // If still not connected, fail
      if (!_isConnected || _channel == null) {
        return false;
      }
    }

    try {
      _logger.info('Sending command: $command');
      _channel?.sink.add(command);
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error sending command', e, stackTrace);
      _isConnected = false;
      _reconnect();
      return false;
    }
  }
}
