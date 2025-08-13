/// Production-safe logger that can be easily disabled
class Logger {
  static const bool _enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: false);
  static const String _appName = 'AdminApp';
  
  /// Log levels
  static const String _DEBUG = '🔧 DEBUG';
  static const String _INFO = 'ℹ️ INFO';
  static const String _WARNING = '⚠️ WARNING';
  static const String _ERROR = '❌ ERROR';
  static const String _SUCCESS = '✅ SUCCESS';
  
  /// Debug logging - only in development
  static void debug(String message, [dynamic data]) {
    if (_enableLogging) {
      _log(_DEBUG, message, data);
    }
  }
  
  /// Info logging
  static void info(String message, [dynamic data]) {
    if (_enableLogging) {
      _log(_INFO, message, data);
    }
  }
  
  /// Warning logging
  static void warning(String message, [dynamic data]) {
    if (_enableLogging) {
      _log(_WARNING, message, data);
    }
  }
  
  /// Error logging - always enabled in debug mode
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // In production, send to error tracking service instead
    if (_enableLogging) {
      _log(_ERROR, message, error);
      if (stackTrace != null && _enableLogging) {
        // Using _log instead of print for stack traces
        _log(_ERROR, 'Stack trace', stackTrace.toString());
      }
    }
    
    // TODO: Send to error tracking service (Sentry, Firebase Crashlytics, etc.)
    // _sendToErrorTracking(message, error, stackTrace);
  }
  
  /// Success logging
  static void success(String message, [dynamic data]) {
    if (_enableLogging) {
      _log(_SUCCESS, message, data);
    }
  }
  
  /// Internal logging method
  static void _log(String level, String message, [dynamic data]) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_appName $level: $message';
    
    // In development, print to console
    // Note: These are the only print statements that should remain
    // They're controlled by the ENABLE_LOGGING flag
    // ignore: avoid_print
    print(logMessage);
    if (data != null) {
      // ignore: avoid_print
      print('Data: $data');
    }
    
    // In production, you could send to a logging service
    // _sendToLoggingService(level, message, data);
  }
  
  /// Network request logging
  static void network(String method, String url, {int? statusCode, dynamic body}) {
    if (_enableLogging) {
      final message = '$method $url${statusCode != null ? ' - Status: $statusCode' : ''}';
      _log('🌐 NETWORK', message, body);
    }
  }
  
  /// Performance logging
  static void performance(String operation, Duration duration) {
    if (_enableLogging) {
      _log('⚡ PERFORMANCE', '$operation took ${duration.inMilliseconds}ms');
    }
  }
  
  /// Measure and log operation duration
  static Future<T> measure<T>(String operation, Future<T> Function() callback) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await callback();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      error('$operation failed after ${stopwatch.elapsed.inMilliseconds}ms', e);
      rethrow;
    }
  }
}