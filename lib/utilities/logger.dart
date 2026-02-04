import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

/// A utility class for logging in the FindSafe app.
class AppLogger {
  static final Map<String, Logger> _loggers = {};
  static bool _initialized = false;

  /// Initialize the logging system.
  static void init() {
    if (_initialized) return;
    
    // Set up logging
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print('${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
        
        if (record.error != null) {
          print('Error: ${record.error}');
        }
        
        if (record.stackTrace != null) {
          print('Stack trace:\n${record.stackTrace}');
        }
      }
    });
    
    _initialized = true;
  }

  /// Get a logger for a specific class or component.
  static Logger getLogger(String name) {
    if (!_initialized) init();
    
    return _loggers.putIfAbsent(name, () => Logger(name));
  }

  /// Log a debug message.
  static void d(String loggerName, String message, [Object? error, StackTrace? stackTrace]) {
    getLogger(loggerName).fine(message, error, stackTrace);
  }

  /// Log an info message.
  static void i(String loggerName, String message, [Object? error, StackTrace? stackTrace]) {
    getLogger(loggerName).info(message, error, stackTrace);
  }

  /// Log a warning message.
  static void w(String loggerName, String message, [Object? error, StackTrace? stackTrace]) {
    getLogger(loggerName).warning(message, error, stackTrace);
  }

  /// Log an error message.
  static void e(String loggerName, String message, [Object? error, StackTrace? stackTrace]) {
    getLogger(loggerName).severe(message, error, stackTrace);
  }
}
