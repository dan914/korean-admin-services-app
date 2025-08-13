/// Production-safe logger that can be easily disabled
class Logger {
  static const bool _enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: false);
  static const String _appName = '행정도우미';
  
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
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
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
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_appName $level: $message';
    
    // In development, print to console
    print(logMessage);
    if (data != null) {
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

/// Usage examples:
/// 
/// Instead of: print('Form submitted');
/// Use: Logger.info('Form submitted');
/// 
/// Instead of: print('Error: $e');
/// Use: Logger.error('Form submission failed', e);
/// 
/// For development only logs:
/// Logger.debug('Current state', state.toJson());
/// 
/// To enable logging:
/// flutter run --dart-define=ENABLE_LOGGING=true