import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/compound_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/utils/constants.dart';
import 'core/routes/routes.dart';

/// Main application widget
class ChemLabApp extends StatelessWidget {
  /// Constructor
  const ChemLabApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CompoundProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization configuration
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            
            // Routing configuration
            routerConfig: RouteConfig.createRouter(),
          );
        },
      ),
    );
  }
}



/// Router extension for easy navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to home screen
  void goHome() => go(AppRoutes.home);
  
  /// Navigate to search screen with optional query
  void goSearch([String? query]) {
    if (query != null && query.isNotEmpty) {
      go('${AppRoutes.search}?q=${Uri.encodeComponent(query)}');
    } else {
      go(AppRoutes.search);
    }
  }
  
  /// Navigate to compound details screen
  void goCompoundDetails(int cid) {
    go(AppRoutes.compoundDetails(cid));
  }
  
  /// Push search screen with query
  void pushSearch([String? query]) {
    if (query != null && query.isNotEmpty) {
      push('${AppRoutes.search}?q=${Uri.encodeComponent(query)}');
    } else {
      push(AppRoutes.search);
    }
  }
  
  /// Push compound details screen
  void pushCompoundDetails(int cid) {
    push(AppRoutes.compoundDetails(cid));
  }
}