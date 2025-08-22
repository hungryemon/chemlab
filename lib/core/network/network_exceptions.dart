import 'package:dio/dio.dart';

/// Base class for all network-related exceptions
abstract class NetworkException implements Exception {
  final String message;
  final int statusCode;
  
  const NetworkException(this.message, this.statusCode);
  
  @override
  String toString() => '${runtimeType}: $message (Status: $statusCode)';
}

/// API-specific exception
class ApiException extends NetworkException {
  const ApiException(super.message, super.statusCode);
}

/// Connection timeout exception
class ConnectionTimeoutException extends NetworkException {
  const ConnectionTimeoutException() : super('Connection timeout', 408);
}

/// Network unavailable exception
class NetworkUnavailableException extends NetworkException {
  const NetworkUnavailableException() : super('Network unavailable', 0);
}

/// Server error exception
class ServerException extends NetworkException {
  const ServerException(super.message, super.statusCode);
}

/// Rate limit exceeded exception
class RateLimitException extends NetworkException {
  const RateLimitException() : super('Rate limit exceeded', 429);
}

/// Resource not found exception
class NotFoundException extends NetworkException {
  const NotFoundException(String resource) : super('$resource not found', 404);
}

/// Request cancelled exception
class RequestCancelledException extends NetworkException {
  const RequestCancelledException() : super('Request cancelled', 499);
}

/// Service unavailable exception
class ServiceUnavailableException extends NetworkException {
  const ServiceUnavailableException() : super('Service unavailable', 503);
}

/// Utility class for handling Dio exceptions
class NetworkExceptionHandler {
  /// Convert DioException to appropriate NetworkException
  static NetworkException handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionTimeoutException();
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final message = e.response?.statusMessage ?? 'Unknown error';
        
        switch (statusCode) {
          case 404:
            return const NotFoundException('Resource');
          case 429:
            return const RateLimitException();
          case 503:
            return const ServiceUnavailableException();
          case >= 500:
            return ServerException(message, statusCode);
          default:
            return ApiException(message, statusCode);
        }
      
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return const NetworkUnavailableException();
    }
  }
  
  /// Check if exception is retryable
  static bool isRetryable(NetworkException exception) {
    return exception is ConnectionTimeoutException ||
           exception is NetworkUnavailableException ||
           exception is ServiceUnavailableException ||
           (exception is ServerException && exception.statusCode >= 500);
  }
  
  /// Get user-friendly error message
  static String getUserFriendlyMessage(NetworkException exception) {
    switch (exception.runtimeType) {
      case ConnectionTimeoutException:
        return 'Connection timed out. Please check your internet connection.';
      case NetworkUnavailableException:
        return 'No internet connection. Please check your network settings.';
      case NotFoundException:
        return 'The requested information could not be found.';
      case RateLimitException:
        return 'Too many requests. Please try again later.';
      case ServiceUnavailableException:
        return 'Service is temporarily unavailable. Please try again later.';
      case ServerException:
        return 'Server error occurred. Please try again later.';
      case RequestCancelledException:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}