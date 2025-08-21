/// Application route names and paths
class AppRoutes {
  // Route names
  static const String home = '/';
  static const String search = '/search';
  static const String details = '/details';
  
  // Route paths with parameters
  static const String detailsWithCid = '/details/:cid';
  
  /// Generate route path for compound details
  static String compoundDetails(int cid) => '/details/$cid';
  
  /// All available routes list
  static const List<String> allRoutes = [
    home,
    search,
    details,
  ];
}