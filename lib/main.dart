import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/habit_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Add other providers here as needed
      ],
      child: const HabitTrackerApp(),
    ),
  );
}
