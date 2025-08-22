import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Enhanced Dio HTTP client with comprehensive configuration and interceptors
class DioClient {
  static const Duration _defaultConnectTimeout = Duration(seconds: 10);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 15);
  static const Duration _defaultSendTimeout = Duration(seconds: 10);
  
  late final Dio _dio;
  
  /// Get the configured Dio instance
  Dio get dio => _dio;
  
  /// Constructor with comprehensive configuration options
  DioClient({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
    bool enableLogging = true,
    bool followRedirects = true,
    int maxRedirects = 5,
    ResponseType responseType = ResponseType.json,
    String? contentType,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout ?? _defaultConnectTimeout,
        receiveTimeout: receiveTimeout ?? _defaultReceiveTimeout,
        sendTimeout: sendTimeout ?? _defaultSendTimeout,
        headers: headers ?? _getDefaultHeaders(),
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        responseType: responseType,
        contentType: contentType ?? Headers.jsonContentType,
        receiveDataWhenStatusError: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    // Add default interceptors
    if (enableLogging) {
      _addLoggingInterceptor();
    }
    _addErrorInterceptor();
    
    // Add custom interceptors if provided
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }
  
  /// Get default headers for HTTP requests
  Map<String, dynamic> _getDefaultHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }
  
  /// Add logging interceptor for debugging
  void _addLoggingInterceptor() {
    if (kDebugMode) {
      _dio.interceptors.add(AppLogger.createHttpLogger());
    }
  }
  
  /// Add error interceptor for common error handling
  void _addErrorInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add request timestamp for debugging
          options.extra['request_time'] = DateTime.now().millisecondsSinceEpoch;
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response time in debug mode
          if (kDebugMode) {
            final requestTime = response.requestOptions.extra['request_time'] as int?;
            if (requestTime != null) {
              final responseTime = DateTime.now().millisecondsSinceEpoch - requestTime;
              AppLogger.debug('Response time: ${responseTime}ms', '[HTTP Client]');
            }
          }
          handler.next(response);
        },
        onError: (error, handler) {
          // Enhanced error logging using AppLogger
          AppLogger.httpError(
            url: error.requestOptions.uri.toString(),
            dioError: error,
          );
          handler.next(error);
        },
      ),
    );
  }
  
  /// Create a specialized client for API services
  static DioClient createApiClient({
    required String baseUrl,
    required String userAgent,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? additionalHeaders,
    List<Interceptor>? interceptors,
    bool enableLogging = true,
    ResponseType responseType = ResponseType.json,
  }) {
    final headers = {
      'User-Agent': userAgent,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };
    
    return DioClient(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      interceptors: interceptors,
      enableLogging: enableLogging,
      responseType: responseType,
    );
  }
  
  /// Create a client for file downloads
  static DioClient createDownloadClient({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) {
    return DioClient(
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(minutes: 5),
      headers: headers,
      interceptors: interceptors,
      responseType: ResponseType.bytes,
      enableLogging: false, // Disable logging for large downloads
    );
  }
  
  /// Add an interceptor to the client
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
  
  /// Remove an interceptor from the client
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }
  
  /// Clear all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }
  
  /// Update base options
  void updateBaseOptions({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
  }) {
    _dio.options = _dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers,
    );
  }
  
  /// Dispose the client and close connections
  void dispose() {
    _dio.close(force: true);
  }
}