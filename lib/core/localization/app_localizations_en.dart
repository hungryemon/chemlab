// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Chemical Compounds';

  @override
  String get searchHint => 'Search compound';

  @override
  String get detailsTitle => 'Compound Details';

  @override
  String get searchTitle => 'Search Compounds';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noResults => 'No results found';

  @override
  String get molecularFormula => 'Molecular Formula';

  @override
  String get molecularWeight => 'Molecular Weight';

  @override
  String get iupacName => 'IUPAC Name';

  @override
  String get casNumber => 'CAS Number';

  @override
  String get synonyms => 'Synonyms';

  @override
  String get hazards => 'Hazards';

  @override
  String get description => 'Description';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get compoundNotFound => 'Compound not found';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get retry => 'Retry';

  @override
  String get hazardWarningColor => 'FFC107';

  @override
  String get safeCompoundColor => '4CAF50';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get resultsFound => 'results found';

  @override
  String get searchTips => 'Search Tips';

  @override
  String get featuredCompounds => 'Featured Compounds';
}
