import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  static const _notificationKey = 'notifications_enabled';
  static const _darkModeKey = 'dark_mode_enabled';

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_notificationKey, enabled);
  }

  Future<bool> getDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_darkModeKey, enabled);
  }
}
