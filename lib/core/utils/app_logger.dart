import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio/dio.dart';

/// Custom application logger that provides enhanced logging capabilities
/// for HTTP requests and general application logging
class AppLogger {
  static const String _tag = '[ChemLab]';
  
  /// Private constructor to prevent instantiation
  AppLogger._();
  
  /// Create a pretty Dio logger interceptor for HTTP requests
  /// 
  /// This interceptor provides beautiful, colored console output for HTTP requests
  /// and responses, making debugging easier during development.
  /// 
  /// Parameters:
  /// - [requestHeader]: Whether to log request headers (default: true)
  /// - [requestBody]: Whether to log request body (default: true)
  /// - [responseHeader]: Whether to log response headers (default: false)
  /// - [responseBody]: Whether to log response body (default: true)
  /// - [error]: Whether to log errors (default: true)
  /// - [compact]: Whether to use compact logging format (default: true)
  /// - [maxWidth]: Maximum width for console output (default: 90)
  static PrettyDioLogger createHttpLogger({
    bool requestHeader = true,
    bool requestBody = true,
    bool responseHeader = false,
    bool responseBody = true,
    bool error = true,
    bool compact = true,
    int maxWidth = 90,
  }) {
    return PrettyDioLogger(
      requestHeader: requestHeader,
      requestBody: requestBody,
      responseHeader: responseHeader,
      responseBody: responseBody,
      error: error,
      compact: compact,
      maxWidth: maxWidth,
      logPrint: (object) => _logPrint(object, LogLevel.info),
    );
  }
  
  /// Log debug messages (only in debug mode)
  /// 
  /// Use this for detailed debugging information that should not appear
  /// in production builds.
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _logPrint('${tag ?? _tag} [DEBUG] $message', LogLevel.debug);
    }
  }
  
  /// Log info messages
  /// 
  /// Use this for general information that might be useful for debugging
  /// or monitoring application flow.
  static void info(String message, [String? tag]) {
    _logPrint('${tag ?? _tag} [INFO] $message', LogLevel.info);
  }
  
  /// Log warning messages
  /// 
  /// Use this for potentially problematic situations that don't prevent
  /// the application from functioning.
  static void warning(String message, [String? tag]) {
    _logPrint('${tag ?? _tag} [WARNING] $message', LogLevel.warning);
  }
  
  /// Log error messages
  /// 
  /// Use this for error conditions that should be investigated.
  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    _logPrint('${tag ?? _tag} [ERROR] $message', LogLevel.error);
    if (error != null) {
      _logPrint('${tag ?? _tag} [ERROR] Exception: $error', LogLevel.error);
    }
    if (stackTrace != null) {
      _logPrint('${tag ?? _tag} [ERROR] StackTrace: $stackTrace', LogLevel.error);
    }
  }
  
  /// Log HTTP request details
  /// 
  /// Use this for logging HTTP request information in a standardized format.
  static void httpRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (kDebugMode) {
      debug('HTTP Request: $method $url');
      if (headers != null && headers.isNotEmpty) {
        debug('Headers: $headers');
      }
      if (body != null) {
        debug('Body: $body');
      }
    }
  }
  
  /// Log HTTP response details
  /// 
  /// Use this for logging HTTP response information in a standardized format.
  static void httpResponse({
    required int statusCode,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    int? responseTime,
  }) {
    if (kDebugMode) {
      final timeInfo = responseTime != null ? ' (${responseTime}ms)' : '';
      debug('HTTP Response: $statusCode $url$timeInfo');
      if (headers != null && headers.isNotEmpty) {
        debug('Headers: $headers');
      }
      if (body != null) {
        debug('Body: $body');
      }
    }
  }
  
  /// Log HTTP error details
  /// 
  /// Use this for logging HTTP error information in a standardized format.
  static void httpError({
    required String url,
    required DioException dioError,
  }) {
    AppLogger.error('HTTP Error: ${dioError.type} - $url', null, dioError, dioError.stackTrace);
    if (dioError.response != null) {
      AppLogger.error('Response Status: ${dioError.response?.statusCode}');
      AppLogger.error('Response Data: ${dioError.response?.data}');
    }
  }
  
  /// Internal method to handle actual logging
  /// 
  /// This method can be extended to integrate with external logging services
  /// like Firebase Crashlytics, Sentry, or other analytics platforms.
  static void _logPrint(Object object, LogLevel level) {
    if (kDebugMode) {
      // In debug mode, use debugPrint for better console output
      debugPrint(object.toString());
    } else {
      // In release mode, you might want to send logs to a remote service
      // For now, we'll just use print, but this can be extended
      print(object.toString());
    }
  }
}

/// Log levels for categorizing log messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Extension on LogLevel for additional functionality
extension LogLevelExtension on LogLevel {
  /// Get the string representation of the log level
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
  
  /// Get the priority level (higher number = higher priority)
  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
    }
  }
}