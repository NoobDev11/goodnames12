// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkMode => _darkMode;

  // Compatibility getter expected by other parts of the project
  bool get darkModeEnabled => _darkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _darkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }

  // Main dark mode setter
  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', enabled);
  }

  // Compatibility method expected elsewhere
  Future<void> setDarkModeEnabled(bool enabled) async => setDarkMode(enabled);
}
