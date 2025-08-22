/// Application constants and configuration values
class AppConstants {
  // App information
  static const String appName = 'ChemLab';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Chemical Compounds Explorer using PubChem API';
  
  // API configuration
  static const String pubchemBaseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';
  static const String userAgent = 'ChemLab/1.0.0 (Flutter App)';
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Cache configuration
  static const int maxCacheSize = 50;
  static const int maxSearchHistory = 20;
  static const Duration cacheExpiry = Duration(days: 7);
  
  // UI configuration
  static const int maxSearchResults = 10;
  static const int featuredCompoundsCount = 5;
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Featured compound names (common compounds)
  static const List<String> featuredCompoundNames = [
    'Water',
    'Glucose', 
    'Caffeine',
    'Methanol',
    'Aspirin',
    'Acetone',
    'Benzene',
  ];
  
  // Storage keys
  static const String themeBoxName = 'theme_settings';
  static const String compoundBoxName = 'compounds_cache';
  static const String searchHistoryBoxName = 'search_history';
  static const String themeModeKey = 'theme_mode';
  static const String cacheBoxName = 'compounds_cache';
  static const String preferencesBoxName = 'preferences';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String compoundNotFoundMessage = 'Compound not found';
  static const String genericErrorMessage = 'An error occurred. Please try again.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  static const String rateLimitErrorMessage = 'Too many requests. Please wait and try again.';
  static const String serviceUnavailableMessage = 'Service temporarily unavailable';
  static const String errorGeneral = 'An error occurred';
  static const String errorNoInternet = 'No internet connection';
  static const String errorNotFound = 'Compound not found';
  static const String errorInvalidInput = 'Invalid input';
  static const String errorNetworkMessage = 'Network connection failed';
  static const String errorServerMessage = 'Server error occurred';
  static const String errorTimeoutMessage = 'Request timed out';
  
  // Validation
  static const int minSearchLength = 2;
  static const int maxSearchLength = 100;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Regular expressions for validation
class AppRegex {
  /// CAS number validation pattern
  static final RegExp casNumber = RegExp(r'^\d{2,7}-\d{2}-\d$');
  
  /// Molecular formula validation pattern
  static final RegExp molecularFormula = RegExp(r'^[A-Z][a-z]?\d*([A-Z][a-z]?\d*)*$');
  
  /// Search term validation pattern (alphanumeric and common chemical symbols)
  static final RegExp searchTerm = RegExp(r'^[a-zA-Z0-9\s\-\.\(\)\[\]]+$');
}

/// HTTP status codes
class HttpStatusCodes {
  static const int ok = 200;
  static const int notFound = 404;
  static const int timeout = 408;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
}