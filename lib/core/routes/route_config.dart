import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/details/compound_detail_screen.dart';
import 'app_routes.dart';

/// Application route configuration using GoRouter
class RouteConfig {
  /// Creates the GoRouter instance with all application routes
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        // Home route
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Search route
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (context, state) {
            final query = state.uri.queryParameters['q'] ?? '';
            return SearchScreen(initialQuery: query.isNotEmpty ? query : null);
          },
        ),
        
        // Compound details route with CID parameter
        GoRoute(
          path: AppRoutes.detailsWithCid,
          name: 'details',
          builder: (context, state) {
            final cidString = state.pathParameters['cid'];
            final cid = int.tryParse(cidString ?? '');
            
            if (cid == null) {
              // Handle invalid CID - redirect to home or show error
              return const Scaffold(
                body: Center(
                  child: Text('Invalid compound ID'),
                ),
              );
            }
            
            return CompoundDetailScreen(cid: cid);
          },
        ),
      ],
      
      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}