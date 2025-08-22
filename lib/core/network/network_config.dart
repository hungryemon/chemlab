/// Network configuration constants and settings
class NetworkConfig {
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // Retry configurations
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 5);
  
  // Rate limiting
  static const Duration rateLimitDelay = Duration(milliseconds: 200);
  static const int maxConcurrentRequests = 5;
  
  // Cache configurations
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // API specific configurations
  static const Map<String, ApiConfig> apiConfigs = {
    'pubchem': ApiConfig(
      baseUrl: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug',
      userAgent: 'ChemLab/1.0.0 (Flutter App)',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      rateLimitDelay: Duration(milliseconds: 200),
    ),
  };
  
  // Environment-specific settings
  static bool get isDebugMode {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }
  
  // Logging configuration
  static bool get enableRequestLogging => isDebugMode;
  static bool get enableResponseLogging => isDebugMode;
  static bool get enableErrorLogging => true;
}

/// Configuration for a specific API
class ApiConfig {
  final String baseUrl;
  final String userAgent;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration? sendTimeout;
  final Duration rateLimitDelay;
  final Map<String, String>? defaultHeaders;
  
  const ApiConfig({
    required this.baseUrl,
    required this.userAgent,
    required this.connectTimeout,
    required this.receiveTimeout,
    this.sendTimeout,
    required this.rateLimitDelay,
    this.defaultHeaders,
  });
  
  /// Get default headers for this API
  Map<String, String> getHeaders() {
    return {
      'User-Agent': userAgent,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?defaultHeaders,
    };
  }
}

/// Network environment configuration
enum NetworkEnvironment {
  development,
  staging,
  production,
}

/// Current network environment
class EnvironmentConfig {
  static const NetworkEnvironment current = NetworkEnvironment.development;
  
  /// Get environment-specific settings
  static Map<String, dynamic> getSettings() {
    switch (current) {
      case NetworkEnvironment.development:
        return {
          'enableLogging': true,
          'enableMockData': false,
          'cacheEnabled': true,
        };
      case NetworkEnvironment.staging:
        return {
          'enableLogging': true,
          'enableMockData': false,
          'cacheEnabled': true,
        };
      case NetworkEnvironment.production:
        return {
          'enableLogging': false,
          'enableMockData': false,
          'cacheEnabled': true,
        };
    }
  }
}