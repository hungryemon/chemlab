import 'dart:math';
import 'package:dio/dio.dart';
import 'network_exceptions.dart';

/// Interceptor that handles automatic retries for failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final Duration maxRetryDelay;
  final bool useExponentialBackoff;
  final double backoffMultiplier;
  
  const RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 10),
    this.useExponentialBackoff = true,
    this.backoffMultiplier = 2.0,
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] ?? 0;
    
    // Check if we should retry this error
    if (retryCount < maxRetries && _shouldRetry(err)) {
      try {
        // Calculate delay for this retry attempt
        final delay = _calculateDelay(retryCount);
        
        print('[Retry Interceptor] Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inMilliseconds}ms');
        
        // Wait before retrying
        await Future.delayed(delay);
        
        // Update retry count
        err.requestOptions.extra['retry_count'] = retryCount + 1;
        
        // Retry the request
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with the original error
        print('[Retry Interceptor] Retry failed: $e');
      }
    }
    
    // No more retries or error is not retryable
    handler.next(err);
  }
  
  /// Determine if the error should be retried
  bool _shouldRetry(DioException error) {
    // Convert to NetworkException to check if retryable
    final networkException = NetworkExceptionHandler.handleDioException(error);
    return NetworkExceptionHandler.isRetryable(networkException);
  }
  
  /// Calculate delay for retry attempt
  Duration _calculateDelay(int retryCount) {
    if (!useExponentialBackoff) {
      return retryDelay;
    }
    
    // Exponential backoff with jitter
    final baseDelay = retryDelay.inMilliseconds;
    final exponentialDelay = baseDelay * pow(backoffMultiplier, retryCount);
    
    // Add jitter (random factor between 0.5 and 1.5)
    final jitter = 0.5 + Random().nextDouble();
    final delayWithJitter = (exponentialDelay * jitter).round();
    
    // Cap at maximum delay
    final finalDelay = min(delayWithJitter, maxRetryDelay.inMilliseconds);
    
    return Duration(milliseconds: finalDelay);
  }
}

/// Retry policy configuration
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool useJitter;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;
  
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });
  
  /// Check if the error should be retried based on this policy
  bool shouldRetry(DioException error) {
    // Check exception type
    if (retryableExceptionTypes.contains(error.type)) {
      return true;
    }
    
    // Check status code
    final statusCode = error.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }
    
    return false;
  }
  
  /// Calculate delay for retry attempt
  Duration calculateDelay(int retryAttempt) {
    final baseDelay = initialDelay.inMilliseconds;
    final exponentialDelay = baseDelay * pow(backoffMultiplier, retryAttempt);
    
    double finalDelay = exponentialDelay.toDouble();
    
    // Add jitter if enabled
    if (useJitter) {
      final jitter = 0.5 + Random().nextDouble();
      finalDelay *= jitter;
    }
    
    // Cap at maximum delay
    finalDelay = min(finalDelay, maxDelay.inMilliseconds.toDouble());
    
    return Duration(milliseconds: finalDelay.round());
  }
}

/// Advanced retry interceptor with configurable policy
class AdvancedRetryInterceptor extends Interceptor {
  final RetryPolicy policy;
  
  const AdvancedRetryInterceptor(this.policy);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] ?? 0;
    
    if (retryCount < policy.maxRetries && policy.shouldRetry(err)) {
      try {
        final delay = policy.calculateDelay(retryCount);
        
        print('[Advanced Retry] Retrying request (${retryCount + 1}/${policy.maxRetries}) after ${delay.inMilliseconds}ms');
        
        await Future.delayed(delay);
        
        err.requestOptions.extra['retry_count'] = retryCount + 1;
        
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        print('[Advanced Retry] Retry failed: $e');
      }
    }
    
    handler.next(err);
  }
}