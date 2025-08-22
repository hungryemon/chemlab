import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'network_config.dart';
import 'network_service.dart';
import 'retry_interceptor.dart';

/// Centralized network manager for creating and managing API clients
class NetworkManager {
  static NetworkManager? _instance;
  final Map<String, NetworkService> _services = {};
  final Map<String, DioClient> _clients = {};
  
  NetworkManager._();
  
  /// Get singleton instance
  static NetworkManager get instance {
    _instance ??= NetworkManager._();
    return _instance!;
  }
  
  /// Create or get a network service for a specific API
  NetworkService getService(String apiKey) {
    if (_services.containsKey(apiKey)) {
      return _services[apiKey]!;
    }
    
    final config = NetworkConfig.apiConfigs[apiKey];
    if (config == null) {
      throw ArgumentError('No configuration found for API: $apiKey');
    }
    
    final dioClient = _createDioClient(config);
    _clients[apiKey] = dioClient;
    final service = BaseNetworkService(dioClient.dio);
    _services[apiKey] = service;
    
    return service;
  }
  
  /// Create a custom network service with specific configuration
  NetworkService createCustomService({
    required String baseUrl,
    required String userAgent,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
    List<Interceptor>? interceptors,
  }) {
    final dioClient = DioClient.createApiClient(
      baseUrl: baseUrl,
      userAgent: userAgent,
      connectTimeout: connectTimeout ?? NetworkConfig.connectTimeout,
       receiveTimeout: receiveTimeout ?? NetworkConfig.receiveTimeout,
       sendTimeout: NetworkConfig.sendTimeout,
      additionalHeaders: headers,
      interceptors: interceptors,
    );
    
    return BaseNetworkService(dioClient.dio);
  }
  
  /// Create DioClient with configuration
  DioClient _createDioClient(ApiConfig config) {
    final interceptors = <Interceptor>[
      // Add retry interceptor
      RetryInterceptor(
        maxRetries: NetworkConfig.maxRetryAttempts,
        retryDelay: NetworkConfig.retryDelay,
      ),
      
      // Add rate limiting interceptor
      _createRateLimitInterceptor(config.rateLimitDelay),
    ];
    
    return DioClient.createApiClient(
       baseUrl: config.baseUrl,
       userAgent: config.userAgent,
       connectTimeout: config.connectTimeout,
       receiveTimeout: config.receiveTimeout,
       sendTimeout: config.sendTimeout,
       interceptors: interceptors,
     );
  }
  
  /// Create rate limiting interceptor
  Interceptor _createRateLimitInterceptor(Duration delay) {
    DateTime? lastRequestTime;
    
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (lastRequestTime != null) {
          final timeSinceLastRequest = DateTime.now().difference(lastRequestTime!);
          if (timeSinceLastRequest < delay) {
            final waitTime = delay - timeSinceLastRequest;
            await Future.delayed(waitTime);
          }
        }
        lastRequestTime = DateTime.now();
        handler.next(options);
      },
    );
  }
  
  /// Get PubChem API service
  NetworkService get pubchemService => getService('pubchem');
  
  /// Dispose all services
  void dispose() {
    for (final service in _services.values) {
      service.dispose();
    }
    for (final client in _clients.values) {
      client.dispose();
    }
    _services.clear();
    _clients.clear();
    _instance = null;
  }
  
  /// Clear specific service
  void clearService(String apiKey) {
    final service = _services.remove(apiKey);
    service?.dispose();
    final client = _clients.remove(apiKey);
    client?.dispose();
  }
  
  /// Check if service exists
  bool hasService(String apiKey) {
    return _services.containsKey(apiKey);
  }
  
  /// Get all active service keys
  List<String> get activeServices => _services.keys.toList();
}