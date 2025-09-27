import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/habit_provider.dart';
import 'providers/habit_stats_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitStatsProvider()),
        ChangeNotifierProxyProvider<HabitStatsProvider, HabitProvider>(
          create: (context) => HabitProvider(context.read<HabitStatsProvider>()),
          update: (context, statsProvider, previous) =>
              previous ?? HabitProvider(statsProvider),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const RootApp(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HabitTrackerApp(),
    );
  }
}
