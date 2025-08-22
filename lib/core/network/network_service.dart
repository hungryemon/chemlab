import 'package:dio/dio.dart';
import 'network_exceptions.dart';

/// Abstract interface for network operations
abstract class NetworkService {
  /// Perform a GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
  
  /// Perform a POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
  
  /// Perform a PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
  
  /// Perform a DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
  
  /// Download a file
  Future<void> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });
  
  /// Upload a file
  Future<T> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  });
  
  /// Dispose resources
  void dispose();
}

/// Base implementation of NetworkService
class BaseNetworkService implements NetworkService {
  final Dio _dio;
  
  BaseNetworkService(this._dio);
  
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  Future<void> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  Future<T> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioException(e);
    }
  }
  
  @override
  void dispose() {
    _dio.close();
  }
}