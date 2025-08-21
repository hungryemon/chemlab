import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/constants.dart';

/// Main entry point of the ChemLab application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Open Hive boxes for caching and preferences
  await Hive.openBox(AppConstants.cacheBoxName);
  await Hive.openBox(AppConstants.preferencesBoxName);
  await Hive.openBox(AppConstants.searchHistoryBoxName);
  
  // Run the ChemLab application
  runApp(const ChemLabApp());
}
