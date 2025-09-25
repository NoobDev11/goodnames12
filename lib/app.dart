import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';
import 'providers/settings_provider.dart';

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Habit Tracker',
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/addHabit') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AddHabitScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }
}
