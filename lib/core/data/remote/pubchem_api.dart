import '../../models/compound.dart';
import '../../network/network.dart';

/// API service for PubChem REST API integration
class PubChemApi {
  late final NetworkService _networkService;

  /// Constructor
  PubChemApi() {
    _networkService = NetworkManager.instance.pubchemService;
  }

  /// Constructor with custom network service (for testing)
  PubChemApi.withNetworkService(this._networkService);

  /// Search compounds by name
  /// Returns compound matching the search term
  Future<Compound?> searchCompounds(String searchTerm) async {
    try {
      int? searchCid = int.tryParse(searchTerm);
      String property = 'Title,MolecularFormula,MolecularWeight,IUPACName';
      final data = await _networkService.get<Map<String, dynamic>>(
        searchCid != null
            ? '/compound/cid/$searchCid/property/$property/JSON'
            : '/compound/name/$searchTerm/property/$property/JSON',
      );

      if (data['PropertyTable'] != null &&
          data['PropertyTable']['Properties'] != null) {
        final properties = data['PropertyTable']['Properties'][0];
        return Compound(
          cid: properties['CID'],
          title: properties['Title'] ?? '',
          molecularFormula: properties['MolecularFormula'],
          molecularWeight: properties['MolecularWeight'],
          iupacName: properties['IUPACName'],
          casNumber: properties['CASRegistryNumber'],
          fetchedAt: DateTime.now(),
        );
      }

      return null;
    } on NetworkException catch (e) {
      throw _convertNetworkException(e);
    }
  }

  /// Get compound details by CID
  Future<Compound> getCompoundDetails(int cid) async {
    try {
      final data = await _networkService.get<Map<String, dynamic>>(
        '/compound/cid/$cid/property/Title,MolecularFormula,MolecularWeight,IUPACName/JSON',
      );

      if (data['PropertyTable'] != null &&
          data['PropertyTable']['Properties'] != null) {
        final properties = data['PropertyTable']['Properties'][0];

        // Get synonyms separately
        final synonyms = await _getCompoundSynonyms(cid);

        return Compound(
          cid: cid,
          title: properties['Title'] ?? '',
          molecularFormula: properties['MolecularFormula'],
          molecularWeight: properties['MolecularWeight'],
          iupacName: properties['IUPACName'],
          casNumber: properties['CASRegistryNumber'],
          synonyms: synonyms,
          fetchedAt: DateTime.now(),
        );
      }

      throw PubChemApiException('Compound not found', 404);
    } on NetworkException catch (e) {
      throw _convertNetworkException(e);
    }
  }

  /// Get compound synonyms
  Future<List<String>> _getCompoundSynonyms(int cid) async {
    try {
      final data = await _networkService.get<Map<String, dynamic>>(
        '/compound/cid/$cid/synonyms/JSON',
      );

      if (data['InformationList'] != null &&
          data['InformationList']['Information'] != null &&
          data['InformationList']['Information'].isNotEmpty) {
        final synonyms = data['InformationList']['Information'][0]['Synonym'];
        return List<String>.from(synonyms ?? []);
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

  /// Convert network exceptions to PubChem API exceptions
  PubChemApiException _convertNetworkException(NetworkException e) {
    switch (e.runtimeType) {
      case NotFoundException:
        return PubChemApiException('Compound not found', e.statusCode);
      case RateLimitException:
        return PubChemApiException('Rate limit exceeded', e.statusCode);
      case ServiceUnavailableException:
        return PubChemApiException('Service unavailable', e.statusCode);
      case ConnectionTimeoutException:
        return PubChemApiException('Connection timeout', e.statusCode);
      case NetworkUnavailableException:
        return PubChemApiException('Network unavailable', e.statusCode);
      case ServerException:
        return PubChemApiException('Server error: ${e.message}', e.statusCode);
      case RequestCancelledException:
        return PubChemApiException('Request cancelled', e.statusCode);
      default:
        return PubChemApiException(e.message, e.statusCode);
    }
  }
}

/// Custom API exception class for PubChem API
class PubChemApiException implements Exception {
  final String message;
  final int statusCode;

  const PubChemApiException(this.message, this.statusCode);

  @override
  String toString() => 'PubChemApiException: $message (Status: $statusCode)';

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (statusCode) {
      case 404:
        return 'Compound not found. Please check the name or CID.';
      case 429:
        return 'Too many requests. Please try again in a moment.';
      case 503:
        return 'PubChem service is temporarily unavailable.';
      case 408:
        return 'Request timed out. Please check your connection.';
      case 0:
        return 'No internet connection available.';
      default:
        return 'An error occurred while fetching compound data.';
    }
  }
}
