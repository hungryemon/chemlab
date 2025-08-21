import 'package:dio/dio.dart';
import '../models/compound.dart';

/// API service for PubChem REST API integration
class PubChemApi {
  static const String _baseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';
  static const String _userAgent = 'ChemLab/1.0.0 (Flutter App)';
  
  late final Dio _dio;
  
  /// Constructor
  PubChemApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[PubChem API] $obj'),
      ),
    );
  }
  
  /// Search compounds by name
  /// Returns list of compound CIDs matching the search term
  Future<List<int>> searchCompounds(String searchTerm) async {
    try {
      int? searchCid = int.tryParse(searchTerm);
      final response = await _dio.get(
        searchCid != null ? '/compound/cid/$searchCid/cids/JSON'
        : '/compound/name/$searchTerm/cids/JSON',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['IdentifierList'] != null && data['IdentifierList']['CID'] != null) {
          return List<int>.from(data['IdentifierList']['CID']);
        }
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  /// Get compound details by CID
  Future<Compound> getCompoundDetails(int cid) async {
    try {
      final response = await _dio.get(
        '/compound/cid/$cid/property/Title,MolecularFormula,MolecularWeight,IUPACName/JSON',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['PropertyTable'] != null && data['PropertyTable']['Properties'] != null) {
          final properties = data['PropertyTable']['Properties'][0];
          
          // Get synonyms separately
          final synonyms = await _getCompoundSynonyms(cid);
          
          return Compound(
            cid: cid,
            title: properties['Title'] ?? '',
            molecularFormula: properties['MolecularFormula'],
            molecularWeight: properties['MolecularWeight']?.toDouble(),
            iupacName: properties['IUPACName'],
            casNumber: properties['CASRegistryNumber'],
            synonyms: synonyms,
            fetchedAt: DateTime.now(),
          );
        }
      }
      
      throw ApiException('Compound not found', 404);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  /// Get compound synonyms
  Future<List<String>> _getCompoundSynonyms(int cid) async {
    try {
      final response = await _dio.get(
        '/compound/cid/$cid/synonyms/JSON',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['InformationList'] != null && 
            data['InformationList']['Information'] != null &&
            data['InformationList']['Information'].isNotEmpty) {
          final synonyms = data['InformationList']['Information'][0]['Synonym'];
          return List<String>.from(synonyms ?? []);
        }
      }
      
      return [];
    } catch (e) {
      // Return empty list if synonyms fetch fails
      return [];
    }
  }
  
  /// Get multiple compounds by CIDs
  Future<List<Compound>> getMultipleCompounds(List<int> cids) async {
    final compounds = <Compound>[];
    
    // Process in batches to avoid overwhelming the API
    const batchSize = 5;
    for (int i = 0; i < cids.length; i += batchSize) {
      final batch = cids.skip(i).take(batchSize).toList();
      final futures = batch.map((cid) => getCompoundDetails(cid));
      
      try {
        final results = await Future.wait(futures);
        compounds.addAll(results);
      } catch (e) {
        // Continue with other batches even if one fails
        print('Failed to fetch batch starting at index $i: $e');
      }
      
      // Add delay between batches to respect rate limits
      if (i + batchSize < cids.length) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    
    return compounds;
  }
  
  /// Handle Dio exceptions and convert to custom exceptions
  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout', 408);
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        switch (statusCode) {
          case 404:
            return ApiException('Compound not found', 404);
          case 429:
            return ApiException('Rate limit exceeded', 429);
          case 503:
            return ApiException('Service unavailable', 503);
          default:
            return ApiException('Server error', statusCode);
        }
      
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', 499);
      
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return ApiException('Network error', 0);
    }
  }
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  const ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}