import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import '../theme/app_colors.dart';

/// Utility functions for formatting and validation
class AppHelpers {
  /// Format molecular weight with appropriate units
  static String formatMolecularWeight(double? weight) {
    if (weight == null) return 'N/A';
    return '${weight.toStringAsFixed(2)} g/mol';
  }
  
  /// Format molecular formula with subscripts
  static String formatMolecularFormula(String? formula) {
    if (formula == null || formula.isEmpty) return 'N/A';
    return formula;
  }
  
  /// Validate search term
  static bool isValidSearchTerm(String term) {
    if (term.trim().isEmpty) return false;
    if (term.length < AppConstants.minSearchLength) return false;
    if (term.length > AppConstants.maxSearchLength) return false;
    return AppRegex.searchTerm.hasMatch(term);
  }

  /// Validate search term and return error message if invalid
  static String? validateSearchTerm(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) {
      return 'Search term cannot be empty';
    }
    if (trimmed.length < AppConstants.minSearchLength) {
      return 'Search term must be at least ${AppConstants.minSearchLength} characters';
    }
    if (trimmed.length > AppConstants.maxSearchLength) {
      return 'Search term cannot exceed ${AppConstants.maxSearchLength} characters';
    }
    if (!AppRegex.searchTerm.hasMatch(trimmed)) {
      return 'Invalid search term format';
    }
    return null; // No error
  }
  
  /// Validate CAS number format
  static bool isValidCasNumber(String? casNumber) {
    if (casNumber == null || casNumber.isEmpty) return false;
    return AppRegex.casNumber.hasMatch(casNumber);
  }
  
  /// Validate molecular formula format
  static bool isValidMolecularFormula(String? formula) {
    if (formula == null || formula.isEmpty) return false;
    return AppRegex.molecularFormula.hasMatch(formula);
  }
  
  /// Get error message for HTTP status code
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case HttpStatusCodes.notFound:
        return AppConstants.compoundNotFoundMessage;
      case HttpStatusCodes.timeout:
        return AppConstants.timeoutErrorMessage;
      case HttpStatusCodes.tooManyRequests:
        return AppConstants.rateLimitErrorMessage;
      case HttpStatusCodes.serviceUnavailable:
        return AppConstants.serviceUnavailableMessage;
      case 0:
        return AppConstants.networkErrorMessage;
      default:
        return AppConstants.genericErrorMessage;
    }
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  /// Get color for hazard level
  static Color getHazardColor(List<String> hazards) {
    if (hazards.isEmpty) {
      return AppColors.safeCompound;
    }
    
    // Check for high-risk hazards
    final highRiskKeywords = ['toxic', 'carcinogen', 'explosive', 'corrosive'];
    final hasHighRisk = hazards.any((hazard) => 
        highRiskKeywords.any((keyword) => 
            hazard.toLowerCase().contains(keyword)));
    
    if (hasHighRisk) {
      return Colors.red;
    }
    
    return AppColors.hazardWarning;
  }
  
  /// Get hazard icon
  static IconData getHazardIcon(List<String> hazards) {
    if (hazards.isEmpty) {
      return Icons.check_circle;
    }
    
    // Check for specific hazard types
    final hazardText = hazards.join(' ').toLowerCase();
    
    if (hazardText.contains('fire') || hazardText.contains('flammable')) {
      return Icons.local_fire_department;
    }
    if (hazardText.contains('toxic') || hazardText.contains('poison')) {
      return Icons.dangerous;
    }
    if (hazardText.contains('corrosive')) {
      return Icons.science;
    }
    if (hazardText.contains('explosive')) {
      return Icons.warning;
    }
    
    return Icons.warning_amber;
  }
  
  /// Debounce function for search
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, {Duration? delay}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay ?? AppConstants.debounceDelay, callback);
  }
  
  /// Show snackbar with message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}