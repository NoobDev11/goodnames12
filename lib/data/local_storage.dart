import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();

  LocalStorage._internal();

  static LocalStorage get instance => _instance;

  factory LocalStorage() => _instance;

  /// Save a string value for a given key.
  /// Optional prefix to namespace keys.
  Future<void> setString(String key, String value, {String prefix = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$prefix$key', value);
  }

  /// Retrieve a string value for a given key.
  /// Optional prefix to namespace keys.
  Future<String?> getString(String key, {String prefix = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$prefix$key');
  }

  /// Remove a string value for a given key.
  /// Optional prefix to namespace keys.
  Future<void> remove(String key, {String prefix = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$prefix$key');
  }
}
