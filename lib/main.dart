import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/local/local_data.dart';

/// Main entry point of the ChemLab application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database and all required boxes
  await HiveManager.initialize();
  
  // Run the ChemLab application
  runApp(const ChemLabApp());
}
